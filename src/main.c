#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include "usbdrv.h"

USB_PUBLIC usbMsgLen_t usbFunctionSetup(uchar data[8]) {
  return 0;
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

  for(;;) {
    usbPoll();
  }

  return 0;
}
