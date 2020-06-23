#include "printf.h"
#include "timer.h"
#include "irq.h"
#include "mini_uart.h"

#include "peripherals/irq.h" // xzl
#include "peripherals/timer.h" // xzl
#include "utils.h"

/* copied over */
#define MMIO_BASE       0x3F000000

#define SYSTMR_LO        ((volatile unsigned int*)(MMIO_BASE+0x00003004))
#define SYSTMR_HI        ((volatile unsigned int*)(MMIO_BASE+0x00003008))


#define GPU_INTERRUPTS_ROUTING ((volatile unsigned int *)(0x4000000C))
#define CORE0_INTERRUPT_SOURCE ((volatile unsigned int*)(0x40000060))

/**
 * Get System Timer's counter
 */
unsigned long get_system_timer()
{
    unsigned int h=-1, l;
    // we must read MMIO area as two separate 32 bit reads
    h=*SYSTMR_HI;
    l=*SYSTMR_LO;
    // we have to repeat it if high word changed during read
    if(h!=*SYSTMR_HI) {
        h=*SYSTMR_HI;
        l=*SYSTMR_LO;
    }
    // compose long int value
    return ((unsigned long) h << 32) | l;
}

void kernel_main(void)
{
	unsigned long t;

	uart_init();
	init_printf(0, putc);

	int el = get_el();
	printf("printf init ok, EL %d\n", el);

	irq_vector_init();
	timer_init();
	enable_interrupt_controller();


	printf("pending %u %u %u %u %u\n",
					get32(IRQ_BASIC_PENDING),
					get32(IRQ_PENDING_1),
					get32(IRQ_PENDING_2),
					get32(TIMER_C1),
					get32(TIMER_CS));


	// IRQ routeing to CORE0.
	*GPU_INTERRUPTS_ROUTING = 0x00;

	enable_irq();

	printf("irq init ok\n");

	t = get_system_timer();
	//printf("Not available\n");
	printf("t=%d\n",t);

	while (1){
		uart_send(uart_recv());

		t = get_system_timer();
		//printf("Not available\n");
		printf("t=%d pending %u %u %u %u %u\n",t,
				get32(IRQ_BASIC_PENDING),
				get32(IRQ_PENDING_1),
				get32(IRQ_PENDING_2),
				get32(TIMER_C1),
				get32(TIMER_CS)
		);
	}	
}
