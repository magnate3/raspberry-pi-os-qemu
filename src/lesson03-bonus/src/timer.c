#include "utils.h"
#include "printf.h"
#include "peripherals/timer.h"
#include "timer.h"
#include "lfb.h"

//unsigned int interval = 9600000;
#ifdef USE_QEMU
unsigned int interval = (1 << 26); // xzl: around 1 sec
#else
// unsigned int interval = 1 * 1000 * 1000; // xzl: around 1 sec
unsigned int interval = 30 * 1000; // xzl: around 1 sec
#endif

unsigned int curVal = 0;

void timer_init ( void )
{
	curVal = get32(TIMER_CLO);
	curVal += interval;
	put32(TIMER_C1, curVal);
}

void handle_timer_irq( void ) 
{
	curVal += interval;
	put32(TIMER_C1, curVal);
	put32(TIMER_CS, TIMER_CS_M1);
	printf("Timer interrupt received\n\r");
}

// xzl: CNTFRQ_EL0 reports the frequency of the system count
static unsigned int read_cntfrq(void)
{
	unsigned int val;
	asm volatile ("mrs %0, cntfrq_el0" : "=r" (val));
  return val;
}

void generic_timer_init ( void )
{
//	interval = read_cntfrq();
//  printf("System count freq (CNTFRQ) is: %u\n", interval);

	printf("interval is set to: %u\n", interval);
	gen_timer_init();
	gen_timer_reset(interval);
}

void handle_generic_timer_irq( void ) 
{
	// printf("Timer interrupt received. next in %u ticks\n\r", interval);
	gen_timer_reset(interval);
	lfb_update2(); // refresh fb
}
