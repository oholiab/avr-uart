#ifndef AVR_UART_INCLUDED
#define AVR_UART_INCLUDED
#include <stdio.h>

void uart_putchar(char c, FILE *stream);
char uart_getchar(void);

void uart_init(void);

FILE uart_output = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);
FILE uart_input = FDEV_SETUP_STREAM(NULL, uart_getchar, _FDEV_SETUP_READ);
#endif
