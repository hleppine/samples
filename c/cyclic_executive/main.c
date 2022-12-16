/*
 * main.c
 *
 *  Created on: Oct 29, 2016
 *      Author: hleppine
 */

#include "task.h"


int main(void){

	task_init(); // Perform initializations.

	task_run(); // Run cyclic executive task. Never returns.

	return 0;

}


