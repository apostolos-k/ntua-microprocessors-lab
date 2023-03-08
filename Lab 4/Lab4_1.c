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
}


int main() 
{
    DDRB = 0xFF;
    DDRD = 0xFF;
    DDRC = 0x00;
    
    ADMUX = (1 << REFS0) | (1 << MUX1);
    ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
    ADCSRB = 0x00;
    DIDR0 = ~(1 << ADC2D);
    
    while(1) {
        LCD_init();
        ADCSRA |= (1 << ADSC);
        while ((ADCSRA & (1 << ADSC)) == (1 << ADSC));
        float adc = ADC;
        adc = adc * 5 / 1024;
        int adc_akeraio = (uint8_t)(adc);
        int adc_1_dec = (adc - adc_akeraio) * 10;
        adc_1_dec = (uint8_t)(adc_1_dec);
        int adc_2_dec = (((adc - adc_akeraio) * 10) - adc_1_dec) * 10;
        adc_2_dec = (uint8_t)(adc_2_dec);
        
        adc_akeraio |= 0x30;
        adc_1_dec |= 0x30;
        adc_2_dec |= 0x30;
        LCD_data(adc_akeraio);
        LCD_data('.');
        LCD_data(adc_1_dec);
        LCD_data(adc_2_dec);
    }
}
