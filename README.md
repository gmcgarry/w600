The original sources can be found here: https://github.com/gmcgarry/w600

# Introduction

Looking through documentation, the SDK and the example code, I couldn't
anything that worked for me.  The SDK wouldn't build with my toolchain
and the download tools didn't work on a Mac.

One of the things that frustrated me with the Wemos W600-pico board
is that the bootmode pin is hard-wired to always boot from the ROM
and the W600 ROM expects the FLASH to start with a complex structure.

Nothing as simple as the STM32 flash.

Additionally, the SDK is build on FreeRTOS, much like the
ESP chips.  Way too much boilerplate code for a microcontroller.

So the aim of this project is to get the W600 to behave more like
an STM32.

# Pre-build Firmware

If you can find .fls files, they are recognised by the W600 ROM
and can be written to the flash.  The only .fls file that worked for
me is the micropython firmware.  So I've [pre-built some more](fls/).

The .fls files can be uploaded and written to flash over UART0
using the following command:

	python3 tools/w600tool.py --upload-baudrate 115200 -u firmware.lfs

The W600 ROM will map the flash at 0x0800000, and jump to the
vector table specified by the load address in the header (usually
0x08002100).

# Pre-build images

The usual way to setup the flash is to place a secondary boot-loader
(secboot) at the beginning of the flash.  Secboot can do a few things:

- receive and write code images (.img) to flash over UART0
- scan the flash for executable code images
- scan the flash and decompress compressed code images

Horrifically, these .img files and images use the same magic markers
as firmware images (.fls).

Secboot assumes that the image header will be located at offset
0x00010000 in flash.  This will map to memory address 0x08010000.
The image header is 256 bytes, so the vector table of the image will
be located at memory address 0x08010100.

You'll see that W600 code will be linked to exectute at 0x08010100.

If your W600-pico doesn't have secboot, you can upload it using
the following command:

	python3 tools/w600tool.py --upload-baudrate 115200 fls/secboot.fls

Then you can upload the images:

	python3 tools/w600tool.py --upload-baudrate 115200 img/blink.img

A collection of [pre-built images are available](img/).

# Tools

The python scripts are modified versions from the W600 SDK.

# Source code

## blink.asm

Simple thumb assembly code to blink an LED which doesn't require
KB of library code.  On the Wemos W600-pico, the blue LED is on PA0.

## uart.asm

Echo the characters from the CH341 USB serial controller.  By default
the UART is configured for 115200,N,8,1.

So much simpler that than the interrupt-driven, FIFO-based example in
the SDK.
