## 5.3: Exercises

When a task is executed in user mode, try to access some of the system registers. Make sure that a synchronous exception is generated in this case. Handle this exception, use `esr_el1` register to distinguish it from a system call.

Backport E0->EL1 switch to exp2.

Add tracing to kernel. Output in ftrace format which can be plotted using various tools. 

Implement sleep()