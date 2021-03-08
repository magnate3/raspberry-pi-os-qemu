
build/kernel8.elf:     file format elf64-littleaarch64


Disassembly of section .text.boot:

0000000000080000 <_start>:

.section ".text.boot"

.globl _start
_start:
	mrs	x0, mpidr_el1		
   80000:	d53800a0 	mrs	x0, mpidr_el1
	and	x0, x0,#0xFF		// Check processor id
   80004:	92401c00 	and	x0, x0, #0xff
	cbz	x0, master		// Hang for all non-primary CPU
   80008:	b4000060 	cbz	x0, 80014 <master>
	b	proc_hang
   8000c:	14000001 	b	80010 <proc_hang>

0000000000080010 <proc_hang>:

proc_hang: 
	b 	proc_hang
   80010:	14000000 	b	80010 <proc_hang>

0000000000080014 <master>:

master:
	ldr	x0, =SCTLR_VALUE_MMU_DISABLED // System control register
   80014:	58000220 	ldr	x0, 80058 <el1_entry+0x20>
	msr	sctlr_el1, x0		
   80018:	d5181000 	msr	sctlr_el1, x0

	ldr	x0, =HCR_VALUE  	// Hypervisor Configuration (EL2) 
   8001c:	58000220 	ldr	x0, 80060 <el1_entry+0x28>
	msr	hcr_el2, x0  
   80020:	d51c1100 	msr	hcr_el2, x0

#ifdef USE_QEMU 		// xzl: qemu boots from EL2. cannot do things to EL3			
	ldr	x0, =SPSR_VALUE	
   80024:	58000220 	ldr	x0, 80068 <el1_entry+0x30>
	msr	spsr_el2, x0
   80028:	d51c4000 	msr	spsr_el2, x0

	adr	x0, el1_entry		
   8002c:	10000060 	adr	x0, 80038 <el1_entry>
	msr	elr_el2, x0
   80030:	d51c4020 	msr	elr_el2, x0

	adr	x0, el1_entry		
	msr	elr_el3, x0
#endif
  
	eret				
   80034:	d69f03e0 	eret

0000000000080038 <el1_entry>:

el1_entry:
	adr	x0, bss_begin
   80038:	10019e00 	adr	x0, 833f8 <bss_begin>
	adr	x1, bss_end
   8003c:	10405e81 	adr	x1, 100c0c <bss_end>
	sub	x1, x1, x0
   80040:	cb000021 	sub	x1, x1, x0
	bl 	memzero
   80044:	94000b75 	bl	82e18 <memzero>

	mov	sp, #LOW_MEMORY
   80048:	b26a03ff 	mov	sp, #0x400000              	// #4194304
	bl	kernel_main
   8004c:	94000215 	bl	808a0 <kernel_main>
	b 	proc_hang		// should never come here
   80050:	17fffff0 	b	80010 <proc_hang>
   80054:	00000000 	.inst	0x00000000 ; undefined
   80058:	30d00800 	.word	0x30d00800
   8005c:	00000000 	.word	0x00000000
   80060:	80000000 	.word	0x80000000
   80064:	00000000 	.word	0x00000000
   80068:	000001c5 	.word	0x000001c5
   8006c:	00000000 	.word	0x00000000

Disassembly of section .text:

0000000000080800 <process>:
#include "fork.h"
#include "sched.h"
#include "mini_uart.h"

