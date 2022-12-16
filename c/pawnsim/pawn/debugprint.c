/*
 * debugprint.c
 *
 *  Created on: 22.11.2015
 *      Author: hleppine
 */

#include <stdio.h>
#include <string.h>
#include "debugprint.h"
#ifdef AALTO2_OBC
/* OBC code*/
#include "sci.h"
#else
/* Linux simulator */
#include <stdarg.h>
#include <stdint.h>
#endif    

#define UART_PRINTF_BUFFER_SIZE	256

static char debug_buf[UART_PRINTF_BUFFER_SIZE] = {0};
    
static void uart_printstrn(char *str, uint16_t max) {
    
	uint16_t len = strlen(str);
    
	if (max < len) {
		len = max;
	}

#ifdef AALTO2_OBC
	sciSend(scilinREG, len, (uint8*)str);
#else
    (void)len;
    printf(str);
#endif
    
}

void hprintf(char *fmt, ...) {

	va_list va;
	va_start(va, fmt);
    
	vsnprintf(debug_buf, UART_PRINTF_BUFFER_SIZE, fmt, va);
    
	// be sure of 0-termination
	debug_buf[UART_PRINTF_BUFFER_SIZE-1] = '\0';
    
	uart_printstrn(debug_buf, UART_PRINTF_BUFFER_SIZE);

}


int amx_putstr(const TCHAR * s){
    hprintf((char*)s);
    return 0;
}

int amx_putchar(int c){
    hprintf("%c", c);
    return 0;
}

int amx_fflush(void){
    return 0;
}

int amx_getch(void){
    return 0;
}
TCHAR *amx_gets(TCHAR * c, int x){
    return c;
}
int amx_termctl(int x, int y){
    return 0;
}
void amx_clrscr(void){

}
void amx_clreol(void){

}
int amx_gotoxy(int x, int y){
    return 0;
}
void amx_wherexy(int *x, int *y){

}
unsigned int amx_setattr(int foregr, int backgr, int highlight){
    return 0;
}
void amx_console(int columns, int lines, int flags){

}
void amx_viewsize(int *width, int *height){

}
int amx_kbhit(void){
    return 0;
}

