#include <stdio.h>

void hprintf(char *fmt, ...){
	va_list va;
	va_start(va, fmt);
    printf(fmt, va);
}
