# A tiny, modern kernel for Raspberry Pi 3 built in small increments

## What is it: 

A tiny kernel that is incrementally built for OS education. 

Through a series of exps, we will core kernel features in small doses. 

Each experiment is a self-contained and can run on Rpi3 hardware and QEMU. 

## Rationale

The kernel must run on cheap & modern hardware. 

Showing the evolution path is important. On the path, each version must be runnable. 

Crucial kernel functions to implement: 

* protection modes

* interrupt handling

* preemptive scheduling

* virtual memory 

Experimenting with these features is difficult with commodity kernels due to their complexity. 

## Goals

**Primary:** 

* Learning by doing: the core concepts of a modern OS kernel. 

* Experience is crucial: programming & debugging experience at the hardware/software boundary

* Dare to plumb: working with baremetal hardware: CPU protection modes, registers, IO, MMU, etc.

**Secondary:**

* ARMv8 programming. ARM is everywhere. 

* Working with C and assembly 
* Cross-platform development 

**Non-goals:**

* Non-core or advanced functions of OS kernel, e.g. filesystem or power management, which shall be taught by experimenting with commodity OS. 

* Rpi3-specific hardware details. Rpi3 and its BCM SoC is notoriously unfriendly to kernel hackers. 

* Internals of commodity kernels. 

## Credits

Derived from the RPi OS project and its tutorials, which is said to modeled after the [Linux kernel](https://github.com/torvalds/linux). 

## Key docs

Board manual: Rpi3 board pinout

SoC manual: Bcm

ARM64: 

<!---- to complete --->

## Table of Contents


* **[Introduction](docs/Introduction.md)**

0. **[Platform setup](docs/lesson01/rpi-os.md)**
1. **Helloworld from Baremetal** 
      * [Power on + UART bring up](docs/lesson01/rpi-os.md)
      * [Simplifying dev workflow](docs/lesson01/workflow)
      * [Exercises](docs/lesson01/exercises.md)
1. **Exception elevated**
      * [CPU initialization, exception levels](docs/lesson02/rpi-os.md)
      * [Exercises](docs/lesson02/exercises.md)
1. **Kernel heartbeats on**
      * [Interrupt handling](docs/lesson03/rpi-os.md)
      * [Exercises](docs/lesson03/exercises.md)
1. **Process scheduler**
      * [A. Cooperative](docs/lesson04a/rpi-os.md) 
      * [B. Preemptive](docs/lesson04b/rpi-os.md) 
      * [Exercises](docs/lesson04/exercises.md)
1. **A world of two lands** 
      * [User processes and system calls](docs/lesson05/rpi-os.md) 
      * [Exercises](docs/lesson05/exercises.md)
1. **Into virtual **
      * [Virtual memory management](docs/lesson06/rpi-os.md) 
      * [Exercises](docs/lesson06/exercises.md)

