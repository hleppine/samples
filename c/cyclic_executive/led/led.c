/*
 * led.c
 *
 *  Created on: Oct 29, 2016
 *      Author: hleppine
 */

#include <avr/io.h>

#include "led.h"


void led_init(void){

    /* set pin 5 of PORTB for output*/
    DDRB |= _BV(DDB5);

}


void led_set(led_state_t state){

	switch (state){

	case LED_OFF:
        /* set pin 5 low to turn led off */
        PORTB &= ~_BV(PORTB5);
        break;

	case LED_ON:
    	/* set pin 5 high to turn led on */
    	PORTB |= _BV(PORTB5);
		break;

	}

}
