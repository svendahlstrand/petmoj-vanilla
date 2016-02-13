#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include "usbdrv.h"
#include "keys.h"
#include "descriptor.h"

typedef struct {
	uint8_t modifier;
	uint8_t reserved;
	uint8_t keycode[6];
} keyboardReport_t;

static keyboardReport_t keyboardReport;
static uint8_t idleRate;

usbMsgLen_t usbFunctionSetup(uchar data[8]) {
	usbRequest_t *request = (void *)data;

	if((request->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_CLASS) {
	  switch(request->bRequest) {
		case USBRQ_HID_GET_REPORT:
		  usbMsgPtr = (usbMsgPtr_t)&keyboardReport;
		  keyboardReport.modifier = 0;
		  keyboardReport.keycode[0] = 0;

		  return sizeof(keyboardReport);
		case USBRQ_HID_SET_REPORT:
		  return (request->wLength.word == 1) ? USB_NO_MSG : 0;
		case USBRQ_HID_GET_IDLE:
		  usbMsgPtr = (usbMsgPtr_t)&idleRate;

		  return 1;
		case USBRQ_HID_SET_IDLE:
		  idleRate = request->wValue.bytes[1];

		  return 0;
		}
	}

	return 0;
}

void pressKeyWithModifier(uint8_t keycode, uint8_t modifier) {
	if (keyboardReport.modifier == modifier && keyboardReport.keycode[0] == keycode)
		return;

  keyboardReport.modifier = modifier;
  keyboardReport.keycode[0] = keycode;

	usbSetInterrupt((void *)&keyboardReport, sizeof(keyboardReport));
}

void pressKey(uint8_t keycode) {
	pressKeyWithModifier(keycode, 0);
}

void releaseAllKeys() {
  pressKey(0);
}

void enforceEnumeration() {
  usbDeviceDisconnect();
  _delay_ms(250);
  usbDeviceConnect();
}

void initializeUSBDriver() {
  enforceEnumeration();
  usbInit();
  sei();
}

int main (void) {
  initializeUSBDriver();

  int sent = 0;

  for(;;) {
    usbPoll();

    if (usbInterruptIsReady()) {
      if (sent == 0) {
        pressKeyWithModifier(KEY_F4, MODIFIER_LEFT_ALT);
        sent = 1;
      } else {
        releaseAllKeys();
      }
    }
  }

  return 0;
}
