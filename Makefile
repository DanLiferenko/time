MCU=atmega32u4

time-read lcd max max4:
	@avr-gcc -mmcu=$(MCU) -g -Os -o fw.elf $@.c
	@avr-objcopy -O ihex fw.elf fw.hex

flash:
	@avrdude -qq -c usbasp -p $(MCU) -U flash:w:fw.hex

imgs:
	@mp MAX
