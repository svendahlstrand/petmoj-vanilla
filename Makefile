MCU=attiny85
F_CPU=16500000UL

PROGRAMMER=stk500v1
PORT=/dev/cu.usbmodem1411
BAUD_RATE=19200

AVRDUDE=avrdude
DUDEFLAGS=-c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD_RATE)

SRC=src
V-USB_SRC=vendor/v-usb/usbdrv
V-USB=$(V-USB_SRC)/usbdrv.o $(V-USB_SRC)/oddebug.o $(V-USB_SRC)/usbdrvasm.o

CC=avr-gcc
CFLAGS=-Wall -Os -I$(V-USB_SRC) -I$(SRC)
ALL_CFLAGS=-mmcu=$(MCU) -DF_CPU=$(F_CPU) $(CFLAGS)

all: main.elf

main.elf: $(SRC)/main.c $(V-USB)
	$(CC) $(ALL_CFLAGS) -o $@ $^

.c.o:
	$(CC) $(ALL_CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(ALL_CFLAGS) -x assembler-with-cpp -c $< -o $@

.PHONY: flash fuse clean

flash: main.elf
	$(AVRDUDE) $(DUDEFLAGS) -U flash:w:$<

fuse:
ifeq ($(and $(strip $(LFUSE)), $(strip $(HFUSE)), $(strip $(EFUSE))),)
	$(error You have to provide LFUSE, HFUSE and EFUSE)
else
	$(AVRDUDE) $(DUDEFLAGS) \
	-U lfuse:w:$(LFUSE):m \
	-U hfuse:w:$(HFUSE):m \
	-U efuse:w:$(EFUSE):m
endif

clean:
	find . \( -name "*.o" -or -name "*.elf" \) -type f -delete -print
