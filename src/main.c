#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
    // PB2 output
    DDRB = 1<<2;

    while(1)
    {
	// Toggle PB2
	PINB = 1<<2;
	_delay_ms(500);
    }
}
