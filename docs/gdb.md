# On using GDB

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

From another terminal 

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

Dump register contents

```
(gdb) info reg 
```

![gdb-reg](images/gdb-reg.png)

## Troubleshooting 

"gdbserver: Target description specified unknown architecture “aarch64” 
https://stackoverflow.com/questions/53524546/gdbserver-target-description-specified-unknown-architecture-aarch64 
It seems GDB server does not play well with WSL… be aware! 

## Reference 

Launch qemu with gdb 

https://en.wikibooks.org/wiki/QEMU/Debugging_with_QEMU#Launching_QEMU_from_GDB 

more info about gdb for kernel debuggging 

https://wiki.osdev.org/Kernel_Debugging 