# Prerequisites

[TOC]

## About the docs

Be aware: it contains URLs referring to the upstream git code repo, which may slightly differ from what we use. I will warn you. 

### Terms

baremetal

kernel?

kernel binary 

kernel image

## Dev environment

### Host OS

- Linux: Ubuntu 18.04
- Windows: WSL 
- OS X: (??)

### Toolchain

Use the one provided by Ubuntu. Save the hassle from compiling from source, etc.

```
$ sudo apt get install gcc-aarch64-linux-gnu 

$ aarch64-linux-gnu-gcc --version
aarch64-linux-gnu-gcc (Ubuntu/Linaro 7.5.0-3ubuntu1~18.04) 7.5.0
```

## Platform Setup 

### Approach A: QEMU

Needs QEMU (>v2.12). Newer is likely better. The following shows the default QEMU is too old. 

```
$ qemu-system-aarch64  --version
QEMU emulator version 2.11.1(Debian 1:2.11+dfsg-1ubuntu7.26)
Copyright (c) 2003-2017 Fabrice Bellard and the QEMU Project developers
```

Build QEMU from source if needed. 

```
sudo apt remove qemu-system-arm
sudo apt install gdb-multiarch build-essential
```

Grab source.  We use v4.2. 
```
git clone git://git.qemu.org/qemu.git
cd qemu
git checkout v4.2.0
./configure --target-list=aarch64-softmmu
make -j`nproc`
export PATH="$(pwd)/aarch64-softmmu:${PATH}"
```

Try QEMU & check its version. The supported machines should include Rpi3
```
$ qemu-system-aarch64  --version
QEMU emulator version 4.2.0 (v4.2.0-11797-g2890edc853-dirty)
Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers

$ qemu-system-aarch64 -M help|grep rasp
raspi2               Raspberry Pi 2
raspi3               Raspberry Pi 3
```

Test QEMU with Rpi3 baremetal code
**TBD**

### Approach B:  set up real hardware (Rpi3)

#### 1. [Raspberry Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)

Older versions of Raspberry Pi are not going to work with this tutorial because all lessons are designed to use a 64-bit processor that supports ARMv8 architecture, and such processor is only available in the Raspberry Pi 3. Newer versions, including [Raspberry Pi 3 Model B+](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/) should work fine, though I haven't tested it yet.

#### 2. [USB to TTL serial cable](https://www.amazon.com/s/ref=nb_sb_noss_2?url=search-alias%3Daps&field-keywords=usb+to+ttl+serial+cable&rh=i%3Aaps%2Ck%3Ausb+to+ttl+serial+cable) 

After you get a serial cable, you need to test your connection. If you never did this before I recommend you to follow [this guide](https://cdn-learn.adafruit.com/downloads/pdf/adafruits-raspberry-pi-lesson-5-using-a-console-cable.pdf) It describes the process of connecting your Raspberry PI via a serial cable in great details. 

The guide also describes how to power your Raspberry Pi using a serial cable. RPi OS works fine with such kind of setup, however, in this case you need to run your terminal emulator right after you plug in the cable. Check [this](https://github.com/s-matyukevich/raspberry-pi-os/issues/2)
 issue for details..

### 3. [SD card](https://www.raspberrypi.org/documentation/installation/sd-cards.md) with installed [Raspbian OS](https://www.raspberrypi.org/downloads/raspbian/)

We need Raspbian to test USB to TTL cable connectivity initially. Another reason is that after installation it leaves the SD card formatted in the right way.

### 4. Test the setup

(TBD)

<!--### 4. Docker
Strictly speaking, Docker is not a required dependency. It is just convenient to use Docker to build source code of the lessons, especially for Mac and Windows users. Each lesson has `build.sh` script (or `build.bat` for windows users) This script uses Docker to build source code of the lesson. Instructions how to install docker for your platform can be found on the [official docker website]
(https://docs.docker.com/engine/installation/)  If for some reasons you want to avoid using Docker, you can install the [make utility](http://www.math.tau.ac.il/~danha/courses/software1/make-intro.html) as well as  `aarch64-linux-gnu` toolchain. If you are using Ubuntu you just need to install `gcc-aarch64-linux-gnu` and `build-essential` packages.
-->

**Previous Page**

[Contribution guide](../docs/Contributions.md)

**Next Page**

1.1 [Kernel Initialization: Introducing RPi OS, or bare metal "Hello, world!"](../docs/lesson01/rpi-os.md)
