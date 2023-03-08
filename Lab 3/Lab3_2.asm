.include "m328PBdef.inc"            ; ATmega328P microcontroller definitions
    
.equ FOSC_MHZ=16                    ; Microcontroller operating frequency in MHZ
    
ldi r24,(1<<WGM10)|(1<<COM1A1)
sts TCCR1A,r24
ldi r24,(1<<WGM12)|(1<<CS11)
sts TCCR1B,r24
    
; Init Stack Pointer
ldi r24, LOW (RAMEND)
out SPL, r24
ldi r24, HIGH (RAMEND)
out SPH, r24

; Init PORTB as output
ser r26
out DDRB, r26
   
; Init PORTD as input
clr r27
out DDRD,r27

clr r17		                        ; For the ZH register
ldi r21, 0x06	                    ; Init array position at the middle, 50% DC

ldi r18, 0x80
sts OCR1AL,r18                      ; 50% DC
    
main:   
; Load on Z register the array address
ldi zh,HIGH(Table*2)
ldi zl,LOW(Table*2)
    
in r20, PIND
cpi r20, 0b11111101                 ; PD1
breq butt_1
cpi r20, 0b11111011                 ; PD2
breq butt_2
rjmp main
    
butt_1:
in r20,PIND
cpi r20, 0b11111101
breq butt_1	                        ; For spinthirismos

cpi r21,0x0C	                    ; 12 decimal
breq main
inc r21
 
mov r22,r21
lsl r22	                            ; r22 x 2
add zl,r22
adc zh,r17                          ; r17 = 0
lpm	                                ; r0 <- Z
mov r19,r0

sts OCR1AL,r19
rjmp main
    
butt_2:
in r20,PIND
cpi r20, 0b11111011
breq butt_2	                        ; For spinthirismos

cpi r21,0x00
breq main
dec r21
    
mov r22,r21
lsl r22	                            ; r22 x 2
add zl,r22
adc zh,r17                          ; r17 = 0
lpm	                                ; r0 <- Z
mov r19,r0

sts OCR1AL,r19
rjmp main
  
Table:
.DW 0x0005, 0x001A, 0x002E, 0x0043, 0x0057, 0x006C, 0x0080, 0x0094, 0x00A7, 0x00BD, 0x00D2, 0x00E6, 0x00FB
