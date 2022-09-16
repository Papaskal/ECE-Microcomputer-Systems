
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

#define LEDS_DEV      XPAR_LEDS_DEVICE_ID
#define BUTTONS_DEV   XPAR_BUTTONS_DEVICE_ID
#define SWITCHES_DEV  XPAR_SWITCHES_DEVICE_ID

#define LED_DELAY     10000000*5

XGpio leds_inst;      // leds gpio driver instance
XGpio buttons_inst;   // buttons gpio driver instance
XGpio switches_inst;  // switches gpio driver instance

int main()
{
	int statusCodes = 0;

	uint32_t delay = 0;

    init_platform();

    /* Initialize the GPIO driver for the leds */
    statusCodes = XGpio_Initialize(&leds_inst, LEDS_DEV);
    if (statusCodes != XST_SUCCESS) {
		xil_printf("ERROR: failed to init LEDS. Aborting\r\n");
		return XST_FAILURE;
	}

    /* Initialize the GPIO driver for the buttons */
    statusCodes = XGpio_Initialize(&buttons_inst, BUTTONS_DEV);
    if (statusCodes != XST_SUCCESS) {
    	xil_printf("ERROR: failed to init BUTTONS. Aborting\r\n");
    	return XST_FAILURE;
    }

    /* Initialize the GPIO driver for the switches */
    statusCodes = XGpio_Initialize(&switches_inst, SWITCHES_DEV);
    if (statusCodes != XST_SUCCESS) {
    	xil_printf("ERROR: failed to init SWITCHES. Aborting\r\n");
    	return XST_FAILURE;
    }

    /* Set the direction for all led signals as outputs */
    XGpio_SetDataDirection(&leds_inst, 1, 0);

    /* Set the direction for all buttons signals as inputs */
    XGpio_SetDataDirection(&buttons_inst, 1, 1);

    /* Set the direction for all switches signals as inputs */
    XGpio_SetDataDirection(&switches_inst, 1, 1);

    uint32_t led_value = 0x01;
    uint32_t buttons_value = 0;
    uint32_t switches_value = 0;

    uint32_t state = 0;
    int i = 0;

    while(1) {
        XGpio_DiscreteWrite(&leds_inst, 1, led_value = led_value);
        buttons_value = XGpio_DiscreteRead(&buttons_inst, 1);
        state |= buttons_value;

        for (i=0; i<4; i++){
            if ((state & ~buttons_value) & (0x01 << i))
                break;
        }

        switch(i){
            case 0:
                led_value = ((led_value << 1) | (led_value >> 3) ) & 0x0F;
                state &= 0x0E;
                break;
            case 1:
                led_value = ((led_value >> 1) | (led_value << 3) ) & 0x0F;
                state &= 0x0D;
                break;
            case 2:
                led_value = 0x08;
                state &= 0x0B;
                break;
            case 3:
                led_value = 0x01;
                state &= 0x07;
        }

    }

    cleanup_platform();
    return 0;
}
