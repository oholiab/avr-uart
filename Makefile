PROGNAME=$(shell basename $(shell pwd))
BOARD?=promicro

## Change following section with details for your chip
CC=avr-gcc
DEPS=$(shell find dependencies/ -maxdepth 1 -type d)
## End of chip details
ifeq ($(BOARD), breadboarduino)
	PROGRAMMER?=ft232r
	FLASHER ?= $(shell which avrdude)
	DEVICE?=/dev/ttyUSB0
  FLASHCMD?=$(FLASHER) -c $(PROGRAMMER) -p $(PART) -P $(DEVICE) -U flash :w:$(PROGNAME).hex
	MCU?=atmega328p
	PART?=m328p
  DEFS?=-DF_CPU=8000000L
endif
ifeq ($(BOARD), promicro)
	PROGRAMMER?=avr109
	FLASHER ?= $(shell which avrdude)
	PART?=m32u4
	DEVICE?=/dev/ttyACM0
  FLASHCMD?=$(FLASHER) -c $(PROGRAMMER) -p $(PART) -P $(DEVICE) -U flash:w:$(PROGNAME).hex
	MCU?=atmega32u4
  DEFS?=-DF_CPU=16000000L
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
#Uncomment to enable verbose
#CFLAGS+= -v
TARGETS=$(PROGNAME).hex
OBJECTS=$(PROGNAME).o

default: $(OBJECTS)

%.hex: %.c .dependencies
	$(CC) $(CFLAGS) $(DEFS) -o $*.elf $*.o
	avr-objcopy -O ihex $*.elf $*.hex
	rm $*.o $*.elf

%.o: %.c .dependencies
	$(CC) -Os $(CFLAGS) $(DEFS) -c $*.c

flash: | $(FLASHER) $(PROGNAME).hex
	echo $(MCU)
	echo $(FLASHER)
	$(FLASHCMD)
	
micronucleus/commandline/micronucleus: micronucleus
	bash -c "cd $</commandline && make"

micronucleus:
	git clone git@github.com:micronucleus/micronucleus

.dependencies:
	bash -c "cd dependencies && make"
	touch .dependencies

clean:
	rm $(TARGETS)
