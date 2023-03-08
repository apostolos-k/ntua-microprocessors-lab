#include <avr/io.h>
#define 	F_CPU   16000000UL 
#include <util/delay.h>
#define cbi(reg,bit) (reg &= ~(1 << bit))
#define sbi(reg,bit) (reg |= (1 << bit))

uint8_t one_wire_receive_bit() {
    uint8_t bit,temp;
    sbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(2);
    cbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(10);
    temp = (PIND & 0x10);
    bit = 0x00;
    if (temp == 0x10) bit = 0x01;
    _delay_us(49);
    return bit;
}

uint8_t one_wire_receive_byte() {    
    uint8_t bit;
    uint8_t byte = 0x00;
    uint8_t i = 0x08;
    while(i != 0){
        bit = one_wire_receive_bit();
        byte = (byte >> 1);
        if (bit == 0x01) bit = 0x80;
        byte = (byte | bit);
        i--;
    }
    return byte;
}

void one_wire_transmit_bit(uint8_t bit) {
    sbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(2);
    if (bit == 0x01) sbi(PORTD,PD4);
    if (bit == 0x00) cbi(PORTD,PD4);
    _delay_us(58);
    cbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(1);
    return;
}

void one_wire_transmit_byte(uint8_t byte) {
    uint8_t bit;
    uint8_t i = 0x08;
    while(i != 0){
        bit = (byte & 0x01);
        one_wire_transmit_bit(bit);
        byte = (byte >> 1);
        i--;
    }
    return;
}

uint8_t one_wire_reset() { 
    sbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(480);
    cbi(DDRD,PD4);
    cbi(PORTD,PD4);
    _delay_us(100);
    uint8_t temp = PIND;
    _delay_us(380);
    temp = (temp & 0x10);
    uint8_t res = 0x00;
    if (temp == 0x00)
        res = 0x01;
    return res;
}


int main(void)
{
    DDRB = 0x3F;
    DDRD = 0xFF;
    
    uint8_t temp_lo, temp_hi, temp_sign;
    uint16_t temp_final, temp_hi_16, temp_final_out;
    
    while (1)
    {
        // Check if device is connected
        if (!one_wire_reset()) {
            temp_final_out = 0x8000;
            continue;
        }
        one_wire_transmit_byte(0xCC);       // Send command 0xCC
        one_wire_transmit_byte(0x44);       // Send command 0x44
        
        while(one_wire_receive_bit() != 0x01);
        
        // Recheck if device is connected
        if (!one_wire_reset()) {
            temp_final_out = 0x8000;
            continue;
        }
        
        one_wire_transmit_byte(0xCC);       // Send command 0xCC
        one_wire_transmit_byte(0xBE);       // Send command 0xBE
        
        /* SAVE TEMPRATURE VALUE */
        temp_lo = one_wire_receive_byte();
        temp_hi = one_wire_receive_byte();
        temp_sign = temp_hi & 0xF8;
        temp_hi_16 = temp_hi << 8;
        temp_final = temp_hi_16 + temp_lo;
        
        // Check if temperature is negative or positive
        if (temp_sign == 0xF8)
            temp_final_out = ~(temp_final) + 1;   // Two's compliment
        else
            temp_final_out = temp_final;
    }
}
