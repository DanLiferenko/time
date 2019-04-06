@ $$\hbox to7cm{\vbox to4.21cm{\vfil\special{psfile=max.eps
  clip llx=0 lly=0 urx=490 ury=295 rwi=1984}}\hfil}$$

$$\hbox to8.35cm{\vbox to2.2225cm{\vfil\special{psfile=MAX.1
  clip llx=-38 lly=37 urx=57 ury=100 rwi=950}}\kern5cm
  \vbox to1.48166666666667cm{\vfil\special{psfile=MAX.2
  clip llx=-142 lly=-21 urx=-28 ury=21 rwi=1140}}\hfil}$$

@c
#include <avr/io.h>
#include <util/delay.h>
void display_write(unsigned int dc) /* FIXME: will it work without `|unsigned|'? */
{
  for (int i = 16; i > 0; i--) { // shift 16 bits out, msb first
    PORTB &= ~(1 << PB4); // clk = 0
    PORTB |= 1 << PB5;
    if ((dc & (1 << 15)) == 0)
      PORTB &= ~(1 << PB5); // data out = bit 15
//    __asm__ __volatile__ ("nop");
//    __asm__ __volatile__ ("nop");
//    __asm__ __volatile__ ("nop");
    PORTB |= 1 << PB4; // clk = 1
    dc <<= 1;                           // prepare next bit
  }

  PORTB |= 1 << PB6; // strobe = 1: latch data
  __asm__ __volatile__ ("nop");
  __asm__ __volatile__ ("nop");
  __asm__ __volatile__ ("nop");
  PORTB &= ~(1 << PB6); // strobe = 0
}

void main(void)
{
  DDRB |= 1 << PB4 | 1 << PB5 | 1 << PB6;
  @<Initialize@>@;
  @<Clear@>@;
}

@ @<Initialize@>=
display_write(0x0B << 8 | 0x07); /* number of displayed characters */
display_write(0x09 << 8 | 0xFF); /* decode mode */
display_write(0x0A << 8 | 0x05); /* brightness */
display_write(0x0C << 8 | 0x01); /* enable */

@ @<Clear@>=
display_write(0x01 << 8 | 0x0F);
display_write(0x02 << 8 | 0x0F);
display_write(0x03 << 8 | 0x0F);
display_write(0x04 << 8 | 0x0F);
display_write(0x05 << 8 | 0x0F);
display_write(0x06 << 8 | 0x0F);
display_write(0x07 << 8 | 0x0F);
display_write(0x08 << 8 | 0x0F);
