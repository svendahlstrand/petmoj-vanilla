MCU=attiny85
F_CPU=16500000UL

PROGRAMMER=stk500v1
PORT=/dev/cu.usbmodem1411
BAUD_RATE=19200

CC=avr-gcc
CFLAGS=-Wall -Os -Ivendor/v-usb/usbdrv -Isrc
ALL_CFLAGS=-mmcu=$(MCU) -DF_CPU=$(F_CPU) $(CFLAGS)
AVRDUDE=avrdude
AVRFLAGS=-c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD_RATE)

OBJECTS = vendor/v-usb/usbdrv/usbdrv.o vendor/v-usb/usbdrv/oddebug.o vendor/v-usb/usbdrv/usbdrvasm.o

COMPILE=$(CC) $(ALL_CFLAGS)

all: main.elf

main.elf: src/main.c $(OBJECTS)
	$(CC) $(ALL_CFLAGS) -o $@ $(OBJECTS) $<

.PHONY: flash fuse clean

flash: main.elf
	$(AVRDUDE) $(AVRFLAGS) -U flash:w:$<

fuse:
ifeq ($(and $(strip $(LFUSE)), $(strip $(HFUSE)), $(strip $(EFUSE))),)
	$(error You have to provide LFUSE, HFUSE and EFUSE)
else
	$(AVRDUDE) $(AVRFLAGS) \
	-U lfuse:w:$(LFUSE):m \
	-U hfuse:w:$(HFUSE):m \
	-U efuse:w:$(EFUSE):m
endif

clean:
	find . \( -name "*.o" -or -name "*.elf" \) -type f -delete -print

.c.o:
	$(CC) $(ALL_CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(ALL_CFLAGS) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(CC) $(ALL_CFLAGS) -S $< -o $@
