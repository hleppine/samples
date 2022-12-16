/*
 * led.h
 *
 *  Created on: Oct 29, 2016
 *      Author: hleppine
 */

#ifndef LED_LED_H_
#define LED_LED_H_


typedef enum led_state_t {
	LED_OFF,
	LED_ON
} led_state_t;


void led_init(void);


void led_set(led_state_t state);


#endif /* LED_LED_H_ */
