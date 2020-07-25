## 5.3: Exercises

1. When a task is executed in user mode, try to access some of the system registers. Make sure that a synchronous exception is generated in this case. Handle this exception, use `esr_el1` register to distinguish it from a system call.

2. Backport the switch of E0->EL1 to exp2. As a result, the kernel in exp2 can switch from EL1 to EL0 and then from EL0 to EL1. 

3. Implement a sleep() syscall. See its interface [here](https://man7.org/linux/man-pages/man3/sleep.3.html). You do not have to implement the signal part. 

<!--- Add tracing to kernel. Output in ftrace format which can be plotted using various tools. --->