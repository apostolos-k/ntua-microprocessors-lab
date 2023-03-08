#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

int main() 
{
    TCCR1A = (0<<WGM10) | (1<<WGM11) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11) | (1<<WGM13);
    
    DDRB = 0b00111111;      // PORTB as output
    
    while(1) 
    {
        ICR1 = 0x00;
        
        if (PIND == 0b11111110) {
            while(PIND == 0b11111110) {
                OCR1A = 0x1F40;
                ICR1 = 0x3E7F;
            }
        }
        if (PIND == 0b11111101) {
            while(PIND == 0b11111101) {
                OCR1A = 0x0FA0;
                ICR1 = 0x1F3F;  
            }
        }
        if (PIND == 0b11111011) {
            while(PIND == 0b11111011) {
                OCR1A = 0x07D0;
                ICR1 = 0x0F9F; 
            }
        }
        if (PIND == 0b11110111) {
            while(PIND == 0b11110111) {
                OCR1A = 0x03E8;
                ICR1 = 0x07CF; 
            }
        }
    }
}