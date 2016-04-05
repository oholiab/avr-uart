PROGNAME=$(shell basename $(shell pwd))
BOARD?=olimexino

## Change following section with details for your chip
PART?=m328p
CC=avr-gcc
PROGRAMMER?=ft232r
DEVICE?=/dev/ttyUSB0
DEPS=$(shell find dependencies/ -maxdepth 1 -type d)
## End of chip details
ifeq ($(BOARD), breadboarduino)
	FLASHER ?= $(shell which avrdude)
  FLASHCMD?=$(FLASHER) -c $(PROGRAMMER) -p $(PART) -P $(DEVICE) -U flash :w:$(PROGNAME).hex
	MCU?=atmega328p
  DEFS?=-DF_CPU=8000000L
endif
ifeq ($(BOARD), olimexino)
	FLASHER ?= micronucleus/commandline/micronucleus
  FLASHCMD?=$(FLASHER) $(PROGNAME).hex
	MCU?=attiny85
	DEFS?=-DF_CPU=8000000L
endif

.PHONY: flash


CFLAGS=-g -Wall -mmcu=$(MCU)
CFLAGS += $(foreach dep,$(DEPS), -I./$(dep))
CFLAGS += -lsetbaud
#Uncomment to enable verbose
#CFLAGS+= -v
TARGETS=$(PROGNAME).hex

default: $(TARGETS)

%.o: %.c .dependencies
	$(CC) -Os $(CFLAGS) $(DEFS) -c $*.c
	$(CC) $(CFLAGS) $(DEFS) -o $*.elf $*.o

%.hex: %.o .dependencies
	avr-objcopy -O ihex $*.elf $*.hex
	rm $*.o $*.elf

flash: | $(FLASHER) $(PROGNAME).hex
	echo $(MCU)
	echo $(FLASHER)
	$(FLASHCMD)
	
micronucleus/commandline/micronucleus: micronucleus
	bash -c "cd $</commandline && make"

micronucleus:
	git clone git@github.com:micronucleus/micronucleus

.dependencies:
	bash -c "if [ -d dependencies ]; then cd dependencies && make; fi"
	touch .dependencies

clean:
	rm $(TARGETS)
