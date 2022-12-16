/*
 * task.c
 *
 *  Created on: Oct 30, 2016
 *      Author: hleppine
 */


#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <stdint.h>
#include <util/delay.h>

#include "led/led.h"

#ifndef TIMSK1
#define TIMSK1 _SFR_MEM8(0x6F) // Redefine to avoid eclipse error. Specific to atmega328p
#endif

static volatile bool start_cycle_now = false;


static void wait_until_end_of_cycle(){

	while(!start_cycle_now);

	start_cycle_now = false;

}


static void start_task_timer(void){

	TCCR1A = 0;
	TCCR1B = 0;
	TCNT1  = 0;

	OCR1A = 31250;            // compare match register 16MHz/256/2Hz
	TCCR1B |= (1 << WGM12);   // CTC mode
	TCCR1B |= (1 << CS12);    // 256 prescaler
	TIMSK1 |= (1 << OCIE1A);  // enable timer compare interrupt

	sei(); // Enable interrupts

}

void task_init(void){

	led_init();

	start_task_timer();

}


void task_run(void){

	while(1) {

		led_set(LED_ON);

		_delay_ms(50);

		led_set(LED_OFF);

		wait_until_end_of_cycle();

	}

}

ISR(TIMER1_COMPA_vect){
	start_cycle_now = true;
}

