TOOLDIR=../tools
BINDIR=../bin

all:	blink.fls uart.fls blink.img uart.img

blink.fls:	secboot.img

uart.fls:	secboot.img

secboot.img:	$(BINDIR)/secboot.bin
	python3 $(TOOLDIR)/makeimg.py $< $@ 2 0 version.txt 0x0000 0x2100

clean:
	rm -f blink.bin uart.bin
	rm -f blink.img uart.img secboot.img
	rm -f blink.fls uart.fls

.SUFFIXES: .bin .asm .img .fls

.img.fls:
	python3 $(TOOLDIR)/makeimg_fls.py secboot.img $< $@

.bin.img:
	python3 $(TOOLDIR)/makeimg.py $< $@ 0 0 version.txt 0x10100 0x10100

.asm.bin:
	pasm-thumb -o $@ $<
