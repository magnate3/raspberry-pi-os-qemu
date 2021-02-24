#include "printf.h"
#include "timer.h"
#include "irq.h"
#include "mini_uart.h"
#include "utils.h"
#include "lfb.h"

void kernel_main(void)
{
	char c = 0; 

	uart_init();
	init_printf(0, putc);
	printf("kernel boots...\n");

	irq_vector_init();
	generic_timer_init();
	enable_interrupt_controller();
	enable_irq();

    lfb_init();
    lfb_showpicture();     // display a pixmap

	printf("done show picture\n");

	while (1) {
		printf("+:resize viewport; *:max viewport; /:yoffset\n\r");
		c = uart_recv();
		uart_send(c);

		switch(c) {
			case '+':
				width += 50;
				if (width > vwidth)
					width = 100; 
				height += 50;
				if (height > vheight)
					height = 100; 
			break;
			case '*':
				width = vwidth; 
				height = vheight; 
			break;			
			case '/':
				if ((offsety += 50) > vheight)
					offsety = 0;
				printf("set offsety = %u\n\r", offsety);
				lfb_update2();  
			break;
		}
		delay(50 * 5000);
		// printf("lfb_update2\n\r");
		// lfb_update2();
	}	
}
