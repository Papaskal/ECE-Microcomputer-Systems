
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

    uint32_t led_value = 0;
    uint32_t buttons_value = 0;
    uint32_t switches_value = 0;

    int a, b, c, d, f0, f1, f2;

    while(1) {

        switches_value = XGpio_DiscreteRead(&switches_inst, 1);
        a = switches_value & 0x01;
        b = (switches_value >> 1) & 0x01;
        c = (switches_value >> 2) & 0x01;
        d = (switches_value >> 3) & 0x01;
    
        f0 = !(a&&b || b&&c || c&&d || d&&a);   //Epeidh asxoloumaste mono me to teleytaio bit
        f1 = (a&&b&&c&&d || !d && !a);          //kai ta a,b,c,d exoun perasei apo maska 0x01, den exei diafora 
        f2 = f0 || f1;                          //an 8a xrhsimopoihsoume genikes logikes prakseis h bitwise

        led_value = (f2<<2) | (f1<<1) | f0;
    	XGpio_DiscreteWrite(&leds_inst, 1, led_value = led_value);		
    }

    cleanup_platform();
    return 0;
}
