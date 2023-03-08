#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

void Write_2_Nibbles(uint8_t in) {
    uint8_t temp = in;
    uint8_t p = PIND;
    p &= 0x0F;
    in &= 0xF0;
    in |= p;
    PORTD = in;
    PORTD |= 0x08;
    PORTD &= 0xF7;
    
    in = temp;
    in &= 0x0F;
    in = in << 4;
    in |= p;
    PORTD = in;
    PORTD |= 0x08;
    PORTD &= 0xF7;
    
    return;
}

void LCD_data(uint8_t c) {
    PORTD |= 0x04;
    Write_2_Nibbles(c);
    _delay_us(100);
    return;
}

void LCD_command(uint8_t c) {
    PORTD &= 0xFB;
    Write_2_Nibbles(c);
    _delay_us(100);
    return;
}

void LCD_init(void) {
    _delay_ms(40);
    
    PORTD = 0x30;
    PORTD |= 0x08;
    PORTD &= 0xF7;
    _delay_us(100);
    
    PORTD = 0x30;
    PORTD |= 0x08;
    PORTD &= 0xF7;
    _delay_us(100);
    
    PORTD = 0x20;
    PORTD |= 0x08;
    PORTD &= 0xF7;
    _delay_us(100);
    
    LCD_command(0x28);
    LCD_command(0x0C);
    LCD_command(0x01);
    _delay_us(5000);
    
    LCD_command(0x06);
    return;
}


int main() 
{
    TCCR1A = (0<<WGM10) | (1<<WGM11) | (1<<COM1A1);
    TCCR1B = (1<<WGM12) | (1<<CS11) | (1<<WGM13);
    
    ADMUX = (1 << REFS0) | (1 << MUX1);
    ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
    ADCSRB = 0x00;
    DIDR0 = ~(1 << ADC2D);
    
    OCR1AL = 0x80;
    
    DDRB = 0b00000010;
    DDRC = 0x00;
    DDRD = 0xFF;
    
    LCD_init();
    
    float adc;
    int adc_akeraio, adc_1_dec, adc_2_dec;
    
    while(1)
    {
        ICR1 = 0x00;
        
        if (PINB == 0b10111011) {
            while(PINB == 0b10111011) {
                ICR1 = 0x018F;     
                OCR1A = ICR1 * 0.2;
                
                ADCSRA |= (1 << ADSC);
                while ((ADCSRA & (1 << ADSC)) == (1 << ADSC));
                adc = ADC;
                adc = adc * 5 / 1024 * 0.2;
                adc_akeraio = (uint8_t)(adc);
                adc_1_dec = (adc - adc_akeraio) * 10;
                adc_1_dec = (uint8_t)(adc_1_dec);
                adc_2_dec = (((adc - adc_akeraio) * 10) - adc_1_dec) * 10;
                adc_2_dec = (uint8_t)(adc_2_dec);
                
                adc_akeraio |= 0x30;
                adc_1_dec |= 0x30;
                adc_2_dec |= 0x30;
                
                LCD_init();
                LCD_data('2');
                LCD_data('0');
                LCD_data('%');
                LCD_command(0b11000000);    // Next line
                LCD_data(adc_akeraio);
                LCD_data('.');
                LCD_data(adc_1_dec);
                LCD_data(adc_2_dec);
            }
        }
        if (PINB == 0b10110111) {
            while(PINB == 0b10110111) {
                ICR1 = 0x018F;
                OCR1A = ICR1 * 0.4;
                
                ADCSRA |= (1 << ADSC);
                while ((ADCSRA & (1 << ADSC)) == (1 << ADSC));
                adc = ADC;
                adc = adc * 5 / 1024 * 0.4;
                adc_akeraio = (uint8_t)(adc);
                adc_1_dec = (adc - adc_akeraio) * 10;
                adc_1_dec = (uint8_t)(adc_1_dec);
                adc_2_dec = (((adc - adc_akeraio) * 10) - adc_1_dec) * 10;
                adc_2_dec = (uint8_t)(adc_2_dec);
                
                adc_akeraio |= 0x30;
                adc_1_dec |= 0x30;
                adc_2_dec |= 0x30;
                
                LCD_init();
                LCD_data('4');
                LCD_data('0');
                LCD_data('%');
                LCD_command(0b11000000);
                LCD_data(adc_akeraio);
                LCD_data('.');
                LCD_data(adc_1_dec);
                LCD_data(adc_2_dec);
            }
        }
        if (PINB == 0b10101111) {
            while(PINB == 0b10101111) {
                ICR1 = 0x018F;
                OCR1A = ICR1 * 0.6;
                
                ADCSRA |= (1 << ADSC);
                while ((ADCSRA & (1 << ADSC)) == (1 << ADSC));
                adc = ADC;
                adc = adc * 5 / 1024 * 0.6;
                adc_akeraio = (uint8_t)(adc);
                adc_1_dec = (adc - adc_akeraio) * 10;
                adc_1_dec = (uint8_t)(adc_1_dec);
                adc_2_dec = (((adc - adc_akeraio) * 10) - adc_1_dec) * 10;
                adc_2_dec = (uint8_t)(adc_2_dec);
                
                adc_akeraio |= 0x30;
                adc_1_dec |= 0x30;
                adc_2_dec |= 0x30;
                
                LCD_init();
                LCD_data('6');
                LCD_data('0');
                LCD_data('%');
                LCD_command(0b11000000);
                LCD_data(adc_akeraio);
                LCD_data('.');
                LCD_data(adc_1_dec);
                LCD_data(adc_2_dec);
            }
        }
        if (PINB == 0b10011111) {
            while(PINB == 0b10011111) {
                ICR1 = 0x018F;
                OCR1A = ICR1 * 0.8;
                
                ADCSRA |= (1 << ADSC);
                while ((ADCSRA & (1 << ADSC)) == (1 << ADSC));
                adc = ADC;
                adc = adc * 5 / 1024 * 0.8;
                adc_akeraio = (uint8_t)(adc);
                adc_1_dec = (adc - adc_akeraio) * 10;
                adc_1_dec = (uint8_t)(adc_1_dec);
                adc_2_dec = (((adc - adc_akeraio) * 10) - adc_1_dec) * 10;
                adc_2_dec = (uint8_t)(adc_2_dec);
                
                adc_akeraio |= 0x30;
                adc_1_dec |= 0x30;
                adc_2_dec |= 0x30;
                
                LCD_init();
                LCD_data('8');
                LCD_data('0');
                LCD_data('%');
                LCD_command(0b11000000);
                LCD_data(adc_akeraio);
                LCD_data('.');
                LCD_data(adc_1_dec);
                LCD_data(adc_2_dec);
            }
        }
    }
}
