/*
 * debugprint.h
 *
 *  Created on: 22.11.2015
 *      Author: hleppine
 */

#ifndef DEBUGPRINT_H_
#define DEBUGPRINT_H_

/* Hercules printf */
void hprintf(char *fmt, ...);

typedef char TCHAR;

int amx_putstr(const TCHAR * s);
int amx_putchar(int c);
int amx_fflush(void);
int amx_getch(void);
TCHAR *amx_gets(TCHAR * s, int x);
int amx_termctl(int x, int y);
void amx_clrscr(void);
void amx_clreol(void);
int amx_gotoxy(int x, int y);
void amx_wherexy(int *x, int *y);
unsigned int amx_setattr(int foregr,int backgr,int highlight);
void amx_console(int columns, int lines, int flags);
void amx_viewsize(int *width,int *height);
int amx_kbhit(void);

#endif /* DEBUGPRINT_H_ */
