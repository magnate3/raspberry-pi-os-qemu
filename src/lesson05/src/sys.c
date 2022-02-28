#include "fork.h"
#include "printf.h"
#include "utils.h"
#include "sched.h"
#include "mm.h"

void sys_write(char * buf){
	printf(buf);
}

int sys_clone(unsigned long stack){
	/* create a blank task and we're done. the fn and arg will be set right after returning to
	the calling task, cf: thread_start() in sys.S */
	return copy_process(0 /*clone_flags*/, 0 /*fn*/, 0 /*arg*/, stack);
}

unsigned long sys_malloc(){
	unsigned long addr = get_free_page();
	if (!addr) {
		return -1;
	}
	return addr;
}

void sys_exit(){
	exit_process();
}

void * const sys_call_table[] = {sys_write, sys_malloc, sys_clone, sys_exit};
