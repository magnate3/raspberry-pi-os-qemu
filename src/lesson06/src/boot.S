#include "arm/mmu.h"
#include "arm/sysregs.h"
#include "mm.h"
#include "peripherals/base.h"

.section ".text.boot"

.globl _start
_start:
	mrs	x0, mpidr_el1		
	and	x0, x0,#0xFF		// Check processor id
	cbz	x0, master		// Hang for all non-primary CPU
	b	proc_hang

proc_hang: 
	b proc_hang

master:
	ldr	x0, =SCTLR_VALUE_MMU_DISABLED
	msr	sctlr_el1, x0		
	
	mrs x0, CurrentEL
  lsr x0, x0, #2
	cmp x0, #3
	beq el3

//	ldr	x0, =HCR_VALUE
//	msr	hcr_el2, x0
	mrs	x0, hcr_el2
	orr	x0, x0, #(1<<31)
	msr	hcr_el2, x0

	mov 	x0, #SPSR_VALUE
	msr	spsr_el2, x0

	adr	x0, el1_entry
	msr	elr_el2, x0
	eret

el3:
  ldr x0, =HCR_VALUE
  msr hcr_el2, x0

	ldr	x0, =SCR_VALUE
	msr	scr_el3, x0

	ldr	x0, =SPSR_VALUE
	msr	spsr_el3, x0

	adr	x0, el1_entry		
	msr	elr_el3, x0

	eret				

el1_entry:
	adr	x0, bss_begin
	adr	x1, bss_end
	sub	x1, x1, x0
	bl 	memzero

#ifdef USE_QEMU
// A workaround for QEMU's quirks on MMU emulation, which also showcases how __create_page_tables
// can be used. 
// 
// As soon as the MMU is on and CPU switches from physical addresses to virtual addresses, 
// the emulated CPU seems to be still fetching next (few) instructions using the physical 
// addresses of those instructions. These addresses will go through MMU for translation 
// as if they are virtual addresses. Of course our kernel pgtables do not have translation
// for these addresses (TTBR1 is for translating virtual addresses at 0xffff...). That causes 
// MMU to throw a Prefetch abort. (prefetch == instruction loading)
//
// Real Rpi3 hardware has no such a problem: after MMU is on, it will not fetch instructions 
// at addresses calculated before MMU is on. 
//
// The workaround is to set an "identity" mapping. That is, we create an additional 
// pgtable tree at TTBR0 that maps all physical DRAM (0 -- PHYS_MEMORY_SIZE) to virtual 
// addresses with the same values. That keeps translation going on at the switch of MMU. 
//
// Cf: https://github.com/s-matyukevich/raspberry-pi-os/issues/8
// https://www.raspberrypi.org/forums/viewtopic.php?t=222408
	bl	__create_idmap
	adrp	x0, idmap_dir
	msr	ttbr0_el1, x0
