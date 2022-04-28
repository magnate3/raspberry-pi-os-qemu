## boot.S

boot.S is copy from [raspberry-pi-os/exercises/lesson03/3/bl4ckout31/src/boot.S](https://github.com/fxlin/p1-kernel/tree/master/src/lesson02)


```
root@ubuntu:~/arm/raspberry-pi3-mini-os/2.exception_level/el_1# cat boot.S 
#include "arm_v8/sysregs.h"

#include "mm.h"

.section ".text.boot"

.globl _start
_start:
        mrs     x0, mpidr_el1
        and     x0, x0,#0xFF            // Check processor id
        cbz     x0, master              // Hang for all non-primary CPU
        b       proc_hang

proc_hang: 
        b       proc_hang

master:
        ldr     x0, =SCTLR_VALUE_MMU_DISABLED // System control register
        msr     sctlr_el1, x0

        ldr     x0, =HCR_VALUE          // Hypervisor Configuration (EL2) 
        msr     hcr_el2, x0  

#ifdef USE_QEMU                 // xzl: qemu boots from EL2. cannot do things to EL3
        ldr     x0, =SPSR_VALUE
        msr     spsr_el2, x0

        #adr    x0, el1_entry
        adr x0, el1_entry_another
        msr     elr_el2, x0
#else                                   // xzl: Rpi3 hw boots from EL3. 
        ldr     x0, =SCR_VALUE  // Secure config register. Only at EL3.
        msr     scr_el3, x0

        ldr     x0, =SPSR_VALUE
        msr     spsr_el3, x0

        adr     x0, el1_entry
        msr     elr_el3, x0
#endif
  
        eret

el1_entry:
        adr     x0, bss_begin
        adr     x1, bss_end
        sub     x1, x1, x0
        bl      memzero

el1_entry_another:
        mov     sp, #LOW_MEMORY
        bl      kernel_main
        b       proc_hang               // should never come here
```

# make
```
root@ubuntu:~/arm/p1-kernel/src/lesson02# make -f Makefile.qemu 
mkdir -p build
aarch64-linux-gnu-gcc -Wall -nostdlib -nostartfiles -ffreestanding -Iinclude -mgeneral-regs-only -g -O0 -DUSE_QEMU -MMD -c src/mini_uart.c -o build/mini_uart_c.o
mkdir -p build
aarch64-linux-gnu-gcc -Wall -nostdlib -nostartfiles -ffreestanding -Iinclude -mgeneral-regs-only -g -O0 -DUSE_QEMU -MMD -c src/printf.c -o build/printf_c.o
mkdir -p build
aarch64-linux-gnu-gcc -Wall -nostdlib -nostartfiles -ffreestanding -Iinclude -mgeneral-regs-only -g -O0 -DUSE_QEMU -MMD -c src/kernel.c -o build/kernel_c.o
aarch64-linux-gnu-gcc -Iinclude -g -DUSE_QEMU -MMD -c src/utils.S -o build/utils_s.o
aarch64-linux-gnu-gcc -Iinclude -g -DUSE_QEMU -MMD -c src/mm.S -o build/mm_s.o
aarch64-linux-gnu-gcc -Iinclude -g -DUSE_QEMU -MMD -c src/boot.S -o build/boot_s.o
aarch64-linux-gnu-ld -T src/linker-qemu.ld -o build/kernel8.elf  build/mini_uart_c.o build/printf_c.o build/kernel_c.o build/utils_s.o build/mm_s.o build/boot_s.o
aarch64-linux-gnu-objcopy build/kernel8.elf -O binary kernel8.img
```

# run

```
root@ubuntu:~/arm/p1-kernel/src/lesson02# qemu-system-aarch64 -machine raspi3 -serial null -serial mon:stdio -nographic -kernel kernel8.img
Exception level: 1 
QEMU: Terminated
root@ubuntu:~/arm/p1-kernel/src/lesson02# qemu-system-aarch64 -machine raspi3 -serial null -serial mon:stdio -nographic -kernel kernel8.img
Exception level: 1 

```