void process(char *array)
{
   80800:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80804:	910003fd 	mov	x29, sp
   80808:	f9000fa0 	str	x0, [x29, #24]
	while (1) {
		for (int i = 0; i < 5; i++){
   8080c:	b9002fbf 	str	wzr, [x29, #44]
   80810:	1400000c 	b	80840 <process+0x40>
			uart_send(array[i]);
   80814:	b9802fa0 	ldrsw	x0, [x29, #44]
   80818:	f9400fa1 	ldr	x1, [x29, #24]
   8081c:	8b000020 	add	x0, x1, x0
   80820:	39400000 	ldrb	w0, [x0]
   80824:	940000a5 	bl	80ab8 <uart_send>
			delay(5000000);
   80828:	d2896800 	mov	x0, #0x4b40                	// #19264
   8082c:	f2a00980 	movk	x0, #0x4c, lsl #16
   80830:	940004b4 	bl	81b00 <delay>
		for (int i = 0; i < 5; i++){
   80834:	b9402fa0 	ldr	w0, [x29, #44]
   80838:	11000400 	add	w0, w0, #0x1
   8083c:	b9002fa0 	str	w0, [x29, #44]
   80840:	b9402fa0 	ldr	w0, [x29, #44]
   80844:	7100101f 	cmp	w0, #0x4
   80848:	54fffe6d 	b.le	80814 <process+0x14>
   8084c:	17fffff0 	b	8080c <process+0xc>

0000000000080850 <process2>:
		}
	}
}

void process2(char *array)
{
   80850:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80854:	910003fd 	mov	x29, sp
   80858:	f9000fa0 	str	x0, [x29, #24]
	while (1) {
		for (int i = 0; i < 5; i++){
   8085c:	b9002fbf 	str	wzr, [x29, #44]
   80860:	1400000c 	b	80890 <process2+0x40>
			uart_send(array[i]);
   80864:	b9802fa0 	ldrsw	x0, [x29, #44]
   80868:	f9400fa1 	ldr	x1, [x29, #24]
   8086c:	8b000020 	add	x0, x1, x0
   80870:	39400000 	ldrb	w0, [x0]
   80874:	94000091 	bl	80ab8 <uart_send>
			delay(5000000);
   80878:	d2896800 	mov	x0, #0x4b40                	// #19264
   8087c:	f2a00980 	movk	x0, #0x4c, lsl #16
   80880:	940004a0 	bl	81b00 <delay>
		for (int i = 0; i < 5; i++){
   80884:	b9402fa0 	ldr	w0, [x29, #44]
   80888:	11000400 	add	w0, w0, #0x1
   8088c:	b9002fa0 	str	w0, [x29, #44]
   80890:	b9402fa0 	ldr	w0, [x29, #44]
   80894:	7100101f 	cmp	w0, #0x4
   80898:	54fffe6d 	b.le	80864 <process2+0x14>
   8089c:	17fffff0 	b	8085c <process2+0xc>

00000000000808a0 <kernel_main>:
		}
	}
}

void kernel_main(void)
{
   808a0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   808a4:	910003fd 	mov	x29, sp
	uart_init();
   808a8:	940000bd 	bl	80b9c <uart_init>
	init_printf(0, putc);
   808ac:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   808b0:	f940a400 	ldr	x0, [x0, #328]
   808b4:	aa0003e1 	mov	x1, x0
   808b8:	d2800000 	mov	x0, #0x0                   	// #0
   808bc:	940003d6 	bl	81814 <init_printf>

	printf("kernel boots\n");
   808c0:	d0000000 	adrp	x0, 82000 <vectors>
   808c4:	9139e000 	add	x0, x0, #0xe78
   808c8:	940003e1 	bl	8184c <tfp_printf>

	irq_vector_init();
   808cc:	94000490 	bl	81b0c <irq_vector_init>
	generic_timer_init();
   808d0:	94000470 	bl	81a90 <generic_timer_init>
	enable_interrupt_controller();
   808d4:	94000024 	bl	80964 <enable_interrupt_controller>
	enable_irq();
   808d8:	94000490 	bl	81b18 <enable_irq>

	int res = copy_process((unsigned long)&process, (unsigned long)"12345");
   808dc:	90000000 	adrp	x0, 80000 <_start>
   808e0:	91200002 	add	x2, x0, #0x800
   808e4:	d0000000 	adrp	x0, 82000 <vectors>
   808e8:	913a2000 	add	x0, x0, #0xe88
   808ec:	aa0003e1 	mov	x1, x0
   808f0:	aa0203e0 	mov	x0, x2
   808f4:	94000199 	bl	80f58 <copy_process>
   808f8:	b9001fa0 	str	w0, [x29, #28]
	if (res != 0) {
   808fc:	b9401fa0 	ldr	w0, [x29, #28]
   80900:	7100001f 	cmp	w0, #0x0
   80904:	540000a0 	b.eq	80918 <kernel_main+0x78>  // b.none
		printf("error while starting process 1");
   80908:	d0000000 	adrp	x0, 82000 <vectors>
   8090c:	913a4000 	add	x0, x0, #0xe90
   80910:	940003cf 	bl	8184c <tfp_printf>
		return;
   80914:	14000012 	b	8095c <kernel_main+0xbc>
	}
	res = copy_process((unsigned long)&process2, (unsigned long)"abcde");
   80918:	90000000 	adrp	x0, 80000 <_start>
   8091c:	91214002 	add	x2, x0, #0x850
   80920:	d0000000 	adrp	x0, 82000 <vectors>
   80924:	913ac000 	add	x0, x0, #0xeb0
   80928:	aa0003e1 	mov	x1, x0
   8092c:	aa0203e0 	mov	x0, x2
   80930:	9400018a 	bl	80f58 <copy_process>
   80934:	b9001fa0 	str	w0, [x29, #28]
	if (res != 0) {
   80938:	b9401fa0 	ldr	w0, [x29, #28]
   8093c:	7100001f 	cmp	w0, #0x0
   80940:	540000a0 	b.eq	80954 <kernel_main+0xb4>  // b.none
		printf("error while starting process 2");
   80944:	d0000000 	adrp	x0, 82000 <vectors>
   80948:	913ae000 	add	x0, x0, #0xeb8
   8094c:	940003c0 	bl	8184c <tfp_printf>
		return;
   80950:	14000003 	b	8095c <kernel_main+0xbc>
	}

	while (1){
		schedule();
   80954:	9400013a 	bl	80e3c <schedule>
   80958:	17ffffff 	b	80954 <kernel_main+0xb4>
	}	
}
   8095c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   80960:	d65f03c0 	ret

0000000000080964 <enable_interrupt_controller>:
    "FIQ_INVALID_EL0_32",		
    "ERROR_INVALID_EL0_32"	
};

void enable_interrupt_controller()
{
   80964:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80968:	910003fd 	mov	x29, sp
    // Enables Core 0 Timers interrupt control for the generic timer 
    put32(TIMER_INT_CTRL_0, TIMER_INT_CTRL_0_VALUE);
   8096c:	52800041 	mov	w1, #0x2                   	// #2
   80970:	d2800800 	mov	x0, #0x40                  	// #64
   80974:	f2a80000 	movk	x0, #0x4000, lsl #16
   80978:	9400045e 	bl	81af0 <put32>
}
   8097c:	d503201f 	nop
   80980:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80984:	d65f03c0 	ret

0000000000080988 <show_invalid_entry_message>:

void show_invalid_entry_message(int type, unsigned long esr, unsigned long address)
{
   80988:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8098c:	910003fd 	mov	x29, sp
   80990:	b9002fa0 	str	w0, [x29, #44]
   80994:	f90013a1 	str	x1, [x29, #32]
   80998:	f9000fa2 	str	x2, [x29, #24]
    printf("%s, ESR: %x, address: %x\r\n", entry_error_messages[type], esr, address);
   8099c:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   809a0:	9105c000 	add	x0, x0, #0x170
   809a4:	b9802fa1 	ldrsw	x1, [x29, #44]
   809a8:	f8617801 	ldr	x1, [x0, x1, lsl #3]
   809ac:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   809b0:	91016000 	add	x0, x0, #0x58
   809b4:	f9400fa3 	ldr	x3, [x29, #24]
   809b8:	f94013a2 	ldr	x2, [x29, #32]
   809bc:	940003a4 	bl	8184c <tfp_printf>
}
   809c0:	d503201f 	nop
   809c4:	a8c37bfd 	ldp	x29, x30, [sp], #48
   809c8:	d65f03c0 	ret

00000000000809cc <handle_irq>:

void handle_irq(void)
{
   809cc:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   809d0:	910003fd 	mov	x29, sp
    // Each Core has its own pending local intrrupts register
    unsigned int irq = get32(INT_SOURCE_0);
   809d4:	d2800c00 	mov	x0, #0x60                  	// #96
   809d8:	f2a80000 	movk	x0, #0x4000, lsl #16
   809dc:	94000447 	bl	81af8 <get32>
   809e0:	b9001fa0 	str	w0, [x29, #28]
    switch (irq) {
   809e4:	b9401fa0 	ldr	w0, [x29, #28]
   809e8:	7100081f 	cmp	w0, #0x2
   809ec:	54000061 	b.ne	809f8 <handle_irq+0x2c>  // b.any
        case (GENERIC_TIMER_INTERRUPT):
            handle_generic_timer_irq();
   809f0:	9400042f 	bl	81aac <handle_generic_timer_irq>
            break;
   809f4:	14000005 	b	80a08 <handle_irq+0x3c>
        default:
            printf("Unknown pending irq: %x\r\n", irq);
   809f8:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   809fc:	9101e000 	add	x0, x0, #0x78
   80a00:	b9401fa1 	ldr	w1, [x29, #28]
   80a04:	94000392 	bl	8184c <tfp_printf>
    }
   80a08:	d503201f 	nop
   80a0c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   80a10:	d65f03c0 	ret

0000000000080a14 <get_free_page>:
#include "mm.h"

static unsigned short mem_map [ PAGING_PAGES ] = {0,};

unsigned long get_free_page()
{
   80a14:	d10043ff 	sub	sp, sp, #0x10
	for (int i = 0; i < PAGING_PAGES; i++){
   80a18:	b9000fff 	str	wzr, [sp, #12]
   80a1c:	14000014 	b	80a6c <get_free_page+0x58>
		if (mem_map[i] == 0){
   80a20:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80a24:	910fe000 	add	x0, x0, #0x3f8
   80a28:	b9800fe1 	ldrsw	x1, [sp, #12]
   80a2c:	78617800 	ldrh	w0, [x0, x1, lsl #1]
   80a30:	7100001f 	cmp	w0, #0x0
   80a34:	54000161 	b.ne	80a60 <get_free_page+0x4c>  // b.any
			mem_map[i] = 1;
   80a38:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80a3c:	910fe000 	add	x0, x0, #0x3f8
   80a40:	b9800fe1 	ldrsw	x1, [sp, #12]
   80a44:	52800022 	mov	w2, #0x1                   	// #1
   80a48:	78217802 	strh	w2, [x0, x1, lsl #1]
			return LOW_MEMORY + i*PAGE_SIZE;
   80a4c:	b9400fe0 	ldr	w0, [sp, #12]
   80a50:	11100000 	add	w0, w0, #0x400
   80a54:	53144c00 	lsl	w0, w0, #12
   80a58:	93407c00 	sxtw	x0, w0
   80a5c:	1400000a 	b	80a84 <get_free_page+0x70>
	for (int i = 0; i < PAGING_PAGES; i++){
   80a60:	b9400fe0 	ldr	w0, [sp, #12]
   80a64:	11000400 	add	w0, w0, #0x1
   80a68:	b9000fe0 	str	w0, [sp, #12]
   80a6c:	b9400fe1 	ldr	w1, [sp, #12]
   80a70:	529d7fe0 	mov	w0, #0xebff                	// #60415
   80a74:	72a00060 	movk	w0, #0x3, lsl #16
   80a78:	6b00003f 	cmp	w1, w0
   80a7c:	54fffd2d 	b.le	80a20 <get_free_page+0xc>
		}
	}
	return 0;
   80a80:	d2800000 	mov	x0, #0x0                   	// #0
}
   80a84:	910043ff 	add	sp, sp, #0x10
   80a88:	d65f03c0 	ret

0000000000080a8c <free_page>:

void free_page(unsigned long p){
   80a8c:	d10043ff 	sub	sp, sp, #0x10
   80a90:	f90007e0 	str	x0, [sp, #8]
	mem_map[(p - LOW_MEMORY) / PAGE_SIZE] = 0;
   80a94:	f94007e0 	ldr	x0, [sp, #8]
   80a98:	d1500000 	sub	x0, x0, #0x400, lsl #12
   80a9c:	d34cfc01 	lsr	x1, x0, #12
   80aa0:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80aa4:	910fe000 	add	x0, x0, #0x3f8
   80aa8:	7821781f 	strh	wzr, [x0, x1, lsl #1]
}
   80aac:	d503201f 	nop
   80ab0:	910043ff 	add	sp, sp, #0x10
   80ab4:	d65f03c0 	ret

0000000000080ab8 <uart_send>:
#include "utils.h"
#include "peripherals/mini_uart.h"
#include "peripherals/gpio.h"

void uart_send ( char c )
{
   80ab8:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   80abc:	910003fd 	mov	x29, sp
   80ac0:	39007fa0 	strb	w0, [x29, #31]
	while(1) {
		if(get32(AUX_MU_LSR_REG)&0x20) 
   80ac4:	d28a0a80 	mov	x0, #0x5054                	// #20564
   80ac8:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80acc:	9400040b 	bl	81af8 <get32>
   80ad0:	121b0000 	and	w0, w0, #0x20
   80ad4:	7100001f 	cmp	w0, #0x0
   80ad8:	54000041 	b.ne	80ae0 <uart_send+0x28>  // b.any
   80adc:	17fffffa 	b	80ac4 <uart_send+0xc>
			break;
   80ae0:	d503201f 	nop
	}
	put32(AUX_MU_IO_REG,c);
   80ae4:	39407fa0 	ldrb	w0, [x29, #31]
   80ae8:	2a0003e1 	mov	w1, w0
   80aec:	d28a0800 	mov	x0, #0x5040                	// #20544
   80af0:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80af4:	940003ff 	bl	81af0 <put32>
}
   80af8:	d503201f 	nop
   80afc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   80b00:	d65f03c0 	ret

0000000000080b04 <uart_recv>:

char uart_recv ( void )
{
   80b04:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80b08:	910003fd 	mov	x29, sp
	while(1) {
		if(get32(AUX_MU_LSR_REG)&0x01) 
   80b0c:	d28a0a80 	mov	x0, #0x5054                	// #20564
   80b10:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80b14:	940003f9 	bl	81af8 <get32>
   80b18:	12000000 	and	w0, w0, #0x1
   80b1c:	7100001f 	cmp	w0, #0x0
   80b20:	54000041 	b.ne	80b28 <uart_recv+0x24>  // b.any
   80b24:	17fffffa 	b	80b0c <uart_recv+0x8>
			break;
   80b28:	d503201f 	nop
	}
	return(get32(AUX_MU_IO_REG)&0xFF);
   80b2c:	d28a0800 	mov	x0, #0x5040                	// #20544
   80b30:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80b34:	940003f1 	bl	81af8 <get32>
   80b38:	12001c00 	and	w0, w0, #0xff
}
   80b3c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80b40:	d65f03c0 	ret

0000000000080b44 <uart_send_string>:

void uart_send_string(char* str)
{
   80b44:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80b48:	910003fd 	mov	x29, sp
   80b4c:	f9000fa0 	str	x0, [x29, #24]
	for (int i = 0; str[i] != '\0'; i ++) {
   80b50:	b9002fbf 	str	wzr, [x29, #44]
   80b54:	14000009 	b	80b78 <uart_send_string+0x34>
		uart_send((char)str[i]);
   80b58:	b9802fa0 	ldrsw	x0, [x29, #44]
   80b5c:	f9400fa1 	ldr	x1, [x29, #24]
   80b60:	8b000020 	add	x0, x1, x0
   80b64:	39400000 	ldrb	w0, [x0]
   80b68:	97ffffd4 	bl	80ab8 <uart_send>
	for (int i = 0; str[i] != '\0'; i ++) {
   80b6c:	b9402fa0 	ldr	w0, [x29, #44]
   80b70:	11000400 	add	w0, w0, #0x1
   80b74:	b9002fa0 	str	w0, [x29, #44]
   80b78:	b9802fa0 	ldrsw	x0, [x29, #44]
   80b7c:	f9400fa1 	ldr	x1, [x29, #24]
   80b80:	8b000020 	add	x0, x1, x0
   80b84:	39400000 	ldrb	w0, [x0]
   80b88:	7100001f 	cmp	w0, #0x0
   80b8c:	54fffe61 	b.ne	80b58 <uart_send_string+0x14>  // b.any
	}
}
   80b90:	d503201f 	nop
   80b94:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80b98:	d65f03c0 	ret

0000000000080b9c <uart_init>:

void uart_init ( void )
{
   80b9c:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   80ba0:	910003fd 	mov	x29, sp
	unsigned int selector;

	selector = get32(GPFSEL1);
   80ba4:	d2800080 	mov	x0, #0x4                   	// #4
   80ba8:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80bac:	940003d3 	bl	81af8 <get32>
   80bb0:	b9001fa0 	str	w0, [x29, #28]
	selector &= ~(7<<12);                   // clean gpio14
   80bb4:	b9401fa0 	ldr	w0, [x29, #28]
   80bb8:	12117000 	and	w0, w0, #0xffff8fff
   80bbc:	b9001fa0 	str	w0, [x29, #28]
	selector |= 2<<12;                      // set alt5 for gpio14
   80bc0:	b9401fa0 	ldr	w0, [x29, #28]
   80bc4:	32130000 	orr	w0, w0, #0x2000
   80bc8:	b9001fa0 	str	w0, [x29, #28]
	selector &= ~(7<<15);                   // clean gpio15
   80bcc:	b9401fa0 	ldr	w0, [x29, #28]
   80bd0:	120e7000 	and	w0, w0, #0xfffc7fff
   80bd4:	b9001fa0 	str	w0, [x29, #28]
	selector |= 2<<15;                      // set alt5 for gpio15
   80bd8:	b9401fa0 	ldr	w0, [x29, #28]
   80bdc:	32100000 	orr	w0, w0, #0x10000
   80be0:	b9001fa0 	str	w0, [x29, #28]
	put32(GPFSEL1,selector);
   80be4:	b9401fa1 	ldr	w1, [x29, #28]
   80be8:	d2800080 	mov	x0, #0x4                   	// #4
   80bec:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80bf0:	940003c0 	bl	81af0 <put32>

	put32(GPPUD,0);
   80bf4:	52800001 	mov	w1, #0x0                   	// #0
   80bf8:	d2801280 	mov	x0, #0x94                  	// #148
   80bfc:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80c00:	940003bc 	bl	81af0 <put32>
	delay(150);
   80c04:	d28012c0 	mov	x0, #0x96                  	// #150
   80c08:	940003be 	bl	81b00 <delay>
	put32(GPPUDCLK0,(1<<14)|(1<<15));
   80c0c:	52980001 	mov	w1, #0xc000                	// #49152
   80c10:	d2801300 	mov	x0, #0x98                  	// #152
   80c14:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80c18:	940003b6 	bl	81af0 <put32>
	delay(150);
   80c1c:	d28012c0 	mov	x0, #0x96                  	// #150
   80c20:	940003b8 	bl	81b00 <delay>
	put32(GPPUDCLK0,0);
   80c24:	52800001 	mov	w1, #0x0                   	// #0
   80c28:	d2801300 	mov	x0, #0x98                  	// #152
   80c2c:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80c30:	940003b0 	bl	81af0 <put32>

	put32(AUX_ENABLES,1);                   //Enable mini uart (this also enables access to it registers)
   80c34:	52800021 	mov	w1, #0x1                   	// #1
   80c38:	d28a0080 	mov	x0, #0x5004                	// #20484
   80c3c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c40:	940003ac 	bl	81af0 <put32>
	put32(AUX_MU_CNTL_REG,0);               //Disable auto flow control and disable receiver and transmitter (for now)
   80c44:	52800001 	mov	w1, #0x0                   	// #0
   80c48:	d28a0c00 	mov	x0, #0x5060                	// #20576
   80c4c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c50:	940003a8 	bl	81af0 <put32>
	put32(AUX_MU_IER_REG,0);                //Disable receive and transmit interrupts
   80c54:	52800001 	mov	w1, #0x0                   	// #0
   80c58:	d28a0880 	mov	x0, #0x5044                	// #20548
   80c5c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c60:	940003a4 	bl	81af0 <put32>
	put32(AUX_MU_LCR_REG,3);                //Enable 8 bit mode
   80c64:	52800061 	mov	w1, #0x3                   	// #3
   80c68:	d28a0980 	mov	x0, #0x504c                	// #20556
   80c6c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c70:	940003a0 	bl	81af0 <put32>
	put32(AUX_MU_MCR_REG,0);                //Set RTS line to be always high
   80c74:	52800001 	mov	w1, #0x0                   	// #0
   80c78:	d28a0a00 	mov	x0, #0x5050                	// #20560
   80c7c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c80:	9400039c 	bl	81af0 <put32>
	put32(AUX_MU_BAUD_REG,270);             //Set baud rate to 115200
   80c84:	528021c1 	mov	w1, #0x10e                 	// #270
   80c88:	d28a0d00 	mov	x0, #0x5068                	// #20584
   80c8c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80c90:	94000398 	bl	81af0 <put32>

	put32(AUX_MU_CNTL_REG,3);               //Finally, enable transmitter and receiver
   80c94:	52800061 	mov	w1, #0x3                   	// #3
   80c98:	d28a0c00 	mov	x0, #0x5060                	// #20576
   80c9c:	f2a7e420 	movk	x0, #0x3f21, lsl #16
   80ca0:	94000394 	bl	81af0 <put32>
}
   80ca4:	d503201f 	nop
   80ca8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   80cac:	d65f03c0 	ret

0000000000080cb0 <putc>:


// This function is required by printf function
void putc ( void* p, char c)
{
   80cb0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   80cb4:	910003fd 	mov	x29, sp
   80cb8:	f9000fa0 	str	x0, [x29, #24]
   80cbc:	39005fa1 	strb	w1, [x29, #23]
	uart_send(c);
   80cc0:	39405fa0 	ldrb	w0, [x29, #23]
   80cc4:	97ffff7d 	bl	80ab8 <uart_send>
}
   80cc8:	d503201f 	nop
   80ccc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   80cd0:	d65f03c0 	ret

0000000000080cd4 <preempt_disable>:
struct task_struct * task[NR_TASKS] = {&(init_task), };
int nr_tasks = 1;

void preempt_disable(void)
{
	current->preempt_count++;
   80cd4:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80cd8:	9107c000 	add	x0, x0, #0x1f0
   80cdc:	f9400000 	ldr	x0, [x0]
   80ce0:	f9404001 	ldr	x1, [x0, #128]
   80ce4:	91000421 	add	x1, x1, #0x1
   80ce8:	f9004001 	str	x1, [x0, #128]
}
   80cec:	d503201f 	nop
   80cf0:	d65f03c0 	ret

0000000000080cf4 <preempt_enable>:

void preempt_enable(void)
{
	current->preempt_count--;
   80cf4:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80cf8:	9107c000 	add	x0, x0, #0x1f0
   80cfc:	f9400000 	ldr	x0, [x0]
   80d00:	f9404001 	ldr	x1, [x0, #128]
   80d04:	d1000421 	sub	x1, x1, #0x1
   80d08:	f9004001 	str	x1, [x0, #128]
}
   80d0c:	d503201f 	nop
   80d10:	d65f03c0 	ret

0000000000080d14 <_schedule>:


void _schedule(void)
{
   80d14:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80d18:	910003fd 	mov	x29, sp
	/* ensure no context happens in the following code region
   80d1c:	97ffffee 	bl	80cd4 <preempt_disable>
		we still leave irq on, because irq handler may set a task to be TASK_RUNNING, which 
		will be picked up by the scheduler below */
	preempt_disable(); 
	int next,c;
   80d20:	12800000 	mov	w0, #0xffffffff            	// #-1
   80d24:	b9002ba0 	str	w0, [x29, #40]
	struct task_struct * p;
   80d28:	b9002fbf 	str	wzr, [x29, #44]
	while (1) {
   80d2c:	b90027bf 	str	wzr, [x29, #36]
   80d30:	1400001a 	b	80d98 <_schedule+0x84>
		c = -1; // the maximum counter of all tasks 
   80d34:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80d38:	9107e000 	add	x0, x0, #0x1f8
   80d3c:	b98027a1 	ldrsw	x1, [x29, #36]
   80d40:	f8617800 	ldr	x0, [x0, x1, lsl #3]
   80d44:	f9000fa0 	str	x0, [x29, #24]
		next = 0;
   80d48:	f9400fa0 	ldr	x0, [x29, #24]
   80d4c:	f100001f 	cmp	x0, #0x0
   80d50:	540001e0 	b.eq	80d8c <_schedule+0x78>  // b.none
   80d54:	f9400fa0 	ldr	x0, [x29, #24]
   80d58:	f9403400 	ldr	x0, [x0, #104]
   80d5c:	f100001f 	cmp	x0, #0x0
   80d60:	54000161 	b.ne	80d8c <_schedule+0x78>  // b.any
   80d64:	f9400fa0 	ldr	x0, [x29, #24]
   80d68:	f9403801 	ldr	x1, [x0, #112]
   80d6c:	b9802ba0 	ldrsw	x0, [x29, #40]
   80d70:	eb00003f 	cmp	x1, x0
   80d74:	540000cd 	b.le	80d8c <_schedule+0x78>

   80d78:	f9400fa0 	ldr	x0, [x29, #24]
   80d7c:	f9403800 	ldr	x0, [x0, #112]
   80d80:	b9002ba0 	str	w0, [x29, #40]
		/* Iterates over all tasks and tries to find a task in 
   80d84:	b94027a0 	ldr	w0, [x29, #36]
   80d88:	b9002fa0 	str	w0, [x29, #44]
	while (1) {
   80d8c:	b94027a0 	ldr	w0, [x29, #36]
   80d90:	11000400 	add	w0, w0, #0x1
   80d94:	b90027a0 	str	w0, [x29, #36]
   80d98:	b94027a0 	ldr	w0, [x29, #36]
   80d9c:	7100fc1f 	cmp	w0, #0x3f
   80da0:	54fffcad 	b.le	80d34 <_schedule+0x20>
		TASK_RUNNING state with the maximum counter. If such 
		a task is found, we immediately break from the while loop 
		and switch to this task. */
   80da4:	b9402ba0 	ldr	w0, [x29, #40]
   80da8:	7100001f 	cmp	w0, #0x0
   80dac:	54000341 	b.ne	80e14 <_schedule+0x100>  // b.any

		for (int i = 0; i < NR_TASKS; i++){
			p = task[i];
   80db0:	b90023bf 	str	wzr, [x29, #32]
   80db4:	14000014 	b	80e04 <_schedule+0xf0>
			if (p && p->state == TASK_RUNNING && p->counter > c) {
   80db8:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80dbc:	9107e000 	add	x0, x0, #0x1f8
   80dc0:	b98023a1 	ldrsw	x1, [x29, #32]
   80dc4:	f8617800 	ldr	x0, [x0, x1, lsl #3]
   80dc8:	f9000fa0 	str	x0, [x29, #24]
				c = p->counter;
   80dcc:	f9400fa0 	ldr	x0, [x29, #24]
   80dd0:	f100001f 	cmp	x0, #0x0
   80dd4:	54000120 	b.eq	80df8 <_schedule+0xe4>  // b.none
				next = i;
   80dd8:	f9400fa0 	ldr	x0, [x29, #24]
   80ddc:	f9403800 	ldr	x0, [x0, #112]
   80de0:	9341fc01 	asr	x1, x0, #1
   80de4:	f9400fa0 	ldr	x0, [x29, #24]
   80de8:	f9403c00 	ldr	x0, [x0, #120]
   80dec:	8b000021 	add	x1, x1, x0
   80df0:	f9400fa0 	ldr	x0, [x29, #24]
   80df4:	f9003801 	str	x1, [x0, #112]
			p = task[i];
   80df8:	b94023a0 	ldr	w0, [x29, #32]
   80dfc:	11000400 	add	w0, w0, #0x1
   80e00:	b90023a0 	str	w0, [x29, #32]
   80e04:	b94023a0 	ldr	w0, [x29, #32]
   80e08:	7100fc1f 	cmp	w0, #0x3f
   80e0c:	54fffd6d 	b.le	80db8 <_schedule+0xa4>
	int next,c;
   80e10:	17ffffc4 	b	80d20 <_schedule+0xc>

   80e14:	d503201f 	nop
			}
		}
		if (c) {
			break;
   80e18:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80e1c:	9107e000 	add	x0, x0, #0x1f8
   80e20:	b9802fa1 	ldrsw	x1, [x29, #44]
   80e24:	f8617800 	ldr	x0, [x0, x1, lsl #3]
   80e28:	9400000f 	bl	80e64 <switch_to>
		}
   80e2c:	97ffffb2 	bl	80cf4 <preempt_enable>

   80e30:	d503201f 	nop
   80e34:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80e38:	d65f03c0 	ret

0000000000080e3c <schedule>:
		/* If no such task is found, this is either because i) no 
		task is in TASK_RUNNING state or ii) all such tasks have 0 counters.
		in our current implemenation which misses TASK_WAIT, only condition ii) is possible. 
   80e3c:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80e40:	910003fd 	mov	x29, sp
		Hence, we recharge counters. Bump counters for all tasks once. */
   80e44:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80e48:	9107c000 	add	x0, x0, #0x1f0
   80e4c:	f9400000 	ldr	x0, [x0]
   80e50:	f900381f 	str	xzr, [x0, #112]
		
   80e54:	97ffffb0 	bl	80d14 <_schedule>
		for (int i = 0; i < NR_TASKS; i++) {
   80e58:	d503201f 	nop
   80e5c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80e60:	d65f03c0 	ret

0000000000080e64 <switch_to>:
			p = task[i];
			if (p) {
				p->counter = (p->counter >> 1) + p->priority;
   80e64:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80e68:	910003fd 	mov	x29, sp
   80e6c:	f9000fa0 	str	x0, [x29, #24]
			}
   80e70:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80e74:	9107c000 	add	x0, x0, #0x1f0
   80e78:	f9400000 	ldr	x0, [x0]
   80e7c:	f9400fa1 	ldr	x1, [x29, #24]
   80e80:	eb00003f 	cmp	x1, x0
   80e84:	540001a0 	b.eq	80eb8 <switch_to+0x54>  // b.none
		}
	}
   80e88:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80e8c:	9107c000 	add	x0, x0, #0x1f0
   80e90:	f9400000 	ldr	x0, [x0]
   80e94:	f90017a0 	str	x0, [x29, #40]
	switch_to(task[next]);
   80e98:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80e9c:	9107c000 	add	x0, x0, #0x1f0
   80ea0:	f9400fa1 	ldr	x1, [x29, #24]
   80ea4:	f9000001 	str	x1, [x0]
	preempt_enable();
   80ea8:	f9400fa1 	ldr	x1, [x29, #24]
   80eac:	f94017a0 	ldr	x0, [x29, #40]
   80eb0:	940007de 	bl	82e28 <cpu_switch_to>
   80eb4:	14000002 	b	80ebc <switch_to+0x58>
		}
   80eb8:	d503201f 	nop
}
   80ebc:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80ec0:	d65f03c0 	ret

0000000000080ec4 <schedule_tail>:

void schedule(void)
   80ec4:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80ec8:	910003fd 	mov	x29, sp
{
   80ecc:	97ffff8a 	bl	80cf4 <preempt_enable>
	current->counter = 0;
   80ed0:	d503201f 	nop
   80ed4:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80ed8:	d65f03c0 	ret

0000000000080edc <timer_tick>:
	_schedule();
}

void switch_to(struct task_struct * next) 
   80edc:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80ee0:	910003fd 	mov	x29, sp
{
   80ee4:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80ee8:	9107c000 	add	x0, x0, #0x1f0
   80eec:	f9400000 	ldr	x0, [x0]
   80ef0:	f9403801 	ldr	x1, [x0, #112]
   80ef4:	d1000421 	sub	x1, x1, #0x1
   80ef8:	f9003801 	str	x1, [x0, #112]
	if (current == next) 
   80efc:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80f00:	9107c000 	add	x0, x0, #0x1f0
   80f04:	f9400000 	ldr	x0, [x0]
   80f08:	f9403800 	ldr	x0, [x0, #112]
   80f0c:	f100001f 	cmp	x0, #0x0
   80f10:	540001ec 	b.gt	80f4c <timer_tick+0x70>
   80f14:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80f18:	9107c000 	add	x0, x0, #0x1f0
   80f1c:	f9400000 	ldr	x0, [x0]
   80f20:	f9404000 	ldr	x0, [x0, #128]
   80f24:	f100001f 	cmp	x0, #0x0
   80f28:	5400012c 	b.gt	80f4c <timer_tick+0x70>
		return;
	struct task_struct * prev = current;
	current = next;
   80f2c:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80f30:	9107c000 	add	x0, x0, #0x1f0
   80f34:	f9400000 	ldr	x0, [x0]
   80f38:	f900381f 	str	xzr, [x0, #112]
	cpu_switch_to(prev, next);
   80f3c:	940002f7 	bl	81b18 <enable_irq>
}
   80f40:	97ffff75 	bl	80d14 <_schedule>

   80f44:	940002f7 	bl	81b20 <disable_irq>
   80f48:	14000002 	b	80f50 <timer_tick+0x74>
		return;
   80f4c:	d503201f 	nop
void schedule_tail(void) {
   80f50:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80f54:	d65f03c0 	ret

0000000000080f58 <copy_process>:
#include "mm.h"
#include "sched.h"
#include "entry.h"

int copy_process(unsigned long fn, unsigned long arg)
{
   80f58:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80f5c:	910003fd 	mov	x29, sp
   80f60:	f9000fa0 	str	x0, [x29, #24]
   80f64:	f9000ba1 	str	x1, [x29, #16]
	preempt_disable();
   80f68:	97ffff5b 	bl	80cd4 <preempt_disable>
	struct task_struct *p;

	p = (struct task_struct *) get_free_page();
   80f6c:	97fffeaa 	bl	80a14 <get_free_page>
   80f70:	f90017a0 	str	x0, [x29, #40]
	if (!p)
   80f74:	f94017a0 	ldr	x0, [x29, #40]
   80f78:	f100001f 	cmp	x0, #0x0
   80f7c:	54000061 	b.ne	80f88 <copy_process+0x30>  // b.any
		return 1;
   80f80:	52800020 	mov	w0, #0x1                   	// #1
   80f84:	1400002d 	b	81038 <copy_process+0xe0>
	p->priority = current->priority;
   80f88:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80f8c:	f9409800 	ldr	x0, [x0, #304]
   80f90:	f9400000 	ldr	x0, [x0]
   80f94:	f9403c01 	ldr	x1, [x0, #120]
   80f98:	f94017a0 	ldr	x0, [x29, #40]
   80f9c:	f9003c01 	str	x1, [x0, #120]
	p->state = TASK_RUNNING;
   80fa0:	f94017a0 	ldr	x0, [x29, #40]
   80fa4:	f900341f 	str	xzr, [x0, #104]
	p->counter = p->priority;
   80fa8:	f94017a0 	ldr	x0, [x29, #40]
   80fac:	f9403c01 	ldr	x1, [x0, #120]
   80fb0:	f94017a0 	ldr	x0, [x29, #40]
   80fb4:	f9003801 	str	x1, [x0, #112]
	p->preempt_count = 1; //disable preemtion until schedule_tail
   80fb8:	f94017a0 	ldr	x0, [x29, #40]
   80fbc:	d2800021 	mov	x1, #0x1                   	// #1
   80fc0:	f9004001 	str	x1, [x0, #128]

	p->cpu_context.x19 = fn;
   80fc4:	f94017a0 	ldr	x0, [x29, #40]
   80fc8:	f9400fa1 	ldr	x1, [x29, #24]
   80fcc:	f9000001 	str	x1, [x0]
	p->cpu_context.x20 = arg;
   80fd0:	f94017a0 	ldr	x0, [x29, #40]
   80fd4:	f9400ba1 	ldr	x1, [x29, #16]
   80fd8:	f9000401 	str	x1, [x0, #8]
	p->cpu_context.pc = (unsigned long)ret_from_fork;
   80fdc:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   80fe0:	f940a801 	ldr	x1, [x0, #336]
   80fe4:	f94017a0 	ldr	x0, [x29, #40]
   80fe8:	f9003001 	str	x1, [x0, #96]
	p->cpu_context.sp = (unsigned long)p + THREAD_SIZE;
   80fec:	f94017a0 	ldr	x0, [x29, #40]
   80ff0:	91400401 	add	x1, x0, #0x1, lsl #12
   80ff4:	f94017a0 	ldr	x0, [x29, #40]
   80ff8:	f9002c01 	str	x1, [x0, #88]
	int pid = nr_tasks++;
   80ffc:	f0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   81000:	f9409c00 	ldr	x0, [x0, #312]
   81004:	b9400000 	ldr	w0, [x0]
   81008:	11000402 	add	w2, w0, #0x1
   8100c:	d0000001 	adrp	x1, 83000 <cpu_switch_to+0x1d8>
   81010:	f9409c21 	ldr	x1, [x1, #312]
   81014:	b9000022 	str	w2, [x1]
   81018:	b90027a0 	str	w0, [x29, #36]
	task[pid] = p;	
   8101c:	d0000000 	adrp	x0, 83000 <cpu_switch_to+0x1d8>
   81020:	f940a000 	ldr	x0, [x0, #320]
   81024:	b98027a1 	ldrsw	x1, [x29, #36]
   81028:	f94017a2 	ldr	x2, [x29, #40]
   8102c:	f8217802 	str	x2, [x0, x1, lsl #3]
	preempt_enable();
   81030:	97ffff31 	bl	80cf4 <preempt_enable>
	return 0;
   81034:	52800000 	mov	w0, #0x0                   	// #0
}
   81038:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8103c:	d65f03c0 	ret

0000000000081040 <ui2a>:
    }

#endif

static void ui2a(unsigned int num, unsigned int base, int uc,char * bf)
    {
   81040:	d100c3ff 	sub	sp, sp, #0x30
   81044:	b9001fe0 	str	w0, [sp, #28]
   81048:	b9001be1 	str	w1, [sp, #24]
   8104c:	b90017e2 	str	w2, [sp, #20]
   81050:	f90007e3 	str	x3, [sp, #8]
    int n=0;
   81054:	b9002fff 	str	wzr, [sp, #44]
    unsigned int d=1;
   81058:	52800020 	mov	w0, #0x1                   	// #1
   8105c:	b9002be0 	str	w0, [sp, #40]
    while (num/d >= base)
   81060:	14000005 	b	81074 <ui2a+0x34>
        d*=base;
   81064:	b9402be1 	ldr	w1, [sp, #40]
   81068:	b9401be0 	ldr	w0, [sp, #24]
   8106c:	1b007c20 	mul	w0, w1, w0
   81070:	b9002be0 	str	w0, [sp, #40]
    while (num/d >= base)
   81074:	b9401fe1 	ldr	w1, [sp, #28]
   81078:	b9402be0 	ldr	w0, [sp, #40]
   8107c:	1ac00820 	udiv	w0, w1, w0
   81080:	b9401be1 	ldr	w1, [sp, #24]
   81084:	6b00003f 	cmp	w1, w0
   81088:	54fffee9 	b.ls	81064 <ui2a+0x24>  // b.plast
    while (d!=0) {
   8108c:	1400002f 	b	81148 <ui2a+0x108>
        int dgt = num / d;
   81090:	b9401fe1 	ldr	w1, [sp, #28]
   81094:	b9402be0 	ldr	w0, [sp, #40]
   81098:	1ac00820 	udiv	w0, w1, w0
   8109c:	b90027e0 	str	w0, [sp, #36]
        num%= d;
   810a0:	b9401fe0 	ldr	w0, [sp, #28]
   810a4:	b9402be1 	ldr	w1, [sp, #40]
   810a8:	1ac10802 	udiv	w2, w0, w1
   810ac:	b9402be1 	ldr	w1, [sp, #40]
   810b0:	1b017c41 	mul	w1, w2, w1
   810b4:	4b010000 	sub	w0, w0, w1
   810b8:	b9001fe0 	str	w0, [sp, #28]
        d/=base;
   810bc:	b9402be1 	ldr	w1, [sp, #40]
   810c0:	b9401be0 	ldr	w0, [sp, #24]
   810c4:	1ac00820 	udiv	w0, w1, w0
   810c8:	b9002be0 	str	w0, [sp, #40]
        if (n || dgt>0 || d==0) {
   810cc:	b9402fe0 	ldr	w0, [sp, #44]
   810d0:	7100001f 	cmp	w0, #0x0
   810d4:	540000e1 	b.ne	810f0 <ui2a+0xb0>  // b.any
   810d8:	b94027e0 	ldr	w0, [sp, #36]
   810dc:	7100001f 	cmp	w0, #0x0
   810e0:	5400008c 	b.gt	810f0 <ui2a+0xb0>
   810e4:	b9402be0 	ldr	w0, [sp, #40]
   810e8:	7100001f 	cmp	w0, #0x0
   810ec:	540002e1 	b.ne	81148 <ui2a+0x108>  // b.any
            *bf++ = dgt+(dgt<10 ? '0' : (uc ? 'A' : 'a')-10);
   810f0:	b94027e0 	ldr	w0, [sp, #36]
   810f4:	7100241f 	cmp	w0, #0x9
   810f8:	5400010d 	b.le	81118 <ui2a+0xd8>
   810fc:	b94017e0 	ldr	w0, [sp, #20]
   81100:	7100001f 	cmp	w0, #0x0
   81104:	54000060 	b.eq	81110 <ui2a+0xd0>  // b.none
   81108:	528006e0 	mov	w0, #0x37                  	// #55
   8110c:	14000004 	b	8111c <ui2a+0xdc>
   81110:	52800ae0 	mov	w0, #0x57                  	// #87
   81114:	14000002 	b	8111c <ui2a+0xdc>
   81118:	52800600 	mov	w0, #0x30                  	// #48
   8111c:	b94027e1 	ldr	w1, [sp, #36]
   81120:	12001c22 	and	w2, w1, #0xff
   81124:	f94007e1 	ldr	x1, [sp, #8]
   81128:	91000423 	add	x3, x1, #0x1
   8112c:	f90007e3 	str	x3, [sp, #8]
   81130:	0b020000 	add	w0, w0, w2
   81134:	12001c00 	and	w0, w0, #0xff
   81138:	39000020 	strb	w0, [x1]
            ++n;
   8113c:	b9402fe0 	ldr	w0, [sp, #44]
   81140:	11000400 	add	w0, w0, #0x1
   81144:	b9002fe0 	str	w0, [sp, #44]
    while (d!=0) {
   81148:	b9402be0 	ldr	w0, [sp, #40]
   8114c:	7100001f 	cmp	w0, #0x0
   81150:	54fffa01 	b.ne	81090 <ui2a+0x50>  // b.any
            }
        }
    *bf=0;
   81154:	f94007e0 	ldr	x0, [sp, #8]
   81158:	3900001f 	strb	wzr, [x0]
    }
   8115c:	d503201f 	nop
   81160:	9100c3ff 	add	sp, sp, #0x30
   81164:	d65f03c0 	ret

0000000000081168 <i2a>:

static void i2a (int num, char * bf)
    {
   81168:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8116c:	910003fd 	mov	x29, sp
   81170:	b9001fa0 	str	w0, [x29, #28]
   81174:	f9000ba1 	str	x1, [x29, #16]
    if (num<0) {
   81178:	b9401fa0 	ldr	w0, [x29, #28]
   8117c:	7100001f 	cmp	w0, #0x0
   81180:	5400012a 	b.ge	811a4 <i2a+0x3c>  // b.tcont
        num=-num;
   81184:	b9401fa0 	ldr	w0, [x29, #28]
   81188:	4b0003e0 	neg	w0, w0
   8118c:	b9001fa0 	str	w0, [x29, #28]
        *bf++ = '-';
   81190:	f9400ba0 	ldr	x0, [x29, #16]
   81194:	91000401 	add	x1, x0, #0x1
   81198:	f9000ba1 	str	x1, [x29, #16]
   8119c:	528005a1 	mov	w1, #0x2d                  	// #45
   811a0:	39000001 	strb	w1, [x0]
        }
    ui2a(num,10,0,bf);
   811a4:	b9401fa0 	ldr	w0, [x29, #28]
   811a8:	f9400ba3 	ldr	x3, [x29, #16]
   811ac:	52800002 	mov	w2, #0x0                   	// #0
   811b0:	52800141 	mov	w1, #0xa                   	// #10
   811b4:	97ffffa3 	bl	81040 <ui2a>
    }
   811b8:	d503201f 	nop
   811bc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   811c0:	d65f03c0 	ret

00000000000811c4 <a2d>:

static int a2d(char ch)
    {
   811c4:	d10043ff 	sub	sp, sp, #0x10
   811c8:	39003fe0 	strb	w0, [sp, #15]
    if (ch>='0' && ch<='9')
   811cc:	39403fe0 	ldrb	w0, [sp, #15]
   811d0:	7100bc1f 	cmp	w0, #0x2f
   811d4:	540000e9 	b.ls	811f0 <a2d+0x2c>  // b.plast
   811d8:	39403fe0 	ldrb	w0, [sp, #15]
   811dc:	7100e41f 	cmp	w0, #0x39
   811e0:	54000088 	b.hi	811f0 <a2d+0x2c>  // b.pmore
        return ch-'0';
   811e4:	39403fe0 	ldrb	w0, [sp, #15]
   811e8:	5100c000 	sub	w0, w0, #0x30
   811ec:	14000014 	b	8123c <a2d+0x78>
    else if (ch>='a' && ch<='f')
   811f0:	39403fe0 	ldrb	w0, [sp, #15]
   811f4:	7101801f 	cmp	w0, #0x60
   811f8:	540000e9 	b.ls	81214 <a2d+0x50>  // b.plast
   811fc:	39403fe0 	ldrb	w0, [sp, #15]
   81200:	7101981f 	cmp	w0, #0x66
   81204:	54000088 	b.hi	81214 <a2d+0x50>  // b.pmore
        return ch-'a'+10;
   81208:	39403fe0 	ldrb	w0, [sp, #15]
   8120c:	51015c00 	sub	w0, w0, #0x57
   81210:	1400000b 	b	8123c <a2d+0x78>
    else if (ch>='A' && ch<='F')
   81214:	39403fe0 	ldrb	w0, [sp, #15]
   81218:	7101001f 	cmp	w0, #0x40
   8121c:	540000e9 	b.ls	81238 <a2d+0x74>  // b.plast
   81220:	39403fe0 	ldrb	w0, [sp, #15]
   81224:	7101181f 	cmp	w0, #0x46
   81228:	54000088 	b.hi	81238 <a2d+0x74>  // b.pmore
        return ch-'A'+10;
   8122c:	39403fe0 	ldrb	w0, [sp, #15]
   81230:	5100dc00 	sub	w0, w0, #0x37
   81234:	14000002 	b	8123c <a2d+0x78>
    else return -1;
   81238:	12800000 	mov	w0, #0xffffffff            	// #-1
    }
   8123c:	910043ff 	add	sp, sp, #0x10
   81240:	d65f03c0 	ret

0000000000081244 <a2i>:

static char a2i(char ch, char** src,int base,int* nump)
    {
   81244:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   81248:	910003fd 	mov	x29, sp
   8124c:	3900bfa0 	strb	w0, [x29, #47]
   81250:	f90013a1 	str	x1, [x29, #32]
   81254:	b9002ba2 	str	w2, [x29, #40]
   81258:	f9000fa3 	str	x3, [x29, #24]
    char* p= *src;
   8125c:	f94013a0 	ldr	x0, [x29, #32]
   81260:	f9400000 	ldr	x0, [x0]
   81264:	f9001fa0 	str	x0, [x29, #56]
    int num=0;
   81268:	b90037bf 	str	wzr, [x29, #52]
    int digit;
    while ((digit=a2d(ch))>=0) {
   8126c:	14000010 	b	812ac <a2i+0x68>
        if (digit>base) break;
   81270:	b94033a1 	ldr	w1, [x29, #48]
   81274:	b9402ba0 	ldr	w0, [x29, #40]
   81278:	6b00003f 	cmp	w1, w0
   8127c:	5400026c 	b.gt	812c8 <a2i+0x84>
        num=num*base+digit;
   81280:	b94037a1 	ldr	w1, [x29, #52]
   81284:	b9402ba0 	ldr	w0, [x29, #40]
   81288:	1b007c20 	mul	w0, w1, w0
   8128c:	b94033a1 	ldr	w1, [x29, #48]
   81290:	0b000020 	add	w0, w1, w0
   81294:	b90037a0 	str	w0, [x29, #52]
        ch=*p++;
   81298:	f9401fa0 	ldr	x0, [x29, #56]
   8129c:	91000401 	add	x1, x0, #0x1
   812a0:	f9001fa1 	str	x1, [x29, #56]
   812a4:	39400000 	ldrb	w0, [x0]
   812a8:	3900bfa0 	strb	w0, [x29, #47]
    while ((digit=a2d(ch))>=0) {
   812ac:	3940bfa0 	ldrb	w0, [x29, #47]
   812b0:	97ffffc5 	bl	811c4 <a2d>
   812b4:	b90033a0 	str	w0, [x29, #48]
   812b8:	b94033a0 	ldr	w0, [x29, #48]
   812bc:	7100001f 	cmp	w0, #0x0
   812c0:	54fffd8a 	b.ge	81270 <a2i+0x2c>  // b.tcont
   812c4:	14000002 	b	812cc <a2i+0x88>
        if (digit>base) break;
   812c8:	d503201f 	nop
        }
    *src=p;
   812cc:	f94013a0 	ldr	x0, [x29, #32]
   812d0:	f9401fa1 	ldr	x1, [x29, #56]
   812d4:	f9000001 	str	x1, [x0]
    *nump=num;
   812d8:	f9400fa0 	ldr	x0, [x29, #24]
   812dc:	b94037a1 	ldr	w1, [x29, #52]
   812e0:	b9000001 	str	w1, [x0]
    return ch;
   812e4:	3940bfa0 	ldrb	w0, [x29, #47]
    }
   812e8:	a8c47bfd 	ldp	x29, x30, [sp], #64
   812ec:	d65f03c0 	ret

00000000000812f0 <putchw>:

static void putchw(void* putp,putcf putf,int n, char z, char* bf)
    {
   812f0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   812f4:	910003fd 	mov	x29, sp
   812f8:	f90017a0 	str	x0, [x29, #40]
   812fc:	f90013a1 	str	x1, [x29, #32]
   81300:	b9001fa2 	str	w2, [x29, #28]
   81304:	39006fa3 	strb	w3, [x29, #27]
   81308:	f9000ba4 	str	x4, [x29, #16]
    char fc=z? '0' : ' ';
   8130c:	39406fa0 	ldrb	w0, [x29, #27]
   81310:	7100001f 	cmp	w0, #0x0
   81314:	54000060 	b.eq	81320 <putchw+0x30>  // b.none
   81318:	52800600 	mov	w0, #0x30                  	// #48
   8131c:	14000002 	b	81324 <putchw+0x34>
   81320:	52800400 	mov	w0, #0x20                  	// #32
   81324:	3900dfa0 	strb	w0, [x29, #55]
    char ch;
    char* p=bf;
   81328:	f9400ba0 	ldr	x0, [x29, #16]
   8132c:	f9001fa0 	str	x0, [x29, #56]
    while (*p++ && n > 0)
   81330:	14000004 	b	81340 <putchw+0x50>
        n--;
   81334:	b9401fa0 	ldr	w0, [x29, #28]
   81338:	51000400 	sub	w0, w0, #0x1
   8133c:	b9001fa0 	str	w0, [x29, #28]
    while (*p++ && n > 0)
   81340:	f9401fa0 	ldr	x0, [x29, #56]
   81344:	91000401 	add	x1, x0, #0x1
   81348:	f9001fa1 	str	x1, [x29, #56]
   8134c:	39400000 	ldrb	w0, [x0]
   81350:	7100001f 	cmp	w0, #0x0
   81354:	54000120 	b.eq	81378 <putchw+0x88>  // b.none
   81358:	b9401fa0 	ldr	w0, [x29, #28]
   8135c:	7100001f 	cmp	w0, #0x0
   81360:	54fffeac 	b.gt	81334 <putchw+0x44>
    while (n-- > 0)
   81364:	14000005 	b	81378 <putchw+0x88>
        putf(putp,fc);
   81368:	f94013a2 	ldr	x2, [x29, #32]
   8136c:	3940dfa1 	ldrb	w1, [x29, #55]
   81370:	f94017a0 	ldr	x0, [x29, #40]
   81374:	d63f0040 	blr	x2
    while (n-- > 0)
   81378:	b9401fa0 	ldr	w0, [x29, #28]
   8137c:	51000401 	sub	w1, w0, #0x1
   81380:	b9001fa1 	str	w1, [x29, #28]
   81384:	7100001f 	cmp	w0, #0x0
   81388:	54ffff0c 	b.gt	81368 <putchw+0x78>
    while ((ch= *bf++))
   8138c:	14000005 	b	813a0 <putchw+0xb0>
        putf(putp,ch);
   81390:	f94013a2 	ldr	x2, [x29, #32]
   81394:	3940dba1 	ldrb	w1, [x29, #54]
   81398:	f94017a0 	ldr	x0, [x29, #40]
   8139c:	d63f0040 	blr	x2
    while ((ch= *bf++))
   813a0:	f9400ba0 	ldr	x0, [x29, #16]
   813a4:	91000401 	add	x1, x0, #0x1
   813a8:	f9000ba1 	str	x1, [x29, #16]
   813ac:	39400000 	ldrb	w0, [x0]
   813b0:	3900dba0 	strb	w0, [x29, #54]
   813b4:	3940dba0 	ldrb	w0, [x29, #54]
   813b8:	7100001f 	cmp	w0, #0x0
   813bc:	54fffea1 	b.ne	81390 <putchw+0xa0>  // b.any
    }
   813c0:	d503201f 	nop
   813c4:	a8c47bfd 	ldp	x29, x30, [sp], #64
   813c8:	d65f03c0 	ret

00000000000813cc <tfp_format>:

void tfp_format(void* putp,putcf putf,char *fmt, va_list va)
    {
   813cc:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   813d0:	910003fd 	mov	x29, sp
   813d4:	f9000bf3 	str	x19, [sp, #16]
   813d8:	f9001fa0 	str	x0, [x29, #56]
   813dc:	f9001ba1 	str	x1, [x29, #48]
   813e0:	f90017a2 	str	x2, [x29, #40]
   813e4:	aa0303f3 	mov	x19, x3
    char bf[12];

    char ch;


    while ((ch=*(fmt++))) {
   813e8:	140000fd 	b	817dc <tfp_format+0x410>
        if (ch!='%')
   813ec:	39417fa0 	ldrb	w0, [x29, #95]
   813f0:	7100941f 	cmp	w0, #0x25
   813f4:	540000c0 	b.eq	8140c <tfp_format+0x40>  // b.none
            putf(putp,ch);
   813f8:	f9401ba2 	ldr	x2, [x29, #48]
   813fc:	39417fa1 	ldrb	w1, [x29, #95]
   81400:	f9401fa0 	ldr	x0, [x29, #56]
   81404:	d63f0040 	blr	x2
   81408:	140000f5 	b	817dc <tfp_format+0x410>
        else {
            char lz=0;
   8140c:	39017bbf 	strb	wzr, [x29, #94]
#ifdef  PRINTF_LONG_SUPPORT
            char lng=0;
#endif
            int w=0;
   81410:	b9004fbf 	str	wzr, [x29, #76]
            ch=*(fmt++);
   81414:	f94017a0 	ldr	x0, [x29, #40]
   81418:	91000401 	add	x1, x0, #0x1
   8141c:	f90017a1 	str	x1, [x29, #40]
   81420:	39400000 	ldrb	w0, [x0]
   81424:	39017fa0 	strb	w0, [x29, #95]
            if (ch=='0') {
   81428:	39417fa0 	ldrb	w0, [x29, #95]
   8142c:	7100c01f 	cmp	w0, #0x30
   81430:	54000101 	b.ne	81450 <tfp_format+0x84>  // b.any
                ch=*(fmt++);
   81434:	f94017a0 	ldr	x0, [x29, #40]
   81438:	91000401 	add	x1, x0, #0x1
   8143c:	f90017a1 	str	x1, [x29, #40]
   81440:	39400000 	ldrb	w0, [x0]
   81444:	39017fa0 	strb	w0, [x29, #95]
                lz=1;
   81448:	52800020 	mov	w0, #0x1                   	// #1
   8144c:	39017ba0 	strb	w0, [x29, #94]
                }
            if (ch>='0' && ch<='9') {
   81450:	39417fa0 	ldrb	w0, [x29, #95]
   81454:	7100bc1f 	cmp	w0, #0x2f
   81458:	54000189 	b.ls	81488 <tfp_format+0xbc>  // b.plast
   8145c:	39417fa0 	ldrb	w0, [x29, #95]
   81460:	7100e41f 	cmp	w0, #0x39
   81464:	54000128 	b.hi	81488 <tfp_format+0xbc>  // b.pmore
                ch=a2i(ch,&fmt,10,&w);
   81468:	910133a1 	add	x1, x29, #0x4c
   8146c:	9100a3a0 	add	x0, x29, #0x28
   81470:	aa0103e3 	mov	x3, x1
   81474:	52800142 	mov	w2, #0xa                   	// #10
   81478:	aa0003e1 	mov	x1, x0
   8147c:	39417fa0 	ldrb	w0, [x29, #95]
   81480:	97ffff71 	bl	81244 <a2i>
   81484:	39017fa0 	strb	w0, [x29, #95]
            if (ch=='l') {
                ch=*(fmt++);
                lng=1;
            }
#endif
            switch (ch) {
   81488:	39417fa0 	ldrb	w0, [x29, #95]
   8148c:	71018c1f 	cmp	w0, #0x63
   81490:	540011c0 	b.eq	816c8 <tfp_format+0x2fc>  // b.none
   81494:	71018c1f 	cmp	w0, #0x63
   81498:	5400010c 	b.gt	814b8 <tfp_format+0xec>
   8149c:	7100941f 	cmp	w0, #0x25
   814a0:	54001940 	b.eq	817c8 <tfp_format+0x3fc>  // b.none
   814a4:	7101601f 	cmp	w0, #0x58
   814a8:	54000b60 	b.eq	81614 <tfp_format+0x248>  // b.none
   814ac:	7100001f 	cmp	w0, #0x0
   814b0:	54001a80 	b.eq	81800 <tfp_format+0x434>  // b.none
                    putchw(putp,putf,w,0,va_arg(va, char*));
                    break;
                case '%' :
                    putf(putp,ch);
                default:
                    break;
   814b4:	140000c9 	b	817d8 <tfp_format+0x40c>
            switch (ch) {
   814b8:	7101cc1f 	cmp	w0, #0x73
   814bc:	54001440 	b.eq	81744 <tfp_format+0x378>  // b.none
   814c0:	7101cc1f 	cmp	w0, #0x73
   814c4:	5400008c 	b.gt	814d4 <tfp_format+0x108>
   814c8:	7101901f 	cmp	w0, #0x64
   814cc:	540005c0 	b.eq	81584 <tfp_format+0x1b8>  // b.none
                    break;
   814d0:	140000c2 	b	817d8 <tfp_format+0x40c>
            switch (ch) {
   814d4:	7101d41f 	cmp	w0, #0x75
   814d8:	54000080 	b.eq	814e8 <tfp_format+0x11c>  // b.none
   814dc:	7101e01f 	cmp	w0, #0x78
   814e0:	540009a0 	b.eq	81614 <tfp_format+0x248>  // b.none
                    break;
   814e4:	140000bd 	b	817d8 <tfp_format+0x40c>
                    ui2a(va_arg(va, unsigned int),10,0,bf);
   814e8:	b9401a60 	ldr	w0, [x19, #24]
   814ec:	f9400261 	ldr	x1, [x19]
   814f0:	7100001f 	cmp	w0, #0x0
   814f4:	540000eb 	b.lt	81510 <tfp_format+0x144>  // b.tstop
   814f8:	aa0103e0 	mov	x0, x1
   814fc:	91002c00 	add	x0, x0, #0xb
   81500:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81504:	f9000260 	str	x0, [x19]
   81508:	aa0103e0 	mov	x0, x1
   8150c:	1400000f 	b	81548 <tfp_format+0x17c>
   81510:	11002002 	add	w2, w0, #0x8
   81514:	b9001a62 	str	w2, [x19, #24]
   81518:	b9401a62 	ldr	w2, [x19, #24]
   8151c:	7100005f 	cmp	w2, #0x0
   81520:	540000ed 	b.le	8153c <tfp_format+0x170>
   81524:	aa0103e0 	mov	x0, x1
   81528:	91002c00 	add	x0, x0, #0xb
   8152c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81530:	f9000260 	str	x0, [x19]
   81534:	aa0103e0 	mov	x0, x1
   81538:	14000004 	b	81548 <tfp_format+0x17c>
   8153c:	f9400661 	ldr	x1, [x19, #8]
   81540:	93407c00 	sxtw	x0, w0
   81544:	8b000020 	add	x0, x1, x0
   81548:	b9400000 	ldr	w0, [x0]
   8154c:	910143a1 	add	x1, x29, #0x50
   81550:	aa0103e3 	mov	x3, x1
   81554:	52800002 	mov	w2, #0x0                   	// #0
   81558:	52800141 	mov	w1, #0xa                   	// #10
   8155c:	97fffeb9 	bl	81040 <ui2a>
                    putchw(putp,putf,w,lz,bf);
   81560:	b9404fa0 	ldr	w0, [x29, #76]
   81564:	910143a1 	add	x1, x29, #0x50
   81568:	aa0103e4 	mov	x4, x1
   8156c:	39417ba3 	ldrb	w3, [x29, #94]
   81570:	2a0003e2 	mov	w2, w0
   81574:	f9401ba1 	ldr	x1, [x29, #48]
   81578:	f9401fa0 	ldr	x0, [x29, #56]
   8157c:	97ffff5d 	bl	812f0 <putchw>
                    break;
   81580:	14000097 	b	817dc <tfp_format+0x410>
                    i2a(va_arg(va, int),bf);
   81584:	b9401a60 	ldr	w0, [x19, #24]
   81588:	f9400261 	ldr	x1, [x19]
   8158c:	7100001f 	cmp	w0, #0x0
   81590:	540000eb 	b.lt	815ac <tfp_format+0x1e0>  // b.tstop
   81594:	aa0103e0 	mov	x0, x1
   81598:	91002c00 	add	x0, x0, #0xb
   8159c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   815a0:	f9000260 	str	x0, [x19]
   815a4:	aa0103e0 	mov	x0, x1
   815a8:	1400000f 	b	815e4 <tfp_format+0x218>
   815ac:	11002002 	add	w2, w0, #0x8
   815b0:	b9001a62 	str	w2, [x19, #24]
   815b4:	b9401a62 	ldr	w2, [x19, #24]
   815b8:	7100005f 	cmp	w2, #0x0
   815bc:	540000ed 	b.le	815d8 <tfp_format+0x20c>
   815c0:	aa0103e0 	mov	x0, x1
   815c4:	91002c00 	add	x0, x0, #0xb
   815c8:	927df000 	and	x0, x0, #0xfffffffffffffff8
   815cc:	f9000260 	str	x0, [x19]
   815d0:	aa0103e0 	mov	x0, x1
   815d4:	14000004 	b	815e4 <tfp_format+0x218>
   815d8:	f9400661 	ldr	x1, [x19, #8]
   815dc:	93407c00 	sxtw	x0, w0
   815e0:	8b000020 	add	x0, x1, x0
   815e4:	b9400000 	ldr	w0, [x0]
   815e8:	910143a1 	add	x1, x29, #0x50
   815ec:	97fffedf 	bl	81168 <i2a>
                    putchw(putp,putf,w,lz,bf);
   815f0:	b9404fa0 	ldr	w0, [x29, #76]
   815f4:	910143a1 	add	x1, x29, #0x50
   815f8:	aa0103e4 	mov	x4, x1
   815fc:	39417ba3 	ldrb	w3, [x29, #94]
   81600:	2a0003e2 	mov	w2, w0
   81604:	f9401ba1 	ldr	x1, [x29, #48]
   81608:	f9401fa0 	ldr	x0, [x29, #56]
   8160c:	97ffff39 	bl	812f0 <putchw>
                    break;
   81610:	14000073 	b	817dc <tfp_format+0x410>
                    ui2a(va_arg(va, unsigned int),16,(ch=='X'),bf);
   81614:	b9401a60 	ldr	w0, [x19, #24]
   81618:	f9400261 	ldr	x1, [x19]
   8161c:	7100001f 	cmp	w0, #0x0
   81620:	540000eb 	b.lt	8163c <tfp_format+0x270>  // b.tstop
   81624:	aa0103e0 	mov	x0, x1
   81628:	91002c00 	add	x0, x0, #0xb
   8162c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81630:	f9000260 	str	x0, [x19]
   81634:	aa0103e0 	mov	x0, x1
   81638:	1400000f 	b	81674 <tfp_format+0x2a8>
   8163c:	11002002 	add	w2, w0, #0x8
   81640:	b9001a62 	str	w2, [x19, #24]
   81644:	b9401a62 	ldr	w2, [x19, #24]
   81648:	7100005f 	cmp	w2, #0x0
   8164c:	540000ed 	b.le	81668 <tfp_format+0x29c>
   81650:	aa0103e0 	mov	x0, x1
   81654:	91002c00 	add	x0, x0, #0xb
   81658:	927df000 	and	x0, x0, #0xfffffffffffffff8
   8165c:	f9000260 	str	x0, [x19]
   81660:	aa0103e0 	mov	x0, x1
   81664:	14000004 	b	81674 <tfp_format+0x2a8>
   81668:	f9400661 	ldr	x1, [x19, #8]
   8166c:	93407c00 	sxtw	x0, w0
   81670:	8b000020 	add	x0, x1, x0
   81674:	b9400004 	ldr	w4, [x0]
   81678:	39417fa0 	ldrb	w0, [x29, #95]
   8167c:	7101601f 	cmp	w0, #0x58
   81680:	1a9f17e0 	cset	w0, eq  // eq = none
   81684:	12001c00 	and	w0, w0, #0xff
   81688:	2a0003e1 	mov	w1, w0
   8168c:	910143a0 	add	x0, x29, #0x50
   81690:	aa0003e3 	mov	x3, x0
   81694:	2a0103e2 	mov	w2, w1
   81698:	52800201 	mov	w1, #0x10                  	// #16
   8169c:	2a0403e0 	mov	w0, w4
   816a0:	97fffe68 	bl	81040 <ui2a>
                    putchw(putp,putf,w,lz,bf);
   816a4:	b9404fa0 	ldr	w0, [x29, #76]
   816a8:	910143a1 	add	x1, x29, #0x50
   816ac:	aa0103e4 	mov	x4, x1
   816b0:	39417ba3 	ldrb	w3, [x29, #94]
   816b4:	2a0003e2 	mov	w2, w0
   816b8:	f9401ba1 	ldr	x1, [x29, #48]
   816bc:	f9401fa0 	ldr	x0, [x29, #56]
   816c0:	97ffff0c 	bl	812f0 <putchw>
                    break;
   816c4:	14000046 	b	817dc <tfp_format+0x410>
                    putf(putp,(char)(va_arg(va, int)));
   816c8:	b9401a60 	ldr	w0, [x19, #24]
   816cc:	f9400261 	ldr	x1, [x19]
   816d0:	7100001f 	cmp	w0, #0x0
   816d4:	540000eb 	b.lt	816f0 <tfp_format+0x324>  // b.tstop
   816d8:	aa0103e0 	mov	x0, x1
   816dc:	91002c00 	add	x0, x0, #0xb
   816e0:	927df000 	and	x0, x0, #0xfffffffffffffff8
   816e4:	f9000260 	str	x0, [x19]
   816e8:	aa0103e0 	mov	x0, x1
   816ec:	1400000f 	b	81728 <tfp_format+0x35c>
   816f0:	11002002 	add	w2, w0, #0x8
   816f4:	b9001a62 	str	w2, [x19, #24]
   816f8:	b9401a62 	ldr	w2, [x19, #24]
   816fc:	7100005f 	cmp	w2, #0x0
   81700:	540000ed 	b.le	8171c <tfp_format+0x350>
   81704:	aa0103e0 	mov	x0, x1
   81708:	91002c00 	add	x0, x0, #0xb
   8170c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81710:	f9000260 	str	x0, [x19]
   81714:	aa0103e0 	mov	x0, x1
   81718:	14000004 	b	81728 <tfp_format+0x35c>
   8171c:	f9400661 	ldr	x1, [x19, #8]
   81720:	93407c00 	sxtw	x0, w0
   81724:	8b000020 	add	x0, x1, x0
   81728:	b9400000 	ldr	w0, [x0]
   8172c:	12001c00 	and	w0, w0, #0xff
   81730:	f9401ba2 	ldr	x2, [x29, #48]
   81734:	2a0003e1 	mov	w1, w0
   81738:	f9401fa0 	ldr	x0, [x29, #56]
   8173c:	d63f0040 	blr	x2
                    break;
   81740:	14000027 	b	817dc <tfp_format+0x410>
                    putchw(putp,putf,w,0,va_arg(va, char*));
   81744:	b9404fa5 	ldr	w5, [x29, #76]
   81748:	b9401a60 	ldr	w0, [x19, #24]
   8174c:	f9400261 	ldr	x1, [x19]
   81750:	7100001f 	cmp	w0, #0x0
   81754:	540000eb 	b.lt	81770 <tfp_format+0x3a4>  // b.tstop
   81758:	aa0103e0 	mov	x0, x1
   8175c:	91003c00 	add	x0, x0, #0xf
   81760:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81764:	f9000260 	str	x0, [x19]
   81768:	aa0103e0 	mov	x0, x1
   8176c:	1400000f 	b	817a8 <tfp_format+0x3dc>
   81770:	11002002 	add	w2, w0, #0x8
   81774:	b9001a62 	str	w2, [x19, #24]
   81778:	b9401a62 	ldr	w2, [x19, #24]
   8177c:	7100005f 	cmp	w2, #0x0
   81780:	540000ed 	b.le	8179c <tfp_format+0x3d0>
   81784:	aa0103e0 	mov	x0, x1
   81788:	91003c00 	add	x0, x0, #0xf
   8178c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   81790:	f9000260 	str	x0, [x19]
   81794:	aa0103e0 	mov	x0, x1
   81798:	14000004 	b	817a8 <tfp_format+0x3dc>
   8179c:	f9400661 	ldr	x1, [x19, #8]
   817a0:	93407c00 	sxtw	x0, w0
   817a4:	8b000020 	add	x0, x1, x0
   817a8:	f9400000 	ldr	x0, [x0]
   817ac:	aa0003e4 	mov	x4, x0
   817b0:	52800003 	mov	w3, #0x0                   	// #0
   817b4:	2a0503e2 	mov	w2, w5
   817b8:	f9401ba1 	ldr	x1, [x29, #48]
   817bc:	f9401fa0 	ldr	x0, [x29, #56]
   817c0:	97fffecc 	bl	812f0 <putchw>
                    break;
   817c4:	14000006 	b	817dc <tfp_format+0x410>
                    putf(putp,ch);
   817c8:	f9401ba2 	ldr	x2, [x29, #48]
   817cc:	39417fa1 	ldrb	w1, [x29, #95]
   817d0:	f9401fa0 	ldr	x0, [x29, #56]
   817d4:	d63f0040 	blr	x2
                    break;
   817d8:	d503201f 	nop
    while ((ch=*(fmt++))) {
   817dc:	f94017a0 	ldr	x0, [x29, #40]
   817e0:	91000401 	add	x1, x0, #0x1
   817e4:	f90017a1 	str	x1, [x29, #40]
   817e8:	39400000 	ldrb	w0, [x0]
   817ec:	39017fa0 	strb	w0, [x29, #95]
   817f0:	39417fa0 	ldrb	w0, [x29, #95]
   817f4:	7100001f 	cmp	w0, #0x0
   817f8:	54ffdfa1 	b.ne	813ec <tfp_format+0x20>  // b.any
                }
            }
        }
    abort:;
   817fc:	14000002 	b	81804 <tfp_format+0x438>
                    goto abort;
   81800:	d503201f 	nop
    }
   81804:	d503201f 	nop
   81808:	f9400bf3 	ldr	x19, [sp, #16]
   8180c:	a8c67bfd 	ldp	x29, x30, [sp], #96
   81810:	d65f03c0 	ret

0000000000081814 <init_printf>:


void init_printf(void* putp,void (*putf) (void*,char))
    {
   81814:	d10043ff 	sub	sp, sp, #0x10
   81818:	f90007e0 	str	x0, [sp, #8]
   8181c:	f90003e1 	str	x1, [sp]
    stdout_putf=putf;
   81820:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81824:	912fe000 	add	x0, x0, #0xbf8
   81828:	f94003e1 	ldr	x1, [sp]
   8182c:	f9000001 	str	x1, [x0]
    stdout_putp=putp;
   81830:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81834:	91300000 	add	x0, x0, #0xc00
   81838:	f94007e1 	ldr	x1, [sp, #8]
   8183c:	f9000001 	str	x1, [x0]
    }
   81840:	d503201f 	nop
   81844:	910043ff 	add	sp, sp, #0x10
   81848:	d65f03c0 	ret

000000000008184c <tfp_printf>:

void tfp_printf(char *fmt, ...)
    {
   8184c:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
   81850:	910003fd 	mov	x29, sp
   81854:	f9001fa0 	str	x0, [x29, #56]
   81858:	f90037a1 	str	x1, [x29, #104]
   8185c:	f9003ba2 	str	x2, [x29, #112]
   81860:	f9003fa3 	str	x3, [x29, #120]
   81864:	f90043a4 	str	x4, [x29, #128]
   81868:	f90047a5 	str	x5, [x29, #136]
   8186c:	f9004ba6 	str	x6, [x29, #144]
   81870:	f9004fa7 	str	x7, [x29, #152]
    va_list va;
    va_start(va,fmt);
   81874:	910283a0 	add	x0, x29, #0xa0
   81878:	f90023a0 	str	x0, [x29, #64]
   8187c:	910283a0 	add	x0, x29, #0xa0
   81880:	f90027a0 	str	x0, [x29, #72]
   81884:	910183a0 	add	x0, x29, #0x60
   81888:	f9002ba0 	str	x0, [x29, #80]
   8188c:	128006e0 	mov	w0, #0xffffffc8            	// #-56
   81890:	b9005ba0 	str	w0, [x29, #88]
   81894:	b9005fbf 	str	wzr, [x29, #92]
    tfp_format(stdout_putp,stdout_putf,fmt,va);
   81898:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   8189c:	91300000 	add	x0, x0, #0xc00
   818a0:	f9400004 	ldr	x4, [x0]
   818a4:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   818a8:	912fe000 	add	x0, x0, #0xbf8
   818ac:	f9400005 	ldr	x5, [x0]
   818b0:	910043a2 	add	x2, x29, #0x10
   818b4:	910103a3 	add	x3, x29, #0x40
   818b8:	a9400460 	ldp	x0, x1, [x3]
   818bc:	a9000440 	stp	x0, x1, [x2]
   818c0:	a9410460 	ldp	x0, x1, [x3, #16]
   818c4:	a9010440 	stp	x0, x1, [x2, #16]
   818c8:	910043a0 	add	x0, x29, #0x10
   818cc:	aa0003e3 	mov	x3, x0
   818d0:	f9401fa2 	ldr	x2, [x29, #56]
   818d4:	aa0503e1 	mov	x1, x5
   818d8:	aa0403e0 	mov	x0, x4
   818dc:	97fffebc 	bl	813cc <tfp_format>
    va_end(va);
    }
   818e0:	d503201f 	nop
   818e4:	a8ca7bfd 	ldp	x29, x30, [sp], #160
   818e8:	d65f03c0 	ret

00000000000818ec <putcp>:

static void putcp(void* p,char c)
    {
   818ec:	d10043ff 	sub	sp, sp, #0x10
   818f0:	f90007e0 	str	x0, [sp, #8]
   818f4:	39001fe1 	strb	w1, [sp, #7]
    *(*((char**)p))++ = c;
   818f8:	f94007e0 	ldr	x0, [sp, #8]
   818fc:	f9400000 	ldr	x0, [x0]
   81900:	91000402 	add	x2, x0, #0x1
   81904:	f94007e1 	ldr	x1, [sp, #8]
   81908:	f9000022 	str	x2, [x1]
   8190c:	39401fe1 	ldrb	w1, [sp, #7]
   81910:	39000001 	strb	w1, [x0]
    }
   81914:	d503201f 	nop
   81918:	910043ff 	add	sp, sp, #0x10
   8191c:	d65f03c0 	ret

0000000000081920 <tfp_sprintf>:



void tfp_sprintf(char* s,char *fmt, ...)
    {
   81920:	a9b77bfd 	stp	x29, x30, [sp, #-144]!
   81924:	910003fd 	mov	x29, sp
   81928:	f9001fa0 	str	x0, [x29, #56]
   8192c:	f9001ba1 	str	x1, [x29, #48]
   81930:	f90033a2 	str	x2, [x29, #96]
   81934:	f90037a3 	str	x3, [x29, #104]
   81938:	f9003ba4 	str	x4, [x29, #112]
   8193c:	f9003fa5 	str	x5, [x29, #120]
   81940:	f90043a6 	str	x6, [x29, #128]
   81944:	f90047a7 	str	x7, [x29, #136]
    va_list va;
    va_start(va,fmt);
   81948:	910243a0 	add	x0, x29, #0x90
   8194c:	f90023a0 	str	x0, [x29, #64]
   81950:	910243a0 	add	x0, x29, #0x90
   81954:	f90027a0 	str	x0, [x29, #72]
   81958:	910183a0 	add	x0, x29, #0x60
   8195c:	f9002ba0 	str	x0, [x29, #80]
   81960:	128005e0 	mov	w0, #0xffffffd0            	// #-48
   81964:	b9005ba0 	str	w0, [x29, #88]
   81968:	b9005fbf 	str	wzr, [x29, #92]
    tfp_format(&s,putcp,fmt,va);
   8196c:	910043a2 	add	x2, x29, #0x10
   81970:	910103a3 	add	x3, x29, #0x40
   81974:	a9400460 	ldp	x0, x1, [x3]
   81978:	a9000440 	stp	x0, x1, [x2]
   8197c:	a9410460 	ldp	x0, x1, [x3, #16]
   81980:	a9010440 	stp	x0, x1, [x2, #16]
   81984:	910043a2 	add	x2, x29, #0x10
   81988:	90000000 	adrp	x0, 81000 <copy_process+0xa8>
   8198c:	9123b001 	add	x1, x0, #0x8ec
   81990:	9100e3a0 	add	x0, x29, #0x38
   81994:	aa0203e3 	mov	x3, x2
   81998:	f9401ba2 	ldr	x2, [x29, #48]
   8199c:	97fffe8c 	bl	813cc <tfp_format>
    putcp(&s,0);
   819a0:	9100e3a0 	add	x0, x29, #0x38
   819a4:	52800001 	mov	w1, #0x0                   	// #0
   819a8:	97ffffd1 	bl	818ec <putcp>
    va_end(va);
    }
   819ac:	d503201f 	nop
   819b0:	a8c97bfd 	ldp	x29, x30, [sp], #144
   819b4:	d65f03c0 	ret

00000000000819b8 <timer_init>:

/* 	These are for Arm generic timer. 
	They are fully functional on both QEMU and Rpi3 
	Recommended.
*/
void generic_timer_init ( void )
   819b8:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   819bc:	910003fd 	mov	x29, sp
{
   819c0:	d2860080 	mov	x0, #0x3004                	// #12292
   819c4:	f2a7e000 	movk	x0, #0x3f00, lsl #16
   819c8:	9400004c 	bl	81af8 <get32>
   819cc:	2a0003e1 	mov	w1, w0
   819d0:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   819d4:	91302000 	add	x0, x0, #0xc08
   819d8:	b9000001 	str	w1, [x0]
	gen_timer_init();
   819dc:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   819e0:	91302000 	add	x0, x0, #0xc08
   819e4:	b9400001 	ldr	w1, [x0]
   819e8:	5281a800 	mov	w0, #0xd40                 	// #3392
   819ec:	72a00060 	movk	w0, #0x3, lsl #16
   819f0:	0b000021 	add	w1, w1, w0
   819f4:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   819f8:	91302000 	add	x0, x0, #0xc08
   819fc:	b9000001 	str	w1, [x0]
	gen_timer_reset();
   81a00:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81a04:	91302000 	add	x0, x0, #0xc08
   81a08:	b9400000 	ldr	w0, [x0]
   81a0c:	2a0003e1 	mov	w1, w0
   81a10:	d2860200 	mov	x0, #0x3010                	// #12304
   81a14:	f2a7e000 	movk	x0, #0x3f00, lsl #16
   81a18:	94000036 	bl	81af0 <put32>
}
   81a1c:	d503201f 	nop
   81a20:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81a24:	d65f03c0 	ret

0000000000081a28 <handle_timer_irq>:

void handle_generic_timer_irq( void ) 
{
   81a28:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   81a2c:	910003fd 	mov	x29, sp
	gen_timer_reset();
   81a30:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81a34:	91302000 	add	x0, x0, #0xc08
   81a38:	b9400001 	ldr	w1, [x0]
   81a3c:	5281a800 	mov	w0, #0xd40                 	// #3392
   81a40:	72a00060 	movk	w0, #0x3, lsl #16
   81a44:	0b000021 	add	w1, w1, w0
   81a48:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81a4c:	91302000 	add	x0, x0, #0xc08
   81a50:	b9000001 	str	w1, [x0]
    timer_tick();
   81a54:	f00003e0 	adrp	x0, 100000 <bss_begin+0x7cc08>
   81a58:	91302000 	add	x0, x0, #0xc08
   81a5c:	b9400000 	ldr	w0, [x0]
   81a60:	2a0003e1 	mov	w1, w0
   81a64:	d2860200 	mov	x0, #0x3010                	// #12304
   81a68:	f2a7e000 	movk	x0, #0x3f00, lsl #16
   81a6c:	94000021 	bl	81af0 <put32>
}
   81a70:	52800041 	mov	w1, #0x2                   	// #2
   81a74:	d2860000 	mov	x0, #0x3000                	// #12288
   81a78:	f2a7e000 	movk	x0, #0x3f00, lsl #16
   81a7c:	9400001d 	bl	81af0 <put32>

   81a80:	97fffd17 	bl	80edc <timer_tick>
/* 
   81a84:	d503201f 	nop
   81a88:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81a8c:	d65f03c0 	ret

0000000000081a90 <generic_timer_init>:
	These are for "System Timer". They are NOT in use by this project. 
	I leave the code here FYI. 
	Rpi3: System Timer works fine. Can generate intrerrupts and be used as a counter for timekeeping.
   81a90:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   81a94:	910003fd 	mov	x29, sp
	QEMU: System Timer can be used for timekeeping. Cannot generate interrupts. 
   81a98:	9400000c 	bl	81ac8 <gen_timer_init>
	See our documentation:
   81a9c:	9400000e 	bl	81ad4 <gen_timer_reset>
	https://fxlin.github.io/p1-kernel/lesson03/rpi-os/#fyi-other-timers-on-rpi3
   81aa0:	d503201f 	nop
   81aa4:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81aa8:	d65f03c0 	ret

0000000000081aac <handle_generic_timer_irq>:
*/

const unsigned int interval = 200000;
   81aac:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   81ab0:	910003fd 	mov	x29, sp
unsigned int curVal = 0;
   81ab4:	94000008 	bl	81ad4 <gen_timer_reset>

   81ab8:	97fffd09 	bl	80edc <timer_tick>
void timer_init ( void )
   81abc:	d503201f 	nop
   81ac0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81ac4:	d65f03c0 	ret

0000000000081ac8 <gen_timer_init>:
 *  https://developer.arm.com/docs/ddi0487/ca/arm-architecture-reference-manual-armv8-for-armv8-a-architecture-profile
 */

.globl gen_timer_init
gen_timer_init:
	mov x0, #1
   81ac8:	d2800020 	mov	x0, #0x1                   	// #1
	msr CNTP_CTL_EL0, x0
   81acc:	d51be220 	msr	cntp_ctl_el0, x0
	ret
   81ad0:	d65f03c0 	ret

0000000000081ad4 <gen_timer_reset>:

.globl gen_timer_reset
gen_timer_reset:
    mov x0, #1
   81ad4:	d2800020 	mov	x0, #0x1                   	// #1
	lsl x0, x0, #24 
   81ad8:	d3689c00 	lsl	x0, x0, #24
	msr CNTP_TVAL_EL0, x0
   81adc:	d51be200 	msr	cntp_tval_el0, x0
   81ae0:	d65f03c0 	ret

0000000000081ae4 <get_el>:
.globl get_el
get_el:
	mrs x0, CurrentEL
   81ae4:	d5384240 	mrs	x0, currentel
	lsr x0, x0, #2
   81ae8:	d342fc00 	lsr	x0, x0, #2
	ret
   81aec:	d65f03c0 	ret

0000000000081af0 <put32>:

.globl put32
put32:
	str w1,[x0]
   81af0:	b9000001 	str	w1, [x0]
	ret
   81af4:	d65f03c0 	ret

0000000000081af8 <get32>:

.globl get32
get32:
	ldr w0,[x0]
   81af8:	b9400000 	ldr	w0, [x0]
	ret
   81afc:	d65f03c0 	ret

0000000000081b00 <delay>:

.globl delay
delay:
	subs x0, x0, #1
   81b00:	f1000400 	subs	x0, x0, #0x1
	bne delay
   81b04:	54ffffe1 	b.ne	81b00 <delay>  // b.any
	ret
   81b08:	d65f03c0 	ret

0000000000081b0c <irq_vector_init>:
.globl irq_vector_init
irq_vector_init:
	adr	x0, vectors		// load VBAR_EL1 with virtual
   81b0c:	100027a0 	adr	x0, 82000 <vectors>
	msr	vbar_el1, x0		// vector table address
   81b10:	d518c000 	msr	vbar_el1, x0
	ret
   81b14:	d65f03c0 	ret

0000000000081b18 <enable_irq>:

.globl enable_irq
enable_irq:
	msr    daifclr, #2 
   81b18:	d50342ff 	msr	daifclr, #0x2
	ret
   81b1c:	d65f03c0 	ret

0000000000081b20 <disable_irq>:

.globl disable_irq
disable_irq:
	msr	daifset, #2
   81b20:	d50342df 	msr	daifset, #0x2
	ret
   81b24:	d65f03c0 	ret
	...

0000000000082000 <vectors>:
 * Exception vectors.
 */
.align	11
.globl vectors 
vectors:
	ventry	sync_invalid_el1t			// Synchronous EL1t
   82000:	140001e1 	b	82784 <sync_invalid_el1t>
   82004:	d503201f 	nop
   82008:	d503201f 	nop
   8200c:	d503201f 	nop
   82010:	d503201f 	nop
   82014:	d503201f 	nop
   82018:	d503201f 	nop
   8201c:	d503201f 	nop
   82020:	d503201f 	nop
   82024:	d503201f 	nop
   82028:	d503201f 	nop
   8202c:	d503201f 	nop
   82030:	d503201f 	nop
   82034:	d503201f 	nop
   82038:	d503201f 	nop
   8203c:	d503201f 	nop
   82040:	d503201f 	nop
   82044:	d503201f 	nop
   82048:	d503201f 	nop
   8204c:	d503201f 	nop
   82050:	d503201f 	nop
   82054:	d503201f 	nop
   82058:	d503201f 	nop
   8205c:	d503201f 	nop
   82060:	d503201f 	nop
   82064:	d503201f 	nop
   82068:	d503201f 	nop
   8206c:	d503201f 	nop
   82070:	d503201f 	nop
   82074:	d503201f 	nop
   82078:	d503201f 	nop
   8207c:	d503201f 	nop
	ventry	irq_invalid_el1t			// IRQ EL1t
   82080:	140001da 	b	827e8 <irq_invalid_el1t>
   82084:	d503201f 	nop
   82088:	d503201f 	nop
   8208c:	d503201f 	nop
   82090:	d503201f 	nop
   82094:	d503201f 	nop
   82098:	d503201f 	nop
   8209c:	d503201f 	nop
   820a0:	d503201f 	nop
   820a4:	d503201f 	nop
   820a8:	d503201f 	nop
   820ac:	d503201f 	nop
   820b0:	d503201f 	nop
   820b4:	d503201f 	nop
   820b8:	d503201f 	nop
   820bc:	d503201f 	nop
   820c0:	d503201f 	nop
   820c4:	d503201f 	nop
   820c8:	d503201f 	nop
   820cc:	d503201f 	nop
   820d0:	d503201f 	nop
   820d4:	d503201f 	nop
   820d8:	d503201f 	nop
   820dc:	d503201f 	nop
   820e0:	d503201f 	nop
   820e4:	d503201f 	nop
   820e8:	d503201f 	nop
   820ec:	d503201f 	nop
   820f0:	d503201f 	nop
   820f4:	d503201f 	nop
   820f8:	d503201f 	nop
   820fc:	d503201f 	nop
	ventry	fiq_invalid_el1t			// FIQ EL1t
   82100:	140001d3 	b	8284c <fiq_invalid_el1t>
   82104:	d503201f 	nop
   82108:	d503201f 	nop
   8210c:	d503201f 	nop
   82110:	d503201f 	nop
   82114:	d503201f 	nop
   82118:	d503201f 	nop
   8211c:	d503201f 	nop
   82120:	d503201f 	nop
   82124:	d503201f 	nop
   82128:	d503201f 	nop
   8212c:	d503201f 	nop
   82130:	d503201f 	nop
   82134:	d503201f 	nop
   82138:	d503201f 	nop
   8213c:	d503201f 	nop
   82140:	d503201f 	nop
   82144:	d503201f 	nop
   82148:	d503201f 	nop
   8214c:	d503201f 	nop
   82150:	d503201f 	nop
   82154:	d503201f 	nop
   82158:	d503201f 	nop
   8215c:	d503201f 	nop
   82160:	d503201f 	nop
   82164:	d503201f 	nop
   82168:	d503201f 	nop
   8216c:	d503201f 	nop
   82170:	d503201f 	nop
   82174:	d503201f 	nop
   82178:	d503201f 	nop
   8217c:	d503201f 	nop
	ventry	error_invalid_el1t			// Error EL1t
   82180:	140001cc 	b	828b0 <error_invalid_el1t>
   82184:	d503201f 	nop
   82188:	d503201f 	nop
   8218c:	d503201f 	nop
   82190:	d503201f 	nop
   82194:	d503201f 	nop
   82198:	d503201f 	nop
   8219c:	d503201f 	nop
   821a0:	d503201f 	nop
   821a4:	d503201f 	nop
   821a8:	d503201f 	nop
   821ac:	d503201f 	nop
   821b0:	d503201f 	nop
   821b4:	d503201f 	nop
   821b8:	d503201f 	nop
   821bc:	d503201f 	nop
   821c0:	d503201f 	nop
   821c4:	d503201f 	nop
   821c8:	d503201f 	nop
   821cc:	d503201f 	nop
   821d0:	d503201f 	nop
   821d4:	d503201f 	nop
   821d8:	d503201f 	nop
   821dc:	d503201f 	nop
   821e0:	d503201f 	nop
   821e4:	d503201f 	nop
   821e8:	d503201f 	nop
   821ec:	d503201f 	nop
   821f0:	d503201f 	nop
   821f4:	d503201f 	nop
   821f8:	d503201f 	nop
   821fc:	d503201f 	nop

	ventry	sync_invalid_el1h			// Synchronous EL1h
   82200:	140001c5 	b	82914 <sync_invalid_el1h>
   82204:	d503201f 	nop
   82208:	d503201f 	nop
   8220c:	d503201f 	nop
   82210:	d503201f 	nop
   82214:	d503201f 	nop
   82218:	d503201f 	nop
   8221c:	d503201f 	nop
   82220:	d503201f 	nop
   82224:	d503201f 	nop
   82228:	d503201f 	nop
   8222c:	d503201f 	nop
   82230:	d503201f 	nop
   82234:	d503201f 	nop
   82238:	d503201f 	nop
   8223c:	d503201f 	nop
   82240:	d503201f 	nop
   82244:	d503201f 	nop
   82248:	d503201f 	nop
   8224c:	d503201f 	nop
   82250:	d503201f 	nop
   82254:	d503201f 	nop
   82258:	d503201f 	nop
   8225c:	d503201f 	nop
   82260:	d503201f 	nop
   82264:	d503201f 	nop
   82268:	d503201f 	nop
   8226c:	d503201f 	nop
   82270:	d503201f 	nop
   82274:	d503201f 	nop
   82278:	d503201f 	nop
   8227c:	d503201f 	nop
	ventry	el1_irq					// IRQ EL1h
   82280:	140002b8 	b	82d60 <el1_irq>
   82284:	d503201f 	nop
   82288:	d503201f 	nop
   8228c:	d503201f 	nop
   82290:	d503201f 	nop
   82294:	d503201f 	nop
   82298:	d503201f 	nop
   8229c:	d503201f 	nop
   822a0:	d503201f 	nop
   822a4:	d503201f 	nop
   822a8:	d503201f 	nop
   822ac:	d503201f 	nop
   822b0:	d503201f 	nop
   822b4:	d503201f 	nop
   822b8:	d503201f 	nop
   822bc:	d503201f 	nop
   822c0:	d503201f 	nop
   822c4:	d503201f 	nop
   822c8:	d503201f 	nop
   822cc:	d503201f 	nop
   822d0:	d503201f 	nop
   822d4:	d503201f 	nop
   822d8:	d503201f 	nop
   822dc:	d503201f 	nop
   822e0:	d503201f 	nop
   822e4:	d503201f 	nop
   822e8:	d503201f 	nop
   822ec:	d503201f 	nop
   822f0:	d503201f 	nop
   822f4:	d503201f 	nop
   822f8:	d503201f 	nop
   822fc:	d503201f 	nop
	ventry	fiq_invalid_el1h			// FIQ EL1h
   82300:	1400019e 	b	82978 <fiq_invalid_el1h>
   82304:	d503201f 	nop
   82308:	d503201f 	nop
   8230c:	d503201f 	nop
   82310:	d503201f 	nop
   82314:	d503201f 	nop
   82318:	d503201f 	nop
   8231c:	d503201f 	nop
   82320:	d503201f 	nop
   82324:	d503201f 	nop
   82328:	d503201f 	nop
   8232c:	d503201f 	nop
   82330:	d503201f 	nop
   82334:	d503201f 	nop
   82338:	d503201f 	nop
   8233c:	d503201f 	nop
   82340:	d503201f 	nop
   82344:	d503201f 	nop
   82348:	d503201f 	nop
   8234c:	d503201f 	nop
   82350:	d503201f 	nop
   82354:	d503201f 	nop
   82358:	d503201f 	nop
   8235c:	d503201f 	nop
   82360:	d503201f 	nop
   82364:	d503201f 	nop
   82368:	d503201f 	nop
   8236c:	d503201f 	nop
   82370:	d503201f 	nop
   82374:	d503201f 	nop
   82378:	d503201f 	nop
   8237c:	d503201f 	nop
	ventry	error_invalid_el1h			// Error EL1h
   82380:	14000197 	b	829dc <error_invalid_el1h>
   82384:	d503201f 	nop
   82388:	d503201f 	nop
   8238c:	d503201f 	nop
   82390:	d503201f 	nop
   82394:	d503201f 	nop
   82398:	d503201f 	nop
   8239c:	d503201f 	nop
   823a0:	d503201f 	nop
   823a4:	d503201f 	nop
   823a8:	d503201f 	nop
   823ac:	d503201f 	nop
   823b0:	d503201f 	nop
   823b4:	d503201f 	nop
   823b8:	d503201f 	nop
   823bc:	d503201f 	nop
   823c0:	d503201f 	nop
   823c4:	d503201f 	nop
   823c8:	d503201f 	nop
   823cc:	d503201f 	nop
   823d0:	d503201f 	nop
   823d4:	d503201f 	nop
   823d8:	d503201f 	nop
   823dc:	d503201f 	nop
   823e0:	d503201f 	nop
   823e4:	d503201f 	nop
   823e8:	d503201f 	nop
   823ec:	d503201f 	nop
   823f0:	d503201f 	nop
   823f4:	d503201f 	nop
   823f8:	d503201f 	nop
   823fc:	d503201f 	nop

	ventry	sync_invalid_el0_64			// Synchronous 64-bit EL0
   82400:	14000190 	b	82a40 <sync_invalid_el0_64>
   82404:	d503201f 	nop
   82408:	d503201f 	nop
   8240c:	d503201f 	nop
   82410:	d503201f 	nop
   82414:	d503201f 	nop
   82418:	d503201f 	nop
   8241c:	d503201f 	nop
   82420:	d503201f 	nop
   82424:	d503201f 	nop
   82428:	d503201f 	nop
   8242c:	d503201f 	nop
   82430:	d503201f 	nop
   82434:	d503201f 	nop
   82438:	d503201f 	nop
   8243c:	d503201f 	nop
   82440:	d503201f 	nop
   82444:	d503201f 	nop
   82448:	d503201f 	nop
   8244c:	d503201f 	nop
   82450:	d503201f 	nop
   82454:	d503201f 	nop
   82458:	d503201f 	nop
   8245c:	d503201f 	nop
   82460:	d503201f 	nop
   82464:	d503201f 	nop
   82468:	d503201f 	nop
   8246c:	d503201f 	nop
   82470:	d503201f 	nop
   82474:	d503201f 	nop
   82478:	d503201f 	nop
   8247c:	d503201f 	nop
	ventry	irq_invalid_el0_64			// IRQ 64-bit EL0
   82480:	14000189 	b	82aa4 <irq_invalid_el0_64>
   82484:	d503201f 	nop
   82488:	d503201f 	nop
   8248c:	d503201f 	nop
   82490:	d503201f 	nop
   82494:	d503201f 	nop
   82498:	d503201f 	nop
   8249c:	d503201f 	nop
   824a0:	d503201f 	nop
   824a4:	d503201f 	nop
   824a8:	d503201f 	nop
   824ac:	d503201f 	nop
   824b0:	d503201f 	nop
   824b4:	d503201f 	nop
   824b8:	d503201f 	nop
   824bc:	d503201f 	nop
   824c0:	d503201f 	nop
   824c4:	d503201f 	nop
   824c8:	d503201f 	nop
   824cc:	d503201f 	nop
   824d0:	d503201f 	nop
   824d4:	d503201f 	nop
   824d8:	d503201f 	nop
   824dc:	d503201f 	nop
   824e0:	d503201f 	nop
   824e4:	d503201f 	nop
   824e8:	d503201f 	nop
   824ec:	d503201f 	nop
   824f0:	d503201f 	nop
   824f4:	d503201f 	nop
   824f8:	d503201f 	nop
   824fc:	d503201f 	nop
	ventry	fiq_invalid_el0_64			// FIQ 64-bit EL0
   82500:	14000182 	b	82b08 <fiq_invalid_el0_64>
   82504:	d503201f 	nop
   82508:	d503201f 	nop
   8250c:	d503201f 	nop
   82510:	d503201f 	nop
   82514:	d503201f 	nop
   82518:	d503201f 	nop
   8251c:	d503201f 	nop
   82520:	d503201f 	nop
   82524:	d503201f 	nop
   82528:	d503201f 	nop
   8252c:	d503201f 	nop
   82530:	d503201f 	nop
   82534:	d503201f 	nop
   82538:	d503201f 	nop
   8253c:	d503201f 	nop
   82540:	d503201f 	nop
   82544:	d503201f 	nop
   82548:	d503201f 	nop
   8254c:	d503201f 	nop
   82550:	d503201f 	nop
   82554:	d503201f 	nop
   82558:	d503201f 	nop
   8255c:	d503201f 	nop
   82560:	d503201f 	nop
   82564:	d503201f 	nop
   82568:	d503201f 	nop
   8256c:	d503201f 	nop
   82570:	d503201f 	nop
   82574:	d503201f 	nop
   82578:	d503201f 	nop
   8257c:	d503201f 	nop
	ventry	error_invalid_el0_64			// Error 64-bit EL0
   82580:	1400017b 	b	82b6c <error_invalid_el0_64>
   82584:	d503201f 	nop
   82588:	d503201f 	nop
   8258c:	d503201f 	nop
   82590:	d503201f 	nop
   82594:	d503201f 	nop
   82598:	d503201f 	nop
   8259c:	d503201f 	nop
   825a0:	d503201f 	nop
   825a4:	d503201f 	nop
   825a8:	d503201f 	nop
   825ac:	d503201f 	nop
   825b0:	d503201f 	nop
   825b4:	d503201f 	nop
   825b8:	d503201f 	nop
   825bc:	d503201f 	nop
   825c0:	d503201f 	nop
   825c4:	d503201f 	nop
   825c8:	d503201f 	nop
   825cc:	d503201f 	nop
   825d0:	d503201f 	nop
   825d4:	d503201f 	nop
   825d8:	d503201f 	nop
   825dc:	d503201f 	nop
   825e0:	d503201f 	nop
   825e4:	d503201f 	nop
   825e8:	d503201f 	nop
   825ec:	d503201f 	nop
   825f0:	d503201f 	nop
   825f4:	d503201f 	nop
   825f8:	d503201f 	nop
   825fc:	d503201f 	nop

	ventry	sync_invalid_el0_32			// Synchronous 32-bit EL0
   82600:	14000174 	b	82bd0 <sync_invalid_el0_32>
   82604:	d503201f 	nop
   82608:	d503201f 	nop
   8260c:	d503201f 	nop
   82610:	d503201f 	nop
   82614:	d503201f 	nop
   82618:	d503201f 	nop
   8261c:	d503201f 	nop
   82620:	d503201f 	nop
   82624:	d503201f 	nop
   82628:	d503201f 	nop
   8262c:	d503201f 	nop
   82630:	d503201f 	nop
   82634:	d503201f 	nop
   82638:	d503201f 	nop
   8263c:	d503201f 	nop
   82640:	d503201f 	nop
   82644:	d503201f 	nop
   82648:	d503201f 	nop
   8264c:	d503201f 	nop
   82650:	d503201f 	nop
   82654:	d503201f 	nop
   82658:	d503201f 	nop
   8265c:	d503201f 	nop
   82660:	d503201f 	nop
   82664:	d503201f 	nop
   82668:	d503201f 	nop
   8266c:	d503201f 	nop
   82670:	d503201f 	nop
   82674:	d503201f 	nop
   82678:	d503201f 	nop
   8267c:	d503201f 	nop
	ventry	irq_invalid_el0_32			// IRQ 32-bit EL0
   82680:	1400016d 	b	82c34 <irq_invalid_el0_32>
   82684:	d503201f 	nop
   82688:	d503201f 	nop
   8268c:	d503201f 	nop
   82690:	d503201f 	nop
   82694:	d503201f 	nop
   82698:	d503201f 	nop
   8269c:	d503201f 	nop
   826a0:	d503201f 	nop
   826a4:	d503201f 	nop
   826a8:	d503201f 	nop
   826ac:	d503201f 	nop
   826b0:	d503201f 	nop
   826b4:	d503201f 	nop
   826b8:	d503201f 	nop
   826bc:	d503201f 	nop
   826c0:	d503201f 	nop
   826c4:	d503201f 	nop
   826c8:	d503201f 	nop
   826cc:	d503201f 	nop
   826d0:	d503201f 	nop
   826d4:	d503201f 	nop
   826d8:	d503201f 	nop
   826dc:	d503201f 	nop
   826e0:	d503201f 	nop
   826e4:	d503201f 	nop
   826e8:	d503201f 	nop
   826ec:	d503201f 	nop
   826f0:	d503201f 	nop
   826f4:	d503201f 	nop
   826f8:	d503201f 	nop
   826fc:	d503201f 	nop
	ventry	fiq_invalid_el0_32			// FIQ 32-bit EL0
   82700:	14000166 	b	82c98 <fiq_invalid_el0_32>
   82704:	d503201f 	nop
   82708:	d503201f 	nop
   8270c:	d503201f 	nop
   82710:	d503201f 	nop
   82714:	d503201f 	nop
   82718:	d503201f 	nop
   8271c:	d503201f 	nop
   82720:	d503201f 	nop
   82724:	d503201f 	nop
   82728:	d503201f 	nop
   8272c:	d503201f 	nop
   82730:	d503201f 	nop
   82734:	d503201f 	nop
   82738:	d503201f 	nop
   8273c:	d503201f 	nop
   82740:	d503201f 	nop
   82744:	d503201f 	nop
   82748:	d503201f 	nop
   8274c:	d503201f 	nop
   82750:	d503201f 	nop
   82754:	d503201f 	nop
   82758:	d503201f 	nop
   8275c:	d503201f 	nop
   82760:	d503201f 	nop
   82764:	d503201f 	nop
   82768:	d503201f 	nop
   8276c:	d503201f 	nop
   82770:	d503201f 	nop
   82774:	d503201f 	nop
   82778:	d503201f 	nop
   8277c:	d503201f 	nop
	ventry	error_invalid_el0_32			// Error 32-bit EL0
   82780:	1400015f 	b	82cfc <error_invalid_el0_32>

0000000000082784 <sync_invalid_el1t>:

sync_invalid_el1t:
	handle_invalid_entry  SYNC_INVALID_EL1t
   82784:	d10443ff 	sub	sp, sp, #0x110
   82788:	a90007e0 	stp	x0, x1, [sp]
   8278c:	a9010fe2 	stp	x2, x3, [sp, #16]
   82790:	a90217e4 	stp	x4, x5, [sp, #32]
   82794:	a9031fe6 	stp	x6, x7, [sp, #48]
   82798:	a90427e8 	stp	x8, x9, [sp, #64]
   8279c:	a9052fea 	stp	x10, x11, [sp, #80]
   827a0:	a90637ec 	stp	x12, x13, [sp, #96]
   827a4:	a9073fee 	stp	x14, x15, [sp, #112]
   827a8:	a90847f0 	stp	x16, x17, [sp, #128]
   827ac:	a9094ff2 	stp	x18, x19, [sp, #144]
   827b0:	a90a57f4 	stp	x20, x21, [sp, #160]
   827b4:	a90b5ff6 	stp	x22, x23, [sp, #176]
   827b8:	a90c67f8 	stp	x24, x25, [sp, #192]
   827bc:	a90d6ffa 	stp	x26, x27, [sp, #208]
   827c0:	a90e77fc 	stp	x28, x29, [sp, #224]
   827c4:	d5384036 	mrs	x22, elr_el1
   827c8:	d5384017 	mrs	x23, spsr_el1
   827cc:	a90f5bfe 	stp	x30, x22, [sp, #240]
   827d0:	f90083f7 	str	x23, [sp, #256]
   827d4:	d2800000 	mov	x0, #0x0                   	// #0
   827d8:	d5385201 	mrs	x1, esr_el1
   827dc:	d5384022 	mrs	x2, elr_el1
   827e0:	97fff86a 	bl	80988 <show_invalid_entry_message>
   827e4:	1400018c 	b	82e14 <err_hang>

00000000000827e8 <irq_invalid_el1t>:

irq_invalid_el1t:
	handle_invalid_entry  IRQ_INVALID_EL1t
   827e8:	d10443ff 	sub	sp, sp, #0x110
   827ec:	a90007e0 	stp	x0, x1, [sp]
   827f0:	a9010fe2 	stp	x2, x3, [sp, #16]
   827f4:	a90217e4 	stp	x4, x5, [sp, #32]
   827f8:	a9031fe6 	stp	x6, x7, [sp, #48]
   827fc:	a90427e8 	stp	x8, x9, [sp, #64]
   82800:	a9052fea 	stp	x10, x11, [sp, #80]
   82804:	a90637ec 	stp	x12, x13, [sp, #96]
   82808:	a9073fee 	stp	x14, x15, [sp, #112]
   8280c:	a90847f0 	stp	x16, x17, [sp, #128]
   82810:	a9094ff2 	stp	x18, x19, [sp, #144]
   82814:	a90a57f4 	stp	x20, x21, [sp, #160]
   82818:	a90b5ff6 	stp	x22, x23, [sp, #176]
   8281c:	a90c67f8 	stp	x24, x25, [sp, #192]
   82820:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82824:	a90e77fc 	stp	x28, x29, [sp, #224]
   82828:	d5384036 	mrs	x22, elr_el1
   8282c:	d5384017 	mrs	x23, spsr_el1
   82830:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82834:	f90083f7 	str	x23, [sp, #256]
   82838:	d2800020 	mov	x0, #0x1                   	// #1
   8283c:	d5385201 	mrs	x1, esr_el1
   82840:	d5384022 	mrs	x2, elr_el1
   82844:	97fff851 	bl	80988 <show_invalid_entry_message>
   82848:	14000173 	b	82e14 <err_hang>

000000000008284c <fiq_invalid_el1t>:

fiq_invalid_el1t:
	handle_invalid_entry  FIQ_INVALID_EL1t
   8284c:	d10443ff 	sub	sp, sp, #0x110
   82850:	a90007e0 	stp	x0, x1, [sp]
   82854:	a9010fe2 	stp	x2, x3, [sp, #16]
   82858:	a90217e4 	stp	x4, x5, [sp, #32]
   8285c:	a9031fe6 	stp	x6, x7, [sp, #48]
   82860:	a90427e8 	stp	x8, x9, [sp, #64]
   82864:	a9052fea 	stp	x10, x11, [sp, #80]
   82868:	a90637ec 	stp	x12, x13, [sp, #96]
   8286c:	a9073fee 	stp	x14, x15, [sp, #112]
   82870:	a90847f0 	stp	x16, x17, [sp, #128]
   82874:	a9094ff2 	stp	x18, x19, [sp, #144]
   82878:	a90a57f4 	stp	x20, x21, [sp, #160]
   8287c:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82880:	a90c67f8 	stp	x24, x25, [sp, #192]
   82884:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82888:	a90e77fc 	stp	x28, x29, [sp, #224]
   8288c:	d5384036 	mrs	x22, elr_el1
   82890:	d5384017 	mrs	x23, spsr_el1
   82894:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82898:	f90083f7 	str	x23, [sp, #256]
   8289c:	d2800040 	mov	x0, #0x2                   	// #2
   828a0:	d5385201 	mrs	x1, esr_el1
   828a4:	d5384022 	mrs	x2, elr_el1
   828a8:	97fff838 	bl	80988 <show_invalid_entry_message>
   828ac:	1400015a 	b	82e14 <err_hang>

00000000000828b0 <error_invalid_el1t>:

error_invalid_el1t:
	handle_invalid_entry  ERROR_INVALID_EL1t
   828b0:	d10443ff 	sub	sp, sp, #0x110
   828b4:	a90007e0 	stp	x0, x1, [sp]
   828b8:	a9010fe2 	stp	x2, x3, [sp, #16]
   828bc:	a90217e4 	stp	x4, x5, [sp, #32]
   828c0:	a9031fe6 	stp	x6, x7, [sp, #48]
   828c4:	a90427e8 	stp	x8, x9, [sp, #64]
   828c8:	a9052fea 	stp	x10, x11, [sp, #80]
   828cc:	a90637ec 	stp	x12, x13, [sp, #96]
   828d0:	a9073fee 	stp	x14, x15, [sp, #112]
   828d4:	a90847f0 	stp	x16, x17, [sp, #128]
   828d8:	a9094ff2 	stp	x18, x19, [sp, #144]
   828dc:	a90a57f4 	stp	x20, x21, [sp, #160]
   828e0:	a90b5ff6 	stp	x22, x23, [sp, #176]
   828e4:	a90c67f8 	stp	x24, x25, [sp, #192]
   828e8:	a90d6ffa 	stp	x26, x27, [sp, #208]
   828ec:	a90e77fc 	stp	x28, x29, [sp, #224]
   828f0:	d5384036 	mrs	x22, elr_el1
   828f4:	d5384017 	mrs	x23, spsr_el1
   828f8:	a90f5bfe 	stp	x30, x22, [sp, #240]
   828fc:	f90083f7 	str	x23, [sp, #256]
   82900:	d2800060 	mov	x0, #0x3                   	// #3
   82904:	d5385201 	mrs	x1, esr_el1
   82908:	d5384022 	mrs	x2, elr_el1
   8290c:	97fff81f 	bl	80988 <show_invalid_entry_message>
   82910:	14000141 	b	82e14 <err_hang>

0000000000082914 <sync_invalid_el1h>:

sync_invalid_el1h:
	handle_invalid_entry  SYNC_INVALID_EL1h
   82914:	d10443ff 	sub	sp, sp, #0x110
   82918:	a90007e0 	stp	x0, x1, [sp]
   8291c:	a9010fe2 	stp	x2, x3, [sp, #16]
   82920:	a90217e4 	stp	x4, x5, [sp, #32]
   82924:	a9031fe6 	stp	x6, x7, [sp, #48]
   82928:	a90427e8 	stp	x8, x9, [sp, #64]
   8292c:	a9052fea 	stp	x10, x11, [sp, #80]
   82930:	a90637ec 	stp	x12, x13, [sp, #96]
   82934:	a9073fee 	stp	x14, x15, [sp, #112]
   82938:	a90847f0 	stp	x16, x17, [sp, #128]
   8293c:	a9094ff2 	stp	x18, x19, [sp, #144]
   82940:	a90a57f4 	stp	x20, x21, [sp, #160]
   82944:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82948:	a90c67f8 	stp	x24, x25, [sp, #192]
   8294c:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82950:	a90e77fc 	stp	x28, x29, [sp, #224]
   82954:	d5384036 	mrs	x22, elr_el1
   82958:	d5384017 	mrs	x23, spsr_el1
   8295c:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82960:	f90083f7 	str	x23, [sp, #256]
   82964:	d2800080 	mov	x0, #0x4                   	// #4
   82968:	d5385201 	mrs	x1, esr_el1
   8296c:	d5384022 	mrs	x2, elr_el1
   82970:	97fff806 	bl	80988 <show_invalid_entry_message>
   82974:	14000128 	b	82e14 <err_hang>

0000000000082978 <fiq_invalid_el1h>:

fiq_invalid_el1h:
	handle_invalid_entry  FIQ_INVALID_EL1h
   82978:	d10443ff 	sub	sp, sp, #0x110
   8297c:	a90007e0 	stp	x0, x1, [sp]
   82980:	a9010fe2 	stp	x2, x3, [sp, #16]
   82984:	a90217e4 	stp	x4, x5, [sp, #32]
   82988:	a9031fe6 	stp	x6, x7, [sp, #48]
   8298c:	a90427e8 	stp	x8, x9, [sp, #64]
   82990:	a9052fea 	stp	x10, x11, [sp, #80]
   82994:	a90637ec 	stp	x12, x13, [sp, #96]
   82998:	a9073fee 	stp	x14, x15, [sp, #112]
   8299c:	a90847f0 	stp	x16, x17, [sp, #128]
   829a0:	a9094ff2 	stp	x18, x19, [sp, #144]
   829a4:	a90a57f4 	stp	x20, x21, [sp, #160]
   829a8:	a90b5ff6 	stp	x22, x23, [sp, #176]
   829ac:	a90c67f8 	stp	x24, x25, [sp, #192]
   829b0:	a90d6ffa 	stp	x26, x27, [sp, #208]
   829b4:	a90e77fc 	stp	x28, x29, [sp, #224]
   829b8:	d5384036 	mrs	x22, elr_el1
   829bc:	d5384017 	mrs	x23, spsr_el1
   829c0:	a90f5bfe 	stp	x30, x22, [sp, #240]
   829c4:	f90083f7 	str	x23, [sp, #256]
   829c8:	d28000c0 	mov	x0, #0x6                   	// #6
   829cc:	d5385201 	mrs	x1, esr_el1
   829d0:	d5384022 	mrs	x2, elr_el1
   829d4:	97fff7ed 	bl	80988 <show_invalid_entry_message>
   829d8:	1400010f 	b	82e14 <err_hang>

00000000000829dc <error_invalid_el1h>:

error_invalid_el1h:
	handle_invalid_entry  ERROR_INVALID_EL1h
   829dc:	d10443ff 	sub	sp, sp, #0x110
   829e0:	a90007e0 	stp	x0, x1, [sp]
   829e4:	a9010fe2 	stp	x2, x3, [sp, #16]
   829e8:	a90217e4 	stp	x4, x5, [sp, #32]
   829ec:	a9031fe6 	stp	x6, x7, [sp, #48]
   829f0:	a90427e8 	stp	x8, x9, [sp, #64]
   829f4:	a9052fea 	stp	x10, x11, [sp, #80]
   829f8:	a90637ec 	stp	x12, x13, [sp, #96]
   829fc:	a9073fee 	stp	x14, x15, [sp, #112]
   82a00:	a90847f0 	stp	x16, x17, [sp, #128]
   82a04:	a9094ff2 	stp	x18, x19, [sp, #144]
   82a08:	a90a57f4 	stp	x20, x21, [sp, #160]
   82a0c:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82a10:	a90c67f8 	stp	x24, x25, [sp, #192]
   82a14:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82a18:	a90e77fc 	stp	x28, x29, [sp, #224]
   82a1c:	d5384036 	mrs	x22, elr_el1
   82a20:	d5384017 	mrs	x23, spsr_el1
   82a24:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82a28:	f90083f7 	str	x23, [sp, #256]
   82a2c:	d28000e0 	mov	x0, #0x7                   	// #7
   82a30:	d5385201 	mrs	x1, esr_el1
   82a34:	d5384022 	mrs	x2, elr_el1
   82a38:	97fff7d4 	bl	80988 <show_invalid_entry_message>
   82a3c:	140000f6 	b	82e14 <err_hang>

0000000000082a40 <sync_invalid_el0_64>:

sync_invalid_el0_64:
	handle_invalid_entry  SYNC_INVALID_EL0_64
   82a40:	d10443ff 	sub	sp, sp, #0x110
   82a44:	a90007e0 	stp	x0, x1, [sp]
   82a48:	a9010fe2 	stp	x2, x3, [sp, #16]
   82a4c:	a90217e4 	stp	x4, x5, [sp, #32]
   82a50:	a9031fe6 	stp	x6, x7, [sp, #48]
   82a54:	a90427e8 	stp	x8, x9, [sp, #64]
   82a58:	a9052fea 	stp	x10, x11, [sp, #80]
   82a5c:	a90637ec 	stp	x12, x13, [sp, #96]
   82a60:	a9073fee 	stp	x14, x15, [sp, #112]
   82a64:	a90847f0 	stp	x16, x17, [sp, #128]
   82a68:	a9094ff2 	stp	x18, x19, [sp, #144]
   82a6c:	a90a57f4 	stp	x20, x21, [sp, #160]
   82a70:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82a74:	a90c67f8 	stp	x24, x25, [sp, #192]
   82a78:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82a7c:	a90e77fc 	stp	x28, x29, [sp, #224]
   82a80:	d5384036 	mrs	x22, elr_el1
   82a84:	d5384017 	mrs	x23, spsr_el1
   82a88:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82a8c:	f90083f7 	str	x23, [sp, #256]
   82a90:	d2800100 	mov	x0, #0x8                   	// #8
   82a94:	d5385201 	mrs	x1, esr_el1
   82a98:	d5384022 	mrs	x2, elr_el1
   82a9c:	97fff7bb 	bl	80988 <show_invalid_entry_message>
   82aa0:	140000dd 	b	82e14 <err_hang>

0000000000082aa4 <irq_invalid_el0_64>:

irq_invalid_el0_64:
	handle_invalid_entry  IRQ_INVALID_EL0_64
   82aa4:	d10443ff 	sub	sp, sp, #0x110
   82aa8:	a90007e0 	stp	x0, x1, [sp]
   82aac:	a9010fe2 	stp	x2, x3, [sp, #16]
   82ab0:	a90217e4 	stp	x4, x5, [sp, #32]
   82ab4:	a9031fe6 	stp	x6, x7, [sp, #48]
   82ab8:	a90427e8 	stp	x8, x9, [sp, #64]
   82abc:	a9052fea 	stp	x10, x11, [sp, #80]
   82ac0:	a90637ec 	stp	x12, x13, [sp, #96]
   82ac4:	a9073fee 	stp	x14, x15, [sp, #112]
   82ac8:	a90847f0 	stp	x16, x17, [sp, #128]
   82acc:	a9094ff2 	stp	x18, x19, [sp, #144]
   82ad0:	a90a57f4 	stp	x20, x21, [sp, #160]
   82ad4:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82ad8:	a90c67f8 	stp	x24, x25, [sp, #192]
   82adc:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82ae0:	a90e77fc 	stp	x28, x29, [sp, #224]
   82ae4:	d5384036 	mrs	x22, elr_el1
   82ae8:	d5384017 	mrs	x23, spsr_el1
   82aec:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82af0:	f90083f7 	str	x23, [sp, #256]
   82af4:	d2800120 	mov	x0, #0x9                   	// #9
   82af8:	d5385201 	mrs	x1, esr_el1
   82afc:	d5384022 	mrs	x2, elr_el1
   82b00:	97fff7a2 	bl	80988 <show_invalid_entry_message>
   82b04:	140000c4 	b	82e14 <err_hang>

0000000000082b08 <fiq_invalid_el0_64>:

fiq_invalid_el0_64:
	handle_invalid_entry  FIQ_INVALID_EL0_64
   82b08:	d10443ff 	sub	sp, sp, #0x110
   82b0c:	a90007e0 	stp	x0, x1, [sp]
   82b10:	a9010fe2 	stp	x2, x3, [sp, #16]
   82b14:	a90217e4 	stp	x4, x5, [sp, #32]
   82b18:	a9031fe6 	stp	x6, x7, [sp, #48]
   82b1c:	a90427e8 	stp	x8, x9, [sp, #64]
   82b20:	a9052fea 	stp	x10, x11, [sp, #80]
   82b24:	a90637ec 	stp	x12, x13, [sp, #96]
   82b28:	a9073fee 	stp	x14, x15, [sp, #112]
   82b2c:	a90847f0 	stp	x16, x17, [sp, #128]
   82b30:	a9094ff2 	stp	x18, x19, [sp, #144]
   82b34:	a90a57f4 	stp	x20, x21, [sp, #160]
   82b38:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82b3c:	a90c67f8 	stp	x24, x25, [sp, #192]
   82b40:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82b44:	a90e77fc 	stp	x28, x29, [sp, #224]
   82b48:	d5384036 	mrs	x22, elr_el1
   82b4c:	d5384017 	mrs	x23, spsr_el1
   82b50:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82b54:	f90083f7 	str	x23, [sp, #256]
   82b58:	d2800140 	mov	x0, #0xa                   	// #10
   82b5c:	d5385201 	mrs	x1, esr_el1
   82b60:	d5384022 	mrs	x2, elr_el1
   82b64:	97fff789 	bl	80988 <show_invalid_entry_message>
   82b68:	140000ab 	b	82e14 <err_hang>

0000000000082b6c <error_invalid_el0_64>:

error_invalid_el0_64:
	handle_invalid_entry  ERROR_INVALID_EL0_64
   82b6c:	d10443ff 	sub	sp, sp, #0x110
   82b70:	a90007e0 	stp	x0, x1, [sp]
   82b74:	a9010fe2 	stp	x2, x3, [sp, #16]
   82b78:	a90217e4 	stp	x4, x5, [sp, #32]
   82b7c:	a9031fe6 	stp	x6, x7, [sp, #48]
   82b80:	a90427e8 	stp	x8, x9, [sp, #64]
   82b84:	a9052fea 	stp	x10, x11, [sp, #80]
   82b88:	a90637ec 	stp	x12, x13, [sp, #96]
   82b8c:	a9073fee 	stp	x14, x15, [sp, #112]
   82b90:	a90847f0 	stp	x16, x17, [sp, #128]
   82b94:	a9094ff2 	stp	x18, x19, [sp, #144]
   82b98:	a90a57f4 	stp	x20, x21, [sp, #160]
   82b9c:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82ba0:	a90c67f8 	stp	x24, x25, [sp, #192]
   82ba4:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82ba8:	a90e77fc 	stp	x28, x29, [sp, #224]
   82bac:	d5384036 	mrs	x22, elr_el1
   82bb0:	d5384017 	mrs	x23, spsr_el1
   82bb4:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82bb8:	f90083f7 	str	x23, [sp, #256]
   82bbc:	d2800160 	mov	x0, #0xb                   	// #11
   82bc0:	d5385201 	mrs	x1, esr_el1
   82bc4:	d5384022 	mrs	x2, elr_el1
   82bc8:	97fff770 	bl	80988 <show_invalid_entry_message>
   82bcc:	14000092 	b	82e14 <err_hang>

0000000000082bd0 <sync_invalid_el0_32>:

sync_invalid_el0_32:
	handle_invalid_entry  SYNC_INVALID_EL0_32
   82bd0:	d10443ff 	sub	sp, sp, #0x110
   82bd4:	a90007e0 	stp	x0, x1, [sp]
   82bd8:	a9010fe2 	stp	x2, x3, [sp, #16]
   82bdc:	a90217e4 	stp	x4, x5, [sp, #32]
   82be0:	a9031fe6 	stp	x6, x7, [sp, #48]
   82be4:	a90427e8 	stp	x8, x9, [sp, #64]
   82be8:	a9052fea 	stp	x10, x11, [sp, #80]
   82bec:	a90637ec 	stp	x12, x13, [sp, #96]
   82bf0:	a9073fee 	stp	x14, x15, [sp, #112]
   82bf4:	a90847f0 	stp	x16, x17, [sp, #128]
   82bf8:	a9094ff2 	stp	x18, x19, [sp, #144]
   82bfc:	a90a57f4 	stp	x20, x21, [sp, #160]
   82c00:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82c04:	a90c67f8 	stp	x24, x25, [sp, #192]
   82c08:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82c0c:	a90e77fc 	stp	x28, x29, [sp, #224]
   82c10:	d5384036 	mrs	x22, elr_el1
   82c14:	d5384017 	mrs	x23, spsr_el1
   82c18:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82c1c:	f90083f7 	str	x23, [sp, #256]
   82c20:	d2800180 	mov	x0, #0xc                   	// #12
   82c24:	d5385201 	mrs	x1, esr_el1
   82c28:	d5384022 	mrs	x2, elr_el1
   82c2c:	97fff757 	bl	80988 <show_invalid_entry_message>
   82c30:	14000079 	b	82e14 <err_hang>

0000000000082c34 <irq_invalid_el0_32>:

irq_invalid_el0_32:
	handle_invalid_entry  IRQ_INVALID_EL0_32
   82c34:	d10443ff 	sub	sp, sp, #0x110
   82c38:	a90007e0 	stp	x0, x1, [sp]
   82c3c:	a9010fe2 	stp	x2, x3, [sp, #16]
   82c40:	a90217e4 	stp	x4, x5, [sp, #32]
   82c44:	a9031fe6 	stp	x6, x7, [sp, #48]
   82c48:	a90427e8 	stp	x8, x9, [sp, #64]
   82c4c:	a9052fea 	stp	x10, x11, [sp, #80]
   82c50:	a90637ec 	stp	x12, x13, [sp, #96]
   82c54:	a9073fee 	stp	x14, x15, [sp, #112]
   82c58:	a90847f0 	stp	x16, x17, [sp, #128]
   82c5c:	a9094ff2 	stp	x18, x19, [sp, #144]
   82c60:	a90a57f4 	stp	x20, x21, [sp, #160]
   82c64:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82c68:	a90c67f8 	stp	x24, x25, [sp, #192]
   82c6c:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82c70:	a90e77fc 	stp	x28, x29, [sp, #224]
   82c74:	d5384036 	mrs	x22, elr_el1
   82c78:	d5384017 	mrs	x23, spsr_el1
   82c7c:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82c80:	f90083f7 	str	x23, [sp, #256]
   82c84:	d28001a0 	mov	x0, #0xd                   	// #13
   82c88:	d5385201 	mrs	x1, esr_el1
   82c8c:	d5384022 	mrs	x2, elr_el1
   82c90:	97fff73e 	bl	80988 <show_invalid_entry_message>
   82c94:	14000060 	b	82e14 <err_hang>

0000000000082c98 <fiq_invalid_el0_32>:

fiq_invalid_el0_32:
	handle_invalid_entry  FIQ_INVALID_EL0_32
   82c98:	d10443ff 	sub	sp, sp, #0x110
   82c9c:	a90007e0 	stp	x0, x1, [sp]
   82ca0:	a9010fe2 	stp	x2, x3, [sp, #16]
   82ca4:	a90217e4 	stp	x4, x5, [sp, #32]
   82ca8:	a9031fe6 	stp	x6, x7, [sp, #48]
   82cac:	a90427e8 	stp	x8, x9, [sp, #64]
   82cb0:	a9052fea 	stp	x10, x11, [sp, #80]
   82cb4:	a90637ec 	stp	x12, x13, [sp, #96]
   82cb8:	a9073fee 	stp	x14, x15, [sp, #112]
   82cbc:	a90847f0 	stp	x16, x17, [sp, #128]
   82cc0:	a9094ff2 	stp	x18, x19, [sp, #144]
   82cc4:	a90a57f4 	stp	x20, x21, [sp, #160]
   82cc8:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82ccc:	a90c67f8 	stp	x24, x25, [sp, #192]
   82cd0:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82cd4:	a90e77fc 	stp	x28, x29, [sp, #224]
   82cd8:	d5384036 	mrs	x22, elr_el1
   82cdc:	d5384017 	mrs	x23, spsr_el1
   82ce0:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82ce4:	f90083f7 	str	x23, [sp, #256]
   82ce8:	d28001c0 	mov	x0, #0xe                   	// #14
   82cec:	d5385201 	mrs	x1, esr_el1
   82cf0:	d5384022 	mrs	x2, elr_el1
   82cf4:	97fff725 	bl	80988 <show_invalid_entry_message>
   82cf8:	14000047 	b	82e14 <err_hang>

0000000000082cfc <error_invalid_el0_32>:

error_invalid_el0_32:
	handle_invalid_entry  ERROR_INVALID_EL0_32
   82cfc:	d10443ff 	sub	sp, sp, #0x110
   82d00:	a90007e0 	stp	x0, x1, [sp]
   82d04:	a9010fe2 	stp	x2, x3, [sp, #16]
   82d08:	a90217e4 	stp	x4, x5, [sp, #32]
   82d0c:	a9031fe6 	stp	x6, x7, [sp, #48]
   82d10:	a90427e8 	stp	x8, x9, [sp, #64]
   82d14:	a9052fea 	stp	x10, x11, [sp, #80]
   82d18:	a90637ec 	stp	x12, x13, [sp, #96]
   82d1c:	a9073fee 	stp	x14, x15, [sp, #112]
   82d20:	a90847f0 	stp	x16, x17, [sp, #128]
   82d24:	a9094ff2 	stp	x18, x19, [sp, #144]
   82d28:	a90a57f4 	stp	x20, x21, [sp, #160]
   82d2c:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82d30:	a90c67f8 	stp	x24, x25, [sp, #192]
   82d34:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82d38:	a90e77fc 	stp	x28, x29, [sp, #224]
   82d3c:	d5384036 	mrs	x22, elr_el1
   82d40:	d5384017 	mrs	x23, spsr_el1
   82d44:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82d48:	f90083f7 	str	x23, [sp, #256]
   82d4c:	d28001e0 	mov	x0, #0xf                   	// #15
   82d50:	d5385201 	mrs	x1, esr_el1
   82d54:	d5384022 	mrs	x2, elr_el1
   82d58:	97fff70c 	bl	80988 <show_invalid_entry_message>
   82d5c:	1400002e 	b	82e14 <err_hang>

0000000000082d60 <el1_irq>:

el1_irq:
	kernel_entry 
   82d60:	d10443ff 	sub	sp, sp, #0x110
   82d64:	a90007e0 	stp	x0, x1, [sp]
   82d68:	a9010fe2 	stp	x2, x3, [sp, #16]
   82d6c:	a90217e4 	stp	x4, x5, [sp, #32]
   82d70:	a9031fe6 	stp	x6, x7, [sp, #48]
   82d74:	a90427e8 	stp	x8, x9, [sp, #64]
   82d78:	a9052fea 	stp	x10, x11, [sp, #80]
   82d7c:	a90637ec 	stp	x12, x13, [sp, #96]
   82d80:	a9073fee 	stp	x14, x15, [sp, #112]
   82d84:	a90847f0 	stp	x16, x17, [sp, #128]
   82d88:	a9094ff2 	stp	x18, x19, [sp, #144]
   82d8c:	a90a57f4 	stp	x20, x21, [sp, #160]
   82d90:	a90b5ff6 	stp	x22, x23, [sp, #176]
   82d94:	a90c67f8 	stp	x24, x25, [sp, #192]
   82d98:	a90d6ffa 	stp	x26, x27, [sp, #208]
   82d9c:	a90e77fc 	stp	x28, x29, [sp, #224]
   82da0:	d5384036 	mrs	x22, elr_el1
   82da4:	d5384017 	mrs	x23, spsr_el1
   82da8:	a90f5bfe 	stp	x30, x22, [sp, #240]
   82dac:	f90083f7 	str	x23, [sp, #256]
	bl	handle_irq
   82db0:	97fff707 	bl	809cc <handle_irq>
	kernel_exit 
   82db4:	f94083f7 	ldr	x23, [sp, #256]
   82db8:	a94f5bfe 	ldp	x30, x22, [sp, #240]
   82dbc:	d5184036 	msr	elr_el1, x22
   82dc0:	d5184017 	msr	spsr_el1, x23
   82dc4:	a94007e0 	ldp	x0, x1, [sp]
   82dc8:	a9410fe2 	ldp	x2, x3, [sp, #16]
   82dcc:	a94217e4 	ldp	x4, x5, [sp, #32]
   82dd0:	a9431fe6 	ldp	x6, x7, [sp, #48]
   82dd4:	a94427e8 	ldp	x8, x9, [sp, #64]
   82dd8:	a9452fea 	ldp	x10, x11, [sp, #80]
   82ddc:	a94637ec 	ldp	x12, x13, [sp, #96]
   82de0:	a9473fee 	ldp	x14, x15, [sp, #112]
   82de4:	a94847f0 	ldp	x16, x17, [sp, #128]
   82de8:	a9494ff2 	ldp	x18, x19, [sp, #144]
   82dec:	a94a57f4 	ldp	x20, x21, [sp, #160]
   82df0:	a94b5ff6 	ldp	x22, x23, [sp, #176]
   82df4:	a94c67f8 	ldp	x24, x25, [sp, #192]
   82df8:	a94d6ffa 	ldp	x26, x27, [sp, #208]
   82dfc:	a94e77fc 	ldp	x28, x29, [sp, #224]
   82e00:	910443ff 	add	sp, sp, #0x110
   82e04:	d69f03e0 	eret

0000000000082e08 <ret_from_fork>:

.globl ret_from_fork
ret_from_fork:
	bl	schedule_tail
   82e08:	97fff82f 	bl	80ec4 <schedule_tail>
	mov	x0, x20
   82e0c:	aa1403e0 	mov	x0, x20
	blr	x19 		//should never return
   82e10:	d63f0260 	blr	x19

0000000000082e14 <err_hang>:

.globl err_hang
err_hang: b err_hang
   82e14:	14000000 	b	82e14 <err_hang>

0000000000082e18 <memzero>:
.globl memzero
memzero:
	str xzr, [x0], #8
   82e18:	f800841f 	str	xzr, [x0], #8
	subs x1, x1, #8
   82e1c:	f1002021 	subs	x1, x1, #0x8
	b.gt memzero
   82e20:	54ffffcc 	b.gt	82e18 <memzero>
	ret
   82e24:	d65f03c0 	ret

0000000000082e28 <cpu_switch_to>:
#include "sched.h"

.globl cpu_switch_to
cpu_switch_to:
	mov	x10, #THREAD_CPU_CONTEXT
   82e28:	d280000a 	mov	x10, #0x0                   	// #0
	add	x8, x0, x10
   82e2c:	8b0a0008 	add	x8, x0, x10
	mov	x9, sp
   82e30:	910003e9 	mov	x9, sp
	stp	x19, x20, [x8], #16		// store callee-saved registers
   82e34:	a8815113 	stp	x19, x20, [x8], #16
	stp	x21, x22, [x8], #16
   82e38:	a8815915 	stp	x21, x22, [x8], #16
	stp	x23, x24, [x8], #16
   82e3c:	a8816117 	stp	x23, x24, [x8], #16
	stp	x25, x26, [x8], #16
   82e40:	a8816919 	stp	x25, x26, [x8], #16
	stp	x27, x28, [x8], #16
   82e44:	a881711b 	stp	x27, x28, [x8], #16
	stp	x29, x9, [x8], #16
   82e48:	a881251d 	stp	x29, x9, [x8], #16
	str	x30, [x8]
   82e4c:	f900011e 	str	x30, [x8]
	add	x8, x1, x10
   82e50:	8b0a0028 	add	x8, x1, x10
	ldp	x19, x20, [x8], #16		// restore callee-saved registers
   82e54:	a8c15113 	ldp	x19, x20, [x8], #16
	ldp	x21, x22, [x8], #16
   82e58:	a8c15915 	ldp	x21, x22, [x8], #16
	ldp	x23, x24, [x8], #16
   82e5c:	a8c16117 	ldp	x23, x24, [x8], #16
	ldp	x25, x26, [x8], #16
   82e60:	a8c16919 	ldp	x25, x26, [x8], #16
	ldp	x27, x28, [x8], #16
   82e64:	a8c1711b 	ldp	x27, x28, [x8], #16
	ldp	x29, x9, [x8], #16
   82e68:	a8c1251d 	ldp	x29, x9, [x8], #16
	ldr	x30, [x8]
   82e6c:	f940011e 	ldr	x30, [x8]
	mov	sp, x9
   82e70:	9100013f 	mov	sp, x9
	ret
   82e74:	d65f03c0 	ret
