@ TODO: add here picture of the module

$$\hbox to10.26cm{\vbox to5.46805555555556cm{\vfil\special{psfile=MAX.1
  clip llx=-85 lly=-38 urx=206 ury=117 rwi=2910}}\hfil}$$

{\tt http://www.adnbr.co.uk/articles/max7219-and-7-segment-displays}

@d F_CPU 16000000UL

@c
#include <avr/io.h>
#include <util/delay.h>

#define ON                        1
#define OFF                       0

#define MAX7219_LOAD1             PORTB |= 1 << PB3
#define MAX7219_LOAD0             PORTB &= ~(1 << PB3)

#define MAX7219_MODE_DECODE       0x09
#define MAX7219_MODE_INTENSITY    0x0A
#define MAX7219_MODE_SCAN_LIMIT   0x0B
#define MAX7219_MODE_POWER        0x0C
#define MAX7219_MODE_TEST         0x0F
#define MAX7219_MODE_NOOP         0x00

// I only have 3 digits, no point having the
// rest. You could use more though.
#define MAX7219_DIGIT0            0x01
#define MAX7219_DIGIT1            0x02
#define MAX7219_DIGIT2            0x03

#define MAX7219_CHAR_BLANK        0xF 
#define MAX7219_CHAR_NEGATIVE     0xA 

char digitsInUse = 3;

void spiSendByte (char databyte)
{
    // Copy data into the SPI data register
    SPDR = databyte;
    // Wait until transfer is complete
    while (!(SPSR & (1 << SPIF)));
}

void MAX7219_writeData(char data_register, char data)
{
    MAX7219_LOAD0;
        // Send the register where the data will be stored
        spiSendByte(data_register);
        // Send the data to be stored
        spiSendByte(data);
    MAX7219_LOAD1;
}

void MAX7219_clearDisplay() 
{
    char i = digitsInUse;
    // Loop until 0, but don't run for zero
    do {
        // Set each display in use to blank
        MAX7219_writeData(i, MAX7219_CHAR_BLANK);
    } while (--i);
}

void MAX7219_displayNumber(volatile long number) 
{
    char negative = 0;

    // Convert negative to positive.
    // Keep a record that it was negative so we can
    // sign it again on the display.
    if (number < 0) {
        negative = 1;
        number *= -1;
    }

    MAX7219_clearDisplay();

    // If number = 0, only show one zero then exit
    if (number == 0) {
        MAX7219_writeData(MAX7219_DIGIT0, 0);
        return;
    }
    
    // Initialization to 0 required in this case,
    // does not work without it. Not sure why.
    char i = 0; 
    
    // Loop until number is 0.
    do {
        MAX7219_writeData(++i, number % 10);
        // Actually divide by 10 now.
        number /= 10;
    } while (number);

    // Bear in mind that if you only have three digits, and
    // try to display something like "-256" all that will display
    // will be "256" because it needs an extra fourth digit to
    // display the sign.
    if (negative) {
        MAX7219_writeData(i, MAX7219_CHAR_NEGATIVE);
    }
}

int main(void)
{
  DDRB |= 1 << PB0; /* this pin is not used for SS because it is not available on promicro,
    but it must be set for OUTPUT anyway, otherwise MCU will be used as SPI slave;
    and on micro board which has SS pin it should not be used anyway because LED is
    attached to it, which means it will be almost constantly ON (i.e., when SPI is
    inactive) */
  DDRB |= 1 << PB3;
//  PORTB |= 1 << PB3;      // begin high (unselected)

  DDRB |= 1 << PB2;       // Output on MOSI
  DDRB |= 1 << PB1;       // Output on SCK

    // SPI Enable, Master mode
    SPCR |= (1 << SPE) | (1 << MSTR)| (1 << SPR1);

    // Decode mode to "Font Code-B"
    MAX7219_writeData(MAX7219_MODE_DECODE, 0xFF);

    // Scan limit runs from 0.
    MAX7219_writeData(MAX7219_MODE_SCAN_LIMIT, digitsInUse - 1);
    MAX7219_writeData(MAX7219_MODE_INTENSITY, 8);
    MAX7219_writeData(MAX7219_MODE_POWER, ON);

    int i = 999;
    while(1)
    {
        MAX7219_displayNumber(--i);
        _delay_ms(10); // this may be it!!! - read the article

        if (i == 0) {
            i = 999;
        }
    }
}