#include "utils.h"
#include "printf.h"
#include "sched.h"
#include "peripherals/timer.h"
#include "timer.h"

#ifdef USE_QEMU
unsigned int interval = (1 << 26); // xzl: around 1 sec
#else
unsigned int interval = 1 * 1000 * 1000; // xzl: around 1 sec
#endif

/* 	These are for Arm generic timer. 
	They are fully functional on both QEMU and Rpi3 
	Recommended.
*/
void generic_timer_init ( void )
{
	printf("interval is set to: %u\r\n", interval);
	gen_timer_init();
	gen_timer_reset(interval);
}

void handle_generic_timer_irq( void ) 
{
	gen_timer_reset(interval);
    timer_tick();
}

/* 
	These are for "System Timer". They are NOT in use by this project. 
	I leave the code here FYI. 
	Rpi3: System Timer works fine. Can generate intrerrupts and be used as a counter for timekeeping.
	QEMU: System Timer can be used for timekeeping. Cannot generate interrupts. 
		You may want to adjust @interval as needed
	cf: 
	https://fxlin.github.io/p1-kernel/lesson03/rpi-os/#fyi-other-timers-on-rpi3
*/
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
	timer_tick();
}