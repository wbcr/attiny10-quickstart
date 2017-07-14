# AVR Development Quick Start (using ATTiny10 + STK600 for external TPI programming)

This a tiny example project to quick start development using the Atmel toolchain under Linux. It uses the ATTiny10 that can be programmed only in TPI mode. STK600 does not directly support external programming in TPI mode

## 1. Install the development toolchain on your workstation. On Arch Linux you can install the Atmel provided packages:

```shell
   $ yaourt -S avr-gcc-atmel
   $ yaourt -S avr-libc-atmel
   $ sudo pacman -S avrdude
```

   On a Debian derived distro, either use the community provided packages (avr-gcc, avr-libc, avrdude) or download an install
   the (Atmel provided packages)[http://www.atmel.com/tools/ATMELAVRTOOLCHAINFORLINUX.aspx) manually.
   
## 1. Verify your toolchain by compiling this tiny test application and generate a hex file:

```shell
   $ make
   avr-gcc -c -std=gnu99 -g -Os -Wall -DF_CPU=1000000 -mmcu=attiny10 -c src/main.c -o src/main.o
   avr-gcc -mmcu=attiny10 -o demo.elf src/main.o
   avr-size demo.elf
      text	   data	    bss	    dec	    hex	filename
        70	      0	      0	     70	     46	demo.elf
   avr-objcopy -O ihex demo.elf demo.hex
```

## 1. Connect your programmer and see if it is properly recognized by your system:

```shell
   $ lsusb
   ...
   Bus 001 Device 025: ID 03eb:2106 Atmel Corp. STK600 development board
```

   TIP: Avrdude uses libusb accessing the programmer. That means it needs RW access to /dev/bus/usb/$BUSID/$DEVICEID, that is by default only root writeable. In order to run Avrdude without sudo, you can add the following udev rule that makes the device world writable:

```
   SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2106", MODE="0666"
```   
   Save the rule and update udev:

```shell
   $ cp 90-atmel-stk600.rules /etc/udev/rules.d/
   $ sudo udevadm control --reload-rules && udevadm trigger

   $ ls -l /dev/bus/usb/001/035 
   crw-rw-rw- 1 root root 189, 34 júl 14 16:02 /dev/bus/usb/001/035
```
## 1. Connect the ATTiny10 MCU. Make sure the following settins are correct:

   * The 6 pin ISP/PDI header on STK600 is connected to the microcontroller's breakout board. Only pins TPICLK, TPIDATA, GND, VCC should be connected.
   * The RESET pin of the MCU is connected directly to pin 1 on the header for the RESET jumper.
   * VTARGET jumper is set.
   * Clock selection switch is on 'INT' as we are using the MCU's internal clock (thus disconnecting STK600's clock from TPICLK).
   * PB2 pin of the MCU is connected to one of hte LED pins on STK600 (LED6 in the picture).

## 1. Make sure VTARGET is set to 5V:

```shell
	$ avrdude -c stk600 -p t10 -t

	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9003 (probably t10)
	avrdude> vtarg 5V
	>>> vtarg 5V 
	avrdude> quit
	>>> quit 

	avrdude done.  Thank you.
```

## 1. Upload your hex file to the microcontroller:

```shell
	$ make upload
	avrdude -c stk600 -p t10 -U flash:w:demo.hex

	avrdude: AVR device initialized and ready to accept instructions

	Reading | ################################################## | 100% 0.00s

	avrdude: Device signature = 0x1e9003 (probably t10)
	avrdude: NOTE: "flash" memory has been specified, an erase cycle will be performed
	To disable this feature, specify the -D option.
	avrdude: erasing chip
	avrdude: reading input file "demo.hex"
	avrdude: input file demo.hex auto detected as Intel Hex
	avrdude: writing flash (70 bytes):

	Writing | ################################################## | 100% 0.19s

	avrdude: 70 bytes of flash written
	avrdude: verifying flash memory against demo.hex:
	avrdude: load data flash data from input file demo.hex:
	avrdude: input file demo.hex auto detected as Intel Hex
	avrdude: input file demo.hex contains 70 bytes
	avrdude: reading on-chip flash data:

	Reading | ################################################## | 100% 0.01s

	avrdude: verifying ...
	avrdude: 70 bytes of flash verified

	avrdude done.  Thank you.
```

## 1. Voila! LED6 should be blinking with a frequency of 1Hz.

References

* [Avr-libc demo project](http://www.nongnu.org/avr-libc/user-manual/group__demo__project.html)
* [Programming ATtiny in Linux](http://joost.damad.be/2014/01/programming-attiny10-in-linux.html)
* [ATMEL STK600 TPI Programming](http://www.atmel.com/webdoc/stk600/stk600.section.gak_mde_lc.html)
* [ATMEL TPI Programming application node](http://www.atmel.com/Images/doc8373.pdf)
* [ATMEL ATTiny10 datasheet](http://www.atmel.com/images/atmel-8127-avr-8-bit-microcontroller-attiny4-attiny5-attiny9-attiny10_datasheet.pdf)
* [AVR Freaks forum: ATTiny10 TPI & STK600](http://www.avrfreaks.net/forum/attiny10-tpi-stk600)