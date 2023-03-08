#define F_CPU 16000000UL
#include<avr/io.h>

int main ()
{
    // set TMR1A 8 bit
    TCCR1A = (1<<WGM10) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11);
    
    DDRB = 0b00111111;      // Output
    DDRD = 0b00000000;      // Input
    
    unsigned char duty[] = {0x05, 0x1A, 0x2E, 0x43, 0x57, 0x6C, 0x80, 0x94, 0xA7, 0xBD, 0xD2, 0xE6, 0xFB};      // Ascending order
    
    int i = 6;              // Initialize DC to 50%
    OCR1AL = duty[i];
    
    while (1)
    {
        if (PIND == 0b11111101) {       // PD1
            while (PIND == 0b11111101); 
            if (i < 12) { 
                i++;
                OCR1AL = duty[i];
            }
        }
        if (PIND == 0b11111011) {       // PD2
            while (PIND == 0b11111011); 
            if (i > 0) {
                i--;
                OCR1AL = duty[i];
            }
        }
    }
}