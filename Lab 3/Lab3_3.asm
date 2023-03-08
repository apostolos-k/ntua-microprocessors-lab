.include "m328PBdef.inc"            ; ATmega328P microcontroller definitions
    
.equ FOSC_MHZ=16                    ; Microcontroller operating frequency in MHZ

ldi r24,(0<<WGM10)|(1<<WGM11)|(1<<COM1A1)
sts TCCR1A,r24
ldi r24,(1<<WGM12)|(1<<CS11)|(1<<WGM13)
sts TCCR1B,r24
    
; Init Stack Pointer
ldi r24, LOW (RAMEND)
out SPL, r24
ldi r24, HIGH (RAMEND)
out SPH, r24
   
ser r26
out DDRB,r26
clr r27
out DDRD,r27                        ; Init PORTD input

main:
ldi r24,HIGH(0)
sts ICR1H,r24
ldi r24,LOW(0)	                    ; Overflow after 4 sec
sts ICR1L,r24 

in r20, PIND
cpi r20, 0b11111110
breq buzz_0
cpi r20, 0b11111101
breq buzz_1
cpi r20, 0b11111011
breq buzz_2
cpi r20, 0b11110111
breq buzz_3
rjmp main

buzz_0:
in r20,PIND
cpi r20, 0b11111110
brne main  
    
ldi r24,HIGH(0x1F40)
sts OCR1AH,r24
ldi r24,LOW(0x1F40)	                ; 8000
sts OCR1AL,r24  
    
ldi r24,HIGH(0x3E7F)
sts ICR1H,r24
ldi r24,LOW(0x3E7F)	                ; 15999
sts ICR1L,r24
rjmp buzz_0
    
buzz_1:
in r20,PIND
cpi r20, 0b11111101
brne main  
    
ldi r24,HIGH(0x0FA0)
sts OCR1AH,r24
ldi r24,LOW(0x0FA0)                 ; 4000
sts OCR1AL,r24  
    
ldi r24,HIGH(0x1F3F)
sts ICR1H,r24
ldi r24,LOW(0x1F3F)	                ; 7999
sts ICR1L,r24
rjmp buzz_1
    
buzz_2:
in r20,PIND
cpi r20, 0b11111011
brne main  
    
ldi r24,HIGH(0x07D0)
sts OCR1AH,r24
ldi r24,LOW(0x07D0)	                ; 2000
sts OCR1AL,r24     
    
ldi r24,HIGH(0x0F9F)
sts ICR1H,r24
ldi r24,LOW(0x0F9F)	                ; 3999
sts ICR1L,r24
rjmp buzz_2
    
buzz_3:
in r20,PIND
cpi r20, 0b11110111
brne jmp_main	                    ; Instead of brne main, because main is 'out of range'
rjmp continue
    
jmp_main:
rjmp main
    
continue:    
ldi r24,HIGH(0x03E8)
sts OCR1AH,r24
ldi r24,LOW(0x03E8)	                ; 1000
sts OCR1AL,r24     
    
ldi r24,HIGH(0x07CF)
sts ICR1H,r24
ldi r24,LOW(0x07CF)	                ; 1999
sts ICR1L,r24
rjmp buzz_3 
