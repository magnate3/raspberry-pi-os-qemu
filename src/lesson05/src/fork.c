#include "mm.h"
#include "sched.h"
#include "printf.h"
#include "fork.h"
#include "entry.h"
#include "utils.h"

int copy_process(unsigned long clone_flags, unsigned long fn, unsigned long arg, unsigned long stack)
{
	preempt_disable();
	struct task_struct *p;

	p = (struct task_struct *) get_free_page();
	if (!p) {
		return -1;
	}

	struct pt_regs *childregs = task_pt_regs(p);
	memzero((unsigned long)childregs, sizeof(struct pt_regs));
	memzero((unsigned long)&p->cpu_context, sizeof(struct cpu_context));

	if (clone_flags & PF_KTHREAD) { /* kernel task, no pt_regs */
		p->cpu_context.x19 = fn;
		p->cpu_context.x20 = arg;
	} else {	/* user task, pop pt_regs which always at the task's user stack top */
		struct pt_regs * cur_regs = task_pt_regs(current);
		*cur_regs = *childregs;
		childregs->regs[0] = 0; /* return val of the clone() syscall */ 
		childregs->sp = stack + PAGE_SIZE; 
		p->stack = stack;
	}
	p->flags = clone_flags;
	p->priority = current->priority;
	p->state = TASK_RUNNING;
	p->counter = p->priority;
	p->preempt_count = 1; //disable preemtion until schedule_tail

	p->cpu_context.pc = (unsigned long)ret_from_fork;
	p->cpu_context.sp = (unsigned long)childregs;
	int pid = nr_tasks++;
	task[pid] = p;	
	preempt_enable();
	return pid;
}


int move_to_user_mode(unsigned long pc)
{
	/* convert a kernel task to a user task, which must have legit pt_regs */		
	struct pt_regs *regs = task_pt_regs(current);
	memzero((unsigned long)regs, sizeof(*regs));
	regs->pc = pc;
	regs->pstate = PSR_MODE_EL0t;
	
	/* alocate new user stack, in addition to the task's existing kernel stack */
	unsigned long stack = get_free_page(); 
	if (!stack) {
		return -1;
	}
	regs->sp = stack + PAGE_SIZE; 
	current->stack = stack;
	return 0;
}

struct pt_regs * task_pt_regs(struct task_struct *tsk){
	unsigned long p = (unsigned long)tsk + THREAD_SIZE - sizeof(struct pt_regs);
	return (struct pt_regs *)p;
}
