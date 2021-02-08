# QEMU cheetsheet

## Add QEMU to PATH

```
# assuming the qemu source tree has been built, and it is under ./qemu
export PATH="$(pwd)/qemu/aarch64-softmmu:${PATH}"

# (optional: grab a sample kernel binary for testing)
wget https://github.com/fxlin/p1-kernel/releases/download/exp1/kernel8.img
```

Explanation: the `export` command adds the path to QEMU to the search paths, so that whenever you type `qemu-system-aarch64`, the shell can find it. You may want to add the line to `~/.bashrc` so it is executed whenever you log in to the server

`echo export PATH="$(pwd)/aarch64-softmmu:${PATH}" >> ~/.bashrc`

To test if the QEMU path is added to PATH.

```
$ whereis qemu-system-aarch64
qemu-system-aarch64: /home/xzl/qemu/aarch64-softmmu/qemu-system-aarch64
```
Note the output path is just an example from my machine.
 
## Launch the kernel, free run

```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio

# if you want to suppress graphics ... 
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -nographic
```
Explanation: 
* -M machine type
* Two "-serial" options correspond to the two UARTs of Rpi3 as emulated by QEMU. **Note:** Our kernel writes message to the 2nd one. So we tell QEMU to redirect the 2nd UART to stdio. 

## Launch the kernel, for GDB debugging 

```
# will wait for gdb to connect at local tcp 1234
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -s -S

# will wait for gdb to connect at local tcp 5678
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -gdb tcp::5678 -S
```
Explanation: -S not starting the guest until you tell it to from gdb. 
-s listening for an incoming connection from gdb on TCP port 1234

The second form is useful in that if multiple students attempt to listen on tcp port 1234 on the same machine, all but one will fail. 

## Launch the kernel with monitor 
```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -monitor stdio
# multiplex both board serial and monitor output on stdio
qemu-system-aarch64 -machine raspi3 -serial null -serial mon:stdio -kernel kernel8.img
```
More on [the monitor mode](https://en.wikibooks.org/wiki/QEMU/Monitor). 

## Launch the kernel with tracing 
```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -d int -D qemu.log 
```
Explanation: -d int ---> enable interrupt dedug       -D test.log  ----> put debug msg to a file "qemu.log"

Sample log from executing  p1exp3:

```
Exception return from AArch64 EL2 to AArch64 EL1 PC 0x80038
Taking exception 5 [IRQ]
...from EL1 to EL1
...with ESR 0x0/0x0
...with ELR 0x8095c
...to EL1 PC 0x81a80 PSTATE 0x3c5
Exception return from AArch64 EL1 to AArch64 EL1 PC 0x8095c
Taking exception 5 [IRQ]
...from EL1 to EL1
...with ESR 0x0/0x0
...with ELR 0x8095c
...to EL1 PC 0x81a80 PSTATE 0x3c5
Exception return from AArch64 EL1 to AArch64 EL1 PC 0x8095c
Taking exception 5 [IRQ]
...from EL1 to EL1
...with ESR 0x0/0x0
...with ELR 0x8095c
...to EL1 PC 0x81a80 PSTATE 0x3c5
Exception return from AArch64 EL1 to AArch64 EL1 PC 0x8095c
Taking exception 5 [IRQ]
...from EL1 to EL1
...with ESR 0x0/0x0
...with ELR 0x8095c
...to EL1 PC 0x81a80 PSTATE 0x3c5
Exception return from AArch64 EL1 to AArch64 EL1 PC 0x8095c
```

Explanation: ESR - exception syndrome register, encoding the cause of the exception. ELR - exception link register, containing the return address of the exception handler. PSTATE - CPU flags when the exception is taken 

## Putting everything in one file (env-qemu.sh)

```
# change the line as needed
export PATH="$(pwd)/qemu/aarch64-softmmu:${PATH}"

run-uart0() {
   qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial stdio
}

run() {
    qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio
}

run-mon() {
    qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -monitor stdio
}

run-debug() {
    qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -s -S
}
```

To use: every time when you log in to the server and wants to develop the kernel

```
# switch to dir where the qemu source directory is qemu/
$ source env-qemu.sh

# switch to dir where kernel8.img resides
$ run
VNC server running on 127.0.0.1:5900
kernel boots...
interval is set to: 67108864
```



## Reference

https://wiki.osdev.org/QEMU

All QEMU options: https://github.com/qemu/qemu/blob/master/qemu-options.hx

