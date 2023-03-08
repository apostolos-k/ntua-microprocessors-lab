#define F_CPU 16000000UL
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

int flag = 0;
int flag1 = 0;

ISR (INT1_vect)         // External INT1 ISR
{
    flag++;
    
    if (flag>1) {       // 0.5 sec
        TCNT1 = 57722;
        PORTB = 0xFF;
        flag1++;
        while (flag1!=0);
        flag = 1;       // Timer1 routine sets flag = 0
        TCNT1 = 3035;
        PORTB= 0x01;
    }
    else {              // 4 sec
        TCNT1 = 3035;
        PORTB = 0x01;
    }
}

ISR (TIMER1_OVF_vect)   // Timer1 routine
{
    flag = 0;
    flag1 = 0;
    PORTB = 0x00;
}

int main()
{
    // Interrupt on rising edge of INT1 pin
    EICRA = (1 << ISC11) | ( 1 << ISC10);
    // Enable the INT1 interrupt (PD3)
    EIMSK = (1 << INT1);
    sei(); // Enable global interrupts

    TIMSK1 = (1<<TOIE1);
    TCCR1B = (1<<CS12) | (0<<CS11) | (1<<CS10);
    
    DDRB = 0xFF;       
    DDRD = 0x00;
   
    while(1) {
        if (PINC == 0b01011111) {
            while (PINC == 0b01011111);
            flag++;

            if (flag>1) {   // 0.5 sec if already LED is on
                TCNT1 = 57722;
                PORTB = 0xFF;
                flag1++;
                while (flag1!=0);
                flag = 1;
                TCNT1 = 3035;
                PORTB = 0x01;
            }
            else {          // 4 sec if LED is off
                TCNT1 = 3035;
                PORTB = 0x01;
            }
        }
    }
}