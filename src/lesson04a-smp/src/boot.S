#include "arm/sysregs.h"

#include "mm.h"

.section ".text.boot"

.globl _start
_start:
	mrs	x28, mpidr_el1		
	and	x28, x28, #0xFF				// x28: core id
		
dead: cbnz x28, dead

    adr     x5, core_flags
check_flag:	
	ldr     x4, [x5, x28, lsl #3]	// x4: the core's flag. 
    cbnz    x4, core_boot			// Flag non zero. This core may proceed. 

	wfe		// wait to be signaled. 
	b 		check_flag
    
core_boot: 	
	ldr	x0, =SCTLR_VALUE_MMU_DISABLED // System control register
	msr	sctlr_el1, x0		

	// configure hypervisor. Notably, set EL1 to be AArch64
	ldr	x0, =HCR_VALUE  	// Hypervisor Configuration (EL2) 
	msr	hcr_el2, x0  

	// elevate from the current EL to EL1, where the kernel runs
#ifdef USE_QEMU 		
	// QEMU boots from EL2. cannot do things to EL3			
	ldr	x0, =SPSR_VALUE	
	msr	spsr_el2, x0

	adr	x0, el1_entry		
	msr	elr_el2, x0
#else 					// xzl: Rpi3 hw boots from EL3. 
	ldr	x0, =SCR_VALUE	// Secure config register. Only at EL3.
	msr	scr_el3, x0

	ldr	x0, =SPSR_VALUE
	msr	spsr_el3, x0

	adr	x0, el1_entry		
	msr	elr_el3, x0
#endif
  
	// go to EL1!
	eret				

el1_entry:
	cbnz x28, 1f		// only core0 clears BSS 
	adr	x0, bss_begin
	adr	x1, bss_end
	sub	x1, x1, x0
	bl 	memzero

	// Set up the stack. 
	// The stack location depends on CPU core asking
	// LOW_MEMORY is the top (i.e. base) of core0's stack. 
	// then core'1 stack top is below that; so on & so forth
1: 	
    mov     x3, #LOW_MEMORY   
    lsl     x28, x28, #9           // Multiply core_number by 512
    sub     x3, x3, x28           // Subtrace from core0's stack top
    mov     sp, x3
	
	adr	x4, jump_table		
	//ldr x4, [x1, x28, lsl #3]
	lsl x2, x28, #3
	add x4, x4, x2

	// Go in through jump_table per our core ID
    mov     x0, x28 	// x28=core id as the 1st argument 
    mov     x1, #0
    mov     x2, #0
    mov     x3, #0
    blr     x4		
    
proc_hang:
	b 	proc_hang		// should never come here


// the following defines integers as flags for core0/1/2/3
// ltorg = instruct the assembler to assemble the current literal pool immediately

.ltorg

// TODO: explain .org
.org 0xd8
.globl spin_cpu0
spin_cpu0:
        .quad 1  // emit 8 bytes of 0s. as the placeholder of core0's flag 

.org 0xe0
.globl spin_cpu1
spin_cpu1:
        .quad 0 // ditto

.org 0xe8
.globl spin_cpu2
spin_cpu2:
        .quad 0 // ditto

.org 0xf0
.globl spin_cpu3
spin_cpu3:
        .quad 0 // ditto

.globl core_flags
core_flags: 
	.quad 1	// 8 bytes
	.quad 0
	.quad 0
	.quad 0

jump_table: 
	bl 	kernel_main
	bl	secondary_core
	bl	secondary_core
	bl	secondary_core

