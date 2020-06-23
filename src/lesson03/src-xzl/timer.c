#include <stdint.h>

#include "irq.h"
#include "utils.h"
#include "printf.h"
#include "peripherals/timer.h"

const unsigned int interval = 200000;
//const unsigned int interval = 0;
unsigned int curVal = 0;

static uint32_t cntfrq = 0;

// core specific stuffs
#define CORE0_TIMER_IRQCNTL 0x40000040
#define CORE0_IRQ_SOURCE    0x40000060

void routing_core0cntv_to_core0irq(void)
{
    put32(CORE0_TIMER_IRQCNTL, 0x08);
}

uint32_t read_core0timer_pending(void)
{
    uint32_t tmp;
    tmp = get32(CORE0_IRQ_SOURCE);
    return tmp;
}

// xzl: turn on irq
// https://developer.arm.com/docs/ddi0595/latest/aarch64-system-registers/cntv_ctl_el0
// enable: bit 0
void enable_cntv(void)
{
    uint32_t cntv_ctl;
    cntv_ctl = 1;
	asm volatile ("msr cntv_ctl_el0, %0" :: "r" (cntv_ctl));
}

void disable_cntv(void)
{
    uint32_t cntv_ctl;
    cntv_ctl = 0;
	asm volatile ("msr cntv_ctl_el0, %0" :: "r" (cntv_ctl));
}

// xzl "Counter-timer Virtual Count register"
// https://developer.arm.com/docs/ddi0595/g/aarch64-system-registers/cntvct_el0
uint64_t read_cntvct(void)
{
	uint64_t val;
	asm volatile("mrs %0, cntvct_el0" : "=r" (val));
	return (val);
}

// xzl: read timer value, which will auto decrement
// cntv: EL1 virtual time; tval: timer value
uint32_t read_cntv_tval(void)
{
    uint32_t val;
	asm volatile ("mrs %0, cntv_tval_el0" : "=r" (val));
    return val;
}

// xzl: write to the timer value reg -- will add to comparator
void write_cntv_tval(uint32_t val)
{
	asm volatile ("msr cntv_tval_el0, %0" :: "r" (val));
    return;
}

// xzl: CNTFRQ_EL0 reports the frequency of the system count
uint32_t read_cntfrq(void)
{
    uint32_t val;
	asm volatile ("mrs %0, cntfrq_el0" : "=r" (val));
    return val;
}


void handle_timer_irq_old( void )
{
	curVal += interval;
	put32(TIMER_C1, curVal);
	put32(TIMER_CS, TIMER_CS_M1);
	printf("Timer interrupt received\n\r");
}

void timer_init ( void )
{
	curVal = get32(TIMER_CLO);
	curVal += interval;
	put32(TIMER_C0, curVal);
	put32(TIMER_C1, curVal);

	put32(TIMER_CS, 0x0);

	// xzl:
    uint32_t val;

    //uart_puts("CNTFRQ  : ");
    cntfrq = read_cntfrq();
    //uart_hex_puts(cntfrq);
    printf("CNTFRQ  : %d\n", cntfrq);

    write_cntv_tval(cntfrq);    // clear cntv interrupt and set next 1 sec timer.
//    uart_puts("CNTV_TVAL: ");
    val = read_cntv_tval();
//    uart_hex_puts(val);
    printf("CNTV_TVAL  : %d\n", val);

    routing_core0cntv_to_core0irq();
    enable_cntv();
}


void handle_timer_irq(void)
{
    uint32_t cntvct;
    uint32_t val;
    int el;

    disable_irq();
    if (read_core0timer_pending() & 0x08 ) {
//        uart_puts("handler CNTV_TVAL: ");

    	el = get_el();

    	printf("handling irq at EL %d handler CNTV_TVAL: ", el);
        val = read_cntv_tval(); // tval is decrementing from its most recent write
        //uart_hex_puts(val);
        printf("%x\n", val);

        // xzl: "TVAL or CVAL is written, so that firing condition is no longer met"
        write_cntv_tval(cntfrq);    // clear cntv interrupt and set next 1sec timer.

//        uart_puts("handler CNTVCT   : ");
        printf("handler CNTVCT   : ");
        cntvct = read_cntvct();
//        uart_hex_puts(cntvct);
        printf("%x\n", cntvct);
    }
    enable_irq();
    return;
}

