#include <avr/io.h>
#include <stdio.h>

#if !defined(F_CPU)
#define F_CPU 16000000UL
#endif

#define BAUD 9600

#include <util/setbaud.h>
#define THIS_UBRR (((F_CPU/16)/BAUD)-1)

void uart_init(void){
  //set baud split across two registers
  //UBRR0H = (uint8_t)(THIS_UBRR>>8);
  //UBRR0L = (uint8_t)THIS_UBRR;
  UBRR0H = UBRRH_VALUE;
  UBRR0L = UBRRL_VALUE;

#if USE_2X
  UCSR0A |= 1<<U2X0;
#else
  UCSR0A &= ~(1<<U2X0);
#endif

  //enable TX and RX
  UCSR0B = (1<<RXEN0)|(1<<TXEN0);

  //8 bit communication with one stop bit (011)
  //using registers UCSZ20, UCSZ01, UCSZ00
  UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
}

void uart_putchar(char c, FILE *stream){
  if (c == '\n'){
    uart_putchar('\r', stream);
  }
  while(!(UCSR0A & (1<<UDRE0)));
  UDR0 = c;
}

char uart_getchar(void){
  while(!(UCSR0A & (1<<RXC0)));
  return UDR0;
}