#endif

	bl 	__create_page_tables

	mov	x0, #VA_START			
	add	sp, x0, #LOW_MEMORY

	adrp	x0, pg_dir				
	msr	ttbr1_el1, x0

	// tcr_el1: Translation Control Register, responsible for configuring MMU, e.g. page size
	ldr	x0, =(TCR_VALUE)		
	msr	tcr_el1, x0 

	ldr	x0, =(MAIR_VALUE)
	msr	mair_el1, x0

	ldr	x2, =kernel_main

	mov	x0, #SCTLR_MMU_ENABLED				
	msr	sctlr_el1, x0	// BOOM! we are on virtual after this.

	br 	x2

	// Given a virt addr and the PGD, set the PGD entry, allocate one PUD and one PMD.
	//		link PGD -> PUD and PUD -> PMD
	// @tbl: a register pointing to PGD
	// @virt: the virtual address that we are currently mapping
	// @tmp1/2: temporary registers to use; contents will be clobbered 
	.macro	create_pgd_entry, tbl, virt, tmp1, tmp2
	create_table_entry \tbl, \virt, PGD_SHIFT, \tmp1, \tmp2  // set a PGD entry
	// @tbl now points to the newly created PUD table
	create_table_entry \tbl, \virt, PUD_SHIFT, \tmp1, \tmp2		// set a PUD entry
	// @tbl now points to the newly created PMD table
	.endm

	// Allocating a new page table (either PGD or PUD) for the kernel's initial page tables
	// All the initial page tables are located in one continuous memory region
	//
	// @tbl: a register pointing to the last pgtable in a memory region, from which pgtables 
	//			are allocated sequentially
	// @virt: the virtual address that we are currently mapping
	// @shift: 39 in case of PGD and 30 in case of PUD
	// 		   apply to the virtual address in order to extract current table index. 
	// @tmp1/2: temporary registers to use; contents will be clobbered 
	.macro	create_table_entry, tbl, virt, shift, tmp1, tmp2
	lsr	\tmp1, \virt, #\shift
	and	\tmp1, \tmp1, #PTRS_PER_TABLE - 1		// tmp1: table index
	add	\tmp2, \tbl, #PAGE_SIZE					// tmp2: addr of a next level pgtable (PUD or PMD). 
	orr	\tmp2, \tmp2, #MM_TYPE_PAGE_TABLE		// tmp2: make a table descriptor. set bits[0:1] to 1. 
	str	\tmp2, [\tbl, \tmp1, lsl #3]			// store descriptor (tmp2) to the current pgtable at index (tmp1)
	add	\tbl, \tbl, #PAGE_SIZE					// point @tbl to the newly create next level pgtable. programming ease
	.endm

	// Populating entries in a PMD table for a given virt addr range 
	// @tbl: a reg pointing to the PMD table
	// @phys: the start of the physical region to be mapped
	// @start/@end: virtual address of the first/last section to be mapped
	// @flags: to be copied into lower attributes of the block descriptor
	// @tmp1: temporary register to use; contents will be clobbered
	.macro	create_block_map, tbl, phys, start, end, flags, tmp1
	lsr	\start, \start, #SECTION_SHIFT
	and	\start, \start, #PTRS_PER_TABLE - 1			// start index in the PMD
	lsr	\end, \end, #SECTION_SHIFT
	and	\end, \end, #PTRS_PER_TABLE - 1				// end index in the PMD
	lsr	\phys, \phys, #SECTION_SHIFT				// assmble a table entry 
	mov	\tmp1, #\flags
	orr	\phys, \tmp1, \phys, lsl #SECTION_SHIFT			// phys: the table entry value
9999:	str	\phys, [\tbl, \start, lsl #3]				// store the entry in PMD
	add	\start, \start, #1								// @start: index of next PMD entry 
	add	\phys, \phys, #SECTION_SIZE						// update the table entry value
	cmp	\start, \end
	b.ls	9999b
	.endm

#ifdef USE_QEMU
__create_idmap:
	mov	x29, x30
	
	adrp	x0, idmap_dir
	mov	x1, #PG_DIR_SIZE
	bl	memzero

	adrp	x0, idmap_dir
	mov	x1, xzr
	create_pgd_entry	x0, x1, x2, x3

	mov	x1, xzr
	mov	x2, xzr
	ldr	x3, =(PHYS_MEMORY_SIZE)
	create_block_map x0, x1, x2, x3, MMU_FLAGS, x4

	mov	x30, x29
	ret
#endif

__create_page_tables:
	mov		x29, x30						// save return address

	// clear the mem region backing pgtables
	adrp 	x0, pg_dir
	mov		x1, #PG_DIR_SIZE
	bl 		memzero

	// allocate one PUD & one PMD; link PGD (pg_dir)->PUD, and PUD->PMD
	adrp	x0, pg_dir
	mov		x1, #VA_START 
	create_pgd_entry x0, x1, x2, x3		// after this, x0 points to the new PMD table

	/* Mapping kernel and init stack. Phys addr range: 0--DEVICE_BASE */
	mov 	x1, xzr				// x1 = starting phys addr. set x1 to 0. 
	mov 	x2, #VA_START		// x2 = the virtual base of the first section
	ldr		x3, =(VA_START + DEVICE_BASE - SECTION_SIZE)  // x3 = the virtual base of the last section
	create_block_map x0, x1, x2, x3, MMU_FLAGS, x4

	/* Mapping device memory. Phys addr range: DEVICE_BASE--PHYS_MEMORY_SIZE(0x40000000) */
	mov 	x1, #DEVICE_BASE					// x1 = start mapping from device base address 
	ldr 	x2, =(VA_START + DEVICE_BASE)				// x2 = first virtual address
	ldr		x3, =(VA_START + PHYS_MEMORY_SIZE - SECTION_SIZE)	// x3 = the virtual base of the last section
	create_block_map x0, x1, x2, x3, MMU_DEVICE_FLAGS, x4

	mov	x30, x29						// restore return address
	ret

