# QEMU cheetsheet

## Add QEMU to PATH

```
# assuming the qemu source tree has been built, and it is under ./qemu
export PATH="$(pwd)/qemu/aarch64-softmmu:${PATH}"
```

## Launch the kernel 
```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio
```
Explanation: 
* -M machine type
* Two "-serial" options correspond to the two UARTs of Rpi3 as emulated by QEMU. Our kernel writes message to the 2nd one. So we tell QEMU to redirect the 2nd UART to stdio. 

## Launch the kernel in debug mode

```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -s -S
```

## Launch the kernel with monitor 
```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -monitor stdio
```

## Run the kernel with tracing 
```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -d int -D qemu.log 
```
Explanation: -d int ---> enable interrupt dedug       -D test.log  ----> put debug msg to a file "qemu.log"

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

To use: 

```
$ source env-qemu.sh
# change to dir where kernel8.img resides

$ run
VNC server running on 127.0.0.1:5900
kernel boots...
interval is set to: 67108864
```



## Reference

https://wiki.osdev.org/QEMU

