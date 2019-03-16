MCU=atmega32u4

time-read:
	@avr-gcc -mmcu=$(MCU) -g -Os -o fw.elf $@.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex
