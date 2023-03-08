#define F_CPU 16000000UL
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

int flag = 0;

ISR (INT1_vect)     //External INT1 ISR
{
    flag++;
    
    if (flag>1){
    PORTB = 0xFF;
    _delay_ms (500) ;
    PORTB = 0x01;
    _delay_ms (4000) ;
    PORTB= 0x00;
    flag = 0;
    }
    else {
    PORTB = 0x01;
    _delay_ms (4000) ;
    PORTB= 0x00;
    flag = 0;
    }
}

int main()
{
    // Interrupt on rising edge of INTO and INT1 pin
    EICRA = (1 << ISC11) | ( 1 << ISC10);
    //Enable the INTO interrupt (PD2), INT1 interrupt (PD3)
    EIMSK = (1 << INT1);
    sei();          // Enable global interrupts

    DDRB=0xFF;      //Set PORTB as output
    PORTB=0x00;
    
    while(1)
    {
    PORTB = 0x00;
    flag = 0;
    }
}