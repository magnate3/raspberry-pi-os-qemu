# A tiny, modern kernel for Raspberry Pi 3 

https://fxlin.github.io/p1-kernel/

A tiny kernel *incrementally built* for OS education. 

Start with minimal, baremetal code. Then add kernel features in small doses. 

Each experiment is a self-contained and can run on both Rpi3 hardware and QEMU. 

## Rationale

The kernel must run on cheap & modern hardware. 

Showing the kernel's evolution path is important. Along the path, each version must be self-contained runnable. 

We deem the following kernel functions crucial to implement: 
* protection modes
* interrupt handling
* preemptive scheduling
* virtual memory 

Experimenting with these features is difficult with commodity kernels due to their complexity. 

## Goals

**Primary:** 
* Learning by doing: the core concepts of a modern OS kernel
* Experiencing OS engineering: hands-on programming & debugging at the hardware/software boundary
* Daring to plumb: working with baremetal hardware: CPU protection modes, registers, IO, MMU, etc.

**Secondary:**
* Armv8 programming. Arm is everywhere, including future Mac. 
* Working with C and assembly 
* Cross-platform development 

**Non-goals:**
* Non-core or advanced functions of OS kernel, e.g. filesystem or power management, which can be learnt via experimenting with commodity OS. 
* Rpi3-specific hardware details. The SoC of Rpi3 is notoriously unfriendly to kernel hackers. 
* Implementation details of commodity kernels, e.g. Linux or Windows.  

<!---- to complete --->

## Experiments
0. **[Sharpen your tools!](lesson00/rpi-os.md)** (p1 exp0) 
1. **Helloworld from baremetal** (p1 exp1) 
      * [Power on + UART bring up](lesson01/rpi-os.md)
      * [Simplifying dev workflow](lesson01/workflow.md)
2. **Exception elevated** (p1 exp2) 
      * [CPU initialization, exception levels](lesson02/rpi-os.md)
3. **Heartbeats on** (p1 exp3) 
      * [Interrupt handling](lesson03/rpi-os.md)
4. **Process scheduler** (p1 exp4) 
      * [A. Cooperative](lesson04a/rpi-os.md) 
      * [B. Preemptive](lesson04b/rpi-os.md) 
5. **A world of two lands** (p1 exp5) 
      * [User processes and system calls](lesson05/rpi-os.md) 
6. **Into virtual** (p1 exp6) 
      * [Virtual memory management](lesson06/rpi-os.md) 

## Assignment weights

| Exp                                 | Weights |
| ----------------------------------- | ------- |
| 00 Sharpen your tools               | 10      |
| 01 Helloworld from baremetal        | 10      |
| 02 Exception elevated               | 10      |
| 03 Heartbeats on                    | 10      |
| 04a Process scheduler - cooperative | 10      |
| 04b Process scheduler - preemptive  | 10      |
| 05 A world of two lands             | 20      |
| 06 Into virtual                     | 20      |

The weights are relative and may not necessarily add up to 100. 

## Acknowledgement
Derived from the RPi OS project and its tutorials, which is modeled after the [Linux kernel](https://github.com/torvalds/linux). 