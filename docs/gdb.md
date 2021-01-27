# Using GDB to debug kernel 

**Note (WSL users)**: It seems GDB server does not play well with WSL… see below. 

## Installation 

Linux or WSL: 
```
sudo apt install gdb-multiarch gcc-aarch64-linux-gnu build-essential 
```
Note: the gdb for aarch64 is not called aarch64-XXXX-gdb.

## Launch 

From one terminal 

```
qemu-system-aarch64 -M raspi3 -kernel ./kernel8.img -serial null -serial stdio -s -S 
```

From another terminal (the elf is needed if we need debugging info)

```
gdb-multiarch build/kernel8.elf 
(gdb) target remote :1234 
(gdb)layout asm 
```

Single step 

```
(gdb) si 
```

![gdb-si](images/gdb-si.png)

## Dump register contents

```
(gdb) info reg 
```

![gdb-reg](images/gdb-reg.png)


show reg information at each step. This example shows 
```
display/10i $sp
```

![gdb-si-display](images/gdb-si-display.gif)

## Dump memory

dump memory as instructions; can also specify raw addr 

```
x/20i _start
```
where `_start` is a symbol name 

dump memory as hex (bytes)
```
x/20xb _start
```

dump memory as hex (words)
```
x/20xw _start
```

## Set a breakpoint at addr

```
b *0xffff0000
```

## Function/source lookup

find out function name at a given addr
```
info line *0x10000000
```

list source at a given addr
```
list *0x10000000
```



## Troubleshooting 

"gdbserver: Target description specified unknown architecture “aarch64” 
https://stackoverflow.com/questions/53524546/gdbserver-target-description-specified-unknown-architecture-aarch64 
It seems GDB server does not play well with WSL… be aware! 

## Reference 

Launch qemu with gdb 

https://en.wikibooks.org/wiki/QEMU/Debugging_with_QEMU#Launching_QEMU_from_GDB 

more info about gdb for kernel debuggging 

https://wiki.osdev.org/Kernel_Debugging 