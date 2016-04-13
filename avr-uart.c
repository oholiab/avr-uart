#if !defined(F_CPU)
#define F_CPU 16000000UL
#endif

#define BAUD 9600

#include <avr/io.h>
#include <stdio.h>
#include <util/setbaud.h>

#define THIS_UBRR (((F_CPU/16)/BAUD)-1)

void uart_init(void){
  //set baud split across two registers
  //UBRR1H = (uint8_t)(THIS_UBRR>>8);
  //UBRR1L = (uint8_t)THIS_UBRR;
  UBRR1H = UBRRH_VALUE;
  UBRR1L = UBRRL_VALUE;

#if USE_2X
  UCSR1A |= 1<<U2X1;
#else
  UCSR1A &= ~(1<<U2X1);
#endif

  //enable TX and RX
  UCSR1B = (1<<RXEN1)|(1<<TXEN1);

  //8 bit communication with two stop bits (011)
  UCSR1C = (1<<USBS1)|(1<<UCSZ10);
}

void uart_putchar(char c, FILE *stream){
  if (c == '\n'){
    uart_putchar('\r', stream);
  }
  while(!(UCSR1A & (1<<UDRE1)));
  UDR1 = c;
}

char uart_getchar(void){
  while(!(UCSR1A & (1<<RXC1)));
  return UDR1;
}
