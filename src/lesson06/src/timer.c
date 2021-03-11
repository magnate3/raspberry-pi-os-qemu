#include "utils.h"
#include "printf.h"
#include "sched.h"
#include "peripherals/timer.h"

const unsigned int interval = 200000;
unsigned int curVal = 0;

/* 
	These are for "System Timer". Note the caveats:
	Rpi3: System Timer works fine. Can generate intrerrupts and be used as a counter for timekeeping.
	QEMU: System Timer can be used for timekeeping. Cannot generate interrupts. 
		You may want to adjust @interval as needed
	cf: 
	https://fxlin.github.io/p1-kernel/lesson03/rpi-os/#fyi-other-timers-on-rpi3
*/

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

/* 	These are for Arm generic timer. 
	They are fully functional on both QEMU and Rpi3 
*/

//void generic_timer_init ( void )
//{
//	gen_timer_init();
//	gen_timer_reset();
//}
//
//void handle_generic_timer_irq( void )
//{
//	gen_timer_reset();
//	timer_tick();
//}

