#include "printf.h"
#include "timer.h"
#include "irq.h"
#include "mini_uart.h"
#include "utils.h"


void kernel_main(void)
{
	uart_init();
	init_printf(0, putc);
	printf("kernel boots...\n");

	irq_vector_init();
	generic_timer_init();
	enable_interrupt_controller();
	enable_irq();
	// disable_irq();

	// a = a / 0; 
	// asm("mrs x0, elr_el2"); // will trigger exception at EL1
	// asm("hvc #0");
	// asm("msr	hcr_el2, x0");

	//printf("going to call wfi...");
	//asm("wfi");
	//printf("we're back!");

	while (1){
		uart_send(uart_recv());
	}	
}
