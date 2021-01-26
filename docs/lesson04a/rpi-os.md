# 4a: Cooperative Multitasking

We will build a minimum kernel that can schedule multiple cooperative tasks. 

![](qemu-sched.gif)

## Roadmap
From this experiment onward, our kernel starts to schedule multiple tasks. This makes it a true "kernel" instead of a baremetal program. 

We will intentionally leave out interrupts, i.e. **timer interrupts are OFF**. Tasks must voluntarily yield to each other. As a result, we focus on scheduling and task switch and defer treatment of interrupt handling to upcoming experiment. . 

We will implement: 

1. The `task_struct` data structure 
2. Task creation by manipulating `task_struct`, registers, and stack
3. Minimalist memory allocation
4. A minimalist task scheduler 
   <!--- counter. must be maintained in timer_tick() for accounting ... --->

**Processes vs tasks**. As we do not have virtual memory yet, we use the term "tasks" instead of "processes". 

## Code Walkthrough

### task_struct

To manage tasks, the first thing we should do is to create a struct that describes a task. Linux has such a struct and it is called `task_struct`  (in Linux both thread and processes are just different types of tasks; the difference is in how they share address spaces). As we are mostly mimicking Linux implementation, we are going to do the same. Our [task_struct](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/include/sched.h#L36) looks like the following.

```
struct cpu_context {
    unsigned long x19;
    unsigned long x20;
    unsigned long x21;
    unsigned long x22;
    unsigned long x23;
    unsigned long x24;
    unsigned long x25;
    unsigned long x26;
    unsigned long x27;
    unsigned long x28;
    unsigned long fp;
    unsigned long sp;
    unsigned long pc;
};

struct task_struct {
    struct cpu_context cpu_context;
    long state;
    long counter;
    long priority;
    long preempt_count;
};
```

This struct has the following members:

* `cpu_context` This is an embedded structure that contains values of all registers that might be different between the tasks, that are being switched. A reasonable question to ask is why do we save not all registers, but only registers `x19 - x30` and `sp`? (`fp` is `x29` and `pc` is `x30`) The answer is that task switch happens only when a task calls [cpu_switch_to](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.S#L4) function. So, from the point of view of the task that is being switched, it just calls `cpu_switch_to` function and it returns after some (potentially long) time. The "switched from" task doesn't notice that another task happens to runs during this period.  Accordingly to ARM calling conventions registers `x0 - x18` can be overwritten by the callee, so the caller must not assume that the values of those registers will survive after a function call. That's why it doesn't make sense to save `x0 - x18` registers.
* `state` This is the state of the currently running task (note: this is NOT CPU state which is an orthogonal concept). For tasks that are just doing some work on the CPU the state will always be [TASK_RUNNING](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/include/sched.h#L15). Actually, this is the only state that the RPi OS is going to support for now. Later we may add a few additional states. For example, a task that is waiting for an interrupt should be moved to a different state, because it doesn't make sense to awake the task while the required interrupt hasn't yet happened.
* `counter` This field is used to determine how long the current task has been running. `counter` decreases by 1 each timer tick and when it reaches 0 another task is scheduled. This supports our simple scheduling algorithm.
* `priority`  When a new task is scheduled its `priority` is copied to `counter`. By setting tasks priority, we can regulate the amount of processor time that the task gets relative to other tasks.
* `preempt_count` If this field has a non-zero value it is an indicator that right now the current task is executing some critical function that must not be interrupted (for example, it runs the scheduling function.). If timer tick occurs at such time it is ignored and rescheduling is not triggered.

After the kernel startup, there is only one task running: the one that runs [kernel_main](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/kernel.c#L19) function. It is called "init task". Before the scheduler functionality is enabled, we must fill `task_struct` corresponding to the init task. This is done [here](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/include/sched.h#L53).

All `task_struct`s are stored in [task](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.c#L7) array. This array has only 64 slots - that is the maximum number of simultaneous tasks that we can have in the RPi OS. It is definitely not the best solution for the production-ready OS, but it is ok for our goals.

A very important global variable called [current](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.c#L6) that always points to the `task_struct` of currently executing task. Both `current` and `task` array are initially set to hold a pointer to the init task. There is also a global variable called [nr_tasks](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.c#L8) - it contains the number of currently running tasks in the system.

Those are all structures and global variables that we are going to use to implement the scheduler functionality. In the description of the `task_struct` I already briefly mentioned some aspects of how scheduling works, because it is impossible to understand the meaning of a particular `task_struct` field without understanding how this field is used. Now we are going to examine the scheduling algorithm in much more details and we will start with the `kernel_main` function.

### `kernel_main()`

Before we dig into the scheduler implementation, I want to quickly show you how we are going to prove that the scheduler actually works. To understand it, you need to take a look at the [kernel.c](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/kernel.c) file. Let me copy the relevant content here.

```
void kernel_main(void)
{
    uart_init();
    init_printf(0, putc);
    irq_vector_init();

    int res = copy_process((unsigned long)&process, (unsigned long)"12345");
    if (res != 0) {
        printf("error while starting process 1");
        return;
    }
    res = copy_process((unsigned long)&process, (unsigned long)"abcde");
    if (res != 0) {
        printf("error while starting process 2");
        return;
    }

    while (1){
        schedule();
    }
}
```

There are a few important things about this code.

1. New function [copy_process](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/fork.c#L5) is introduced. `copy_process` takes 2 arguments: a function to execute in a new thread and an argument that need to be passed to this function. `copy_process` allocates a new `task_struct`  and makes it available for the scheduler.
1. Another new function for us is called [schedule](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.c#L21). This is the core scheduler function: it checks whether there is a new task that needs to preempt the current one. In cooperative scheduling, a task voluntarily calls `schedule` if it doesn't have any work to do at the moment. Spoiler: for preemptive multitasking, `schedule` is also called from the timer interrupt handler.

We are calling `copy_process` 2 times, each time passing a pointer to the [process](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/kernel.c#L9) function as the first argument. `process` function is very simple.

```
void process(char *array)
{
    while (1){
        for (int i = 0; i < 5; i++){
            uart_send(array[i]);
            delay(100000);
            schedule();
        }
    }
}
```

It just keeps printing on the screen characters from the array, that is passed as an argument The first time it is called with the argument "12345" and second time the argument is "abcde". After printing out a string, a task yields to others by calling `schedule()`. If our scheduler implementation is correct, we should see on the output from both threads.

### Switching tasks (sched.c & sched.S)

This is where the magic happens. The code looks like this.

```
void switch_to(struct task_struct * next)
{
    if (current == next)
        return;
    struct task_struct * prev = current;
    current = next;
    cpu_switch_to(prev, next);
}
```

Here we check that next process is not the same as the current, and if not, `current` variable is updated. The actual work is redirected to [cpu_switch_to](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/sched.S) function. It is in assembly as it manipulates registers. 

```
.globl cpu_switch_to
cpu_switch_to:
    mov    x10, #THREAD_CPU_CONTEXT
    add    x8, x0, x10
    mov    x9, sp
    stp    x19, x20, [x8], #16        // store callee-saved registers
    stp    x21, x22, [x8], #16
    stp    x23, x24, [x8], #16
    stp    x25, x26, [x8], #16
    stp    x27, x28, [x8], #16
    stp    x29, x9, [x8], #16
    str    x30, [x8]
    add    x8, x1, x10
    ldp    x19, x20, [x8], #16        // restore callee-saved registers
    ldp    x21, x22, [x8], #16
    ldp    x23, x24, [x8], #16
    ldp    x25, x26, [x8], #16
    ldp    x27, x28, [x8], #16
    ldp    x29, x9, [x8], #16
    ldr    x30, [x8]
    mov    sp, x9
    ret
```

This is the place where the real context switch happens. Let's examine it line by line.

```
    mov    x10, #THREAD_CPU_CONTEXT
    add    x8, x0, x10
```

<!--- need a figure --->

`THREAD_CPU_CONTEXT` constant contains offset of the `cpu_context` structure in the `task_struct`. `x0` contains a pointer to the first argument, which is the current `task_struct` (i.e. the "switch_from" task).  After the copied 2 lines are executed, `x8` will contain a pointer to the current `cpu_context`.

```
    mov    x9, sp
    stp    x19, x20, [x8], #16        // store callee-saved registers
    stp    x21, x22, [x8], #16
    stp    x23, x24, [x8], #16
    stp    x25, x26, [x8], #16
    stp    x27, x28, [x8], #16
    stp    x29, x9, [x8], #16
    str    x30, [x8]
```

Next all callee-saved registers are stored in the order, in which they are defined in `cpu_context` structure. The current stack pointer is saved as `cpu_context.sp` and `x29` is saved as `cpu_context.fp` (frame pointer).

Note: `x30`, the link register containing function return address, is stored as `cpu_context.pc`. Why?

Now we calculate the address of the next task's `cpu_context`: 

```
    add    x8, x1, x10
```

This a cute hack. `x10` contains an offset of the `cpu_context` structure inside `task_struct`, `x1` is a pointer to the next `task_struct`, so `x8` will contain a pointer to the next `cpu_context`.

Now, restore the CPU context of "switch_to" task from memory to CPU regs. A mirror procedure. 

```
    ldp    x19, x20, [x8], #16        // restore callee-saved registers
    ldp    x21, x22, [x8], #16
    ldp    x23, x24, [x8], #16
    ldp    x25, x26, [x8], #16
    ldp    x27, x28, [x8], #16
    ldp    x29, x9, [x8], #16
    ldr    x30, [x8]
    mov    sp, x9
    ret
```

After `ret`, kernel returns to the location pointed to by the link register (`x30`). If we are switching to a task for the first time, this will be [ret_from_fork](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/entry.S#L148) function. More on it below. In all other cases this will be the location, previously saved in the `cpu_context.pc` by the `cpu_switch_to` function. Think: which instruction does it point to? 

### Creating a new task

After seeing task switch, new task creation starts to make more sense. It is implemented in [copy_process](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/fork.c#L5) function.

Keep in mind: after `copy_process` finishes execution, no context switch happens. The function only prepares new `task_struct` and adds it to the `task` array — this task will be executed only after `schedule` function is called.

```
int copy_process(unsigned long fn, unsigned long arg)
{
    struct task_struct *p;

    p = (struct task_struct *) get_free_page();
    if (!p)
        return 1;
    p->priority = current->priority;
    p->state = TASK_RUNNING;
    p->counter = p->priority;

    p->cpu_context.x19 = fn;
    p->cpu_context.x20 = arg;
    p->cpu_context.pc = (unsigned long)ret_from_fork;
    p->cpu_context.sp = (unsigned long)p + THREAD_SIZE;
    int pid = nr_tasks++;
    task[pid] = p;
    return 0;
}
```

Now, we are going to examine it in details.

```
    struct task_struct *p;
```

The function starts with allocating a pointer for the new task. As interrupts are off, the kernel will not be interrupted in the middle of the `copy_process` function.

```
    p = (struct task_struct *) get_free_page();
    if (!p)
        return 1;
```

Next, a new page is allocated. At the bottom of this page, we are putting the `task_struct` for the newly created task. The rest of this page will be used as the task stack. A few lines below, `context.sp` is set as `p + THREAD_SIZE`. THREAD_SIZE is defined as 4KB. It is the total amount of memory for a task. The name, again, is following the Linux kernel convention. 

<!--- need a figure--->

```
    p->priority = current->priority;
    p->state = TASK_RUNNING;
    p->counter = p->priority;
```

After the `task_struct` is allocated, we can initialize its properties.  Priority and initial counters are set based on the current task priority. 

```
    p->cpu_context.x19 = fn;
    p->cpu_context.x20 = arg;
    p->cpu_context.pc = (unsigned long)ret_from_fork;
    p->cpu_context.sp = (unsigned long)p + THREAD_SIZE;
```

This is the most important part of the function. Here `cpu_context` is initialized. The stack pointer is set to the top of the newly allocated memory page. `pc`  is set to the [ret_from_fork](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/entry.S#L146) function, and we need to look at this function now in order to understand why the rest of the `cpu_context` registers are initialized in the way they are.

### ret_from_fork (entry.S)

This is the **first** piece of code executed by a newly created process. A new process P executes `ret_from_fork` after **it is switched to** for the first time. That is right after the scheduler picks P for the first time and restores P's CPU context from `task_struct` to CPU registers. Throughout its lifetime, P only executes `ret_from_fork` once. 

> About naming: despite the name "fork", we are not doing fork() as in Linux/Unix. We are simply copying a `task_struct` while fork() does far more things like duplicating process address spaces. The naming follows the Linux kernel convention; and we will evolve our `ret_from_fork` in subsequent experiments. 

```
.globl ret_from_fork
ret_from_fork:
    bl    schedule_tail // will talk about this later
    mov    x0, x20
    blr    x19         //should never return
```

Where do `x19` and `x20` come from? See code `copy_process` above, which saves `fn` (the process's main function) and `arg` (the argument passed to the process) to`task_struct`. When switching to P, the kernel restores `fn` and `arg` from `task_struct` to `x19` and `x20`. 

As a result, `ret_from_fork` calls the function stored in `x19` register with the argument stored in `x20`. 

### Aside: Memory allocation

Each task in the system should have its dedicated stack. That's why when creating a new task we must have a way to allocate memory. For now, our memory allocator is extremely primitive. (The implementation can be found in [mm.c](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/src/mm.c) file)

```
static unsigned short mem_map [ PAGING_PAGES ] = {0,};

unsigned long get_free_page()
{
    for (int i = 0; i < PAGING_PAGES; i++){
        if (mem_map[i] == 0){
            mem_map[i] = 1;
            return LOW_MEMORY + i*PAGE_SIZE;
        }
    }
    return 0;
}

void free_page(unsigned long p){
    mem_map[(p - LOW_MEMORY) / PAGE_SIZE] = 0;
}
```

The allocator can work only with memory pages (each page is 4 KB in size). There is an array called `mem_map` that for each page in the system holds its status: whether it is allocated or free. Whenever we need to allocate a new page, we just loop through this array and return the first free page. This implementation is based on 2 assumptions:

1. We know the total amount of memory in the system. It is `1 GB - 1 MB` (the last megabyte of memory is reserved for device registers.). This value is stored in the [HIGH_MEMORY](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/include/mm.h#L14) constant.
1. First 4 MB of memory are reserved for the kernel image and init task stack. This value is stored in [LOW_MEMORY](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/src/lesson04/include/mm.h#L13) constant. All memory allocations start right after this point.

> Note: even with QEMU our kernel must start from 0x80000 (512KB), the above assumptions are good as there's still plenty room in 512KB -- LOW_MEMORY for our tiny kernel.

### Scheduling algorithm

Finally, we are ready to look at the scheduler algorithm. I almost precisely copied this algorithm from the first release of the Linux kernel. You can find the original version [here](https://github.com/zavg/linux-0.01/blob/master/kernel/sched.c#L68).

```
void _schedule(void)
{
    int next,c;
    struct task_struct * p;
    while (1) {
        c = -1;
        next = 0;
        // try to pick a task
        for (int i = 0; i < NR_TASKS; i++){
            p = task[i];
            if (p && p->state == TASK_RUNNING && p->counter > c) {
                c = p->counter;
                next = i;
            }
        }
        if (c) {
            break;
        }
        // update counters
        for (int i = 0; i < NR_TASKS; i++) {
            p = task[i];
            if (p) {
                p->counter = (p->counter >> 1) + p->priority;
            }
        }
    }
    switch_to(task[next]);
}
```

The simple algorithm works like the following:

 * The first `for` loop iterates over all tasks and tries to find a task in `TASK_RUNNING` state with the maximum counter. If such a task is found, we immediately break from the `while` loop and switch to this task. 

 * If no such task is found, this is either because i) no task is in `TASK_RUNNING`  state or ii) all such tasks have 0 counters. In a real OS, i) might happen, for example, when all tasks are waiting for an interrupt. In our current tiny kernel, all tasks are always in `TASK_RUNNING` (Why?) 

 * The scheduler moves to the 2nd `for` loop to "recharge" counters. It bumps counters for all tasks once. The increment depends on a task's priority. Note: a task counter can never get larger than `2 * priority`.

* With updated counters, the scheduler goes back to the 1st `for` loop to pick a task. 

We will augment the scheduling algorithm for preemptive multitasking later. 

### Conclusion

We have seen important nuts & bolts of multitasking. The subsequent experiment will enable task preemption. We will show a detailed workflow of context switch there. 
