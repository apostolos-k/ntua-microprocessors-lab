.include "m328PBdef.inc"                ; ATmega328P microcontroller definitions
    
.equ FOSC_MHZ=16                        ; Microcontroller operating frequency in MHZ
 
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1
.org 0x1A
rjmp ISR_TIMER1_OVF

reset:
; Interupt on rising edge of INT1 pin
ldi r24,(1<<ISC11) | (1<< ISC10) 
sts EICRA, r24
; Enable the INT1 interrupt (PD3)
ldi r24, (1 << INT1)
out EIMSK, r24
  
; Timer1 Interupts
ldi r24,(1<<TOIE1)  
sts TIMSK1,r24
ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)   ; CLK/1024
sts TCCR1B,r24

sei                                     ; Sets the Global Interrupt Flag

; Init Stack Pointer
ldi r24, LOW (RAMEND)
out SPL, r24
ldi r24, HIGH (RAMEND)
out SPH, r24
    
; Init PORTB as output
ser r26
out DDRB, r26
   
; Init PORTD & PORTC as input
clr r27
out DDRD,r27
out DDRC,r27
    
ldi r18,0x00	                        ; Counter
ldi r20, 0x00	                        ; 0.5 sec counter
    
main:
in r23,PINC
andi r23,0x20	                        ; Mask PC5
cpi r23,0x00	                        ; 0 = Pressed
breq pathmeno   
rjmp main
    
;delay of 1000* F1+6 cycles (almost equal to 1000* Fl cycles)
delay_mS:
    
; total delay of next 4 insruction group = 1+ (249*4-1) 996 cycles
ldi r23, 249                            ; (1 cycle)
    
loop_inn:

dec r23		                            ; 1 cycle
nop		                                ; 1 cycle
brne loop_inn	                        ; 1 or 2 cycles
sbiw r24,1	                            ; 2 cycles
brne delay_mS	                        ; 1 or 2 cycles
ret		                                ; 4 cycles
    
pathmeno:
    
SPINTH:
ldi r24,low(80)	
ldi r25,high(80)                        ; Set delay (number of cycles)
rcall delay_mS
in r23,PINC
andi r23,0x20	                        ; Mask PC5
cpi r23,0x00	                        ; 0 = Pressed
breq SPINTH  
    
inc r18
cpi r18,0x01                            ; If cpi result is 0, then it is the first time and
                                        ; 4 sec (cont_a) delay will be called, else 0.5 sec (cont1_a)
brne cont1_a

cont_a:		                            ; 4 sec delay
ldi r24,HIGH(3035)
sts TCNT1H,r24
ldi r24,LOW(3035)	                    ; Overflow after 4 sec
sts TCNT1L,r24  
    
ldi r19,0x01
out PORTB,r19
rjmp main 
    
cont1_a:		                        ; 0.5 sec delay
ldi r24,HIGH(57722)
sts TCNT1H,r24
ldi r24,LOW(57722)	                    ; Overflow after 0.5 sec
sts TCNT1L,r24       

ldi r19,0xFF
out PORTB,r19

; Check if 0.5 sec passed	  
inc r20
checking_a:
cpi r20,0x00
brne checking_a     
                          
ldi r18,0x01                            ; Timer1 routine sets r18 = 0, but we are inside the renewal
    
ldi r24,HIGH(3035)
sts TCNT1H,r24
ldi r24,LOW(3035)	                    ; Overflow after 4 sec
sts TCNT1L,r24   
    
ldi r19,0x01
out PORTB,r19
rjmp main
   
; Interupt Routine     
ISR1: 
push r25 
push r24
in r24, SREG		                    ; Save r24, r25, SREG
push r24
 
INT_1:
ldi r24,(1<<INTF1)
out EIFR,r24
ldi r24,low(80)	
ldi r25,high(80)                        ; Set delay (number of cycles)
rcall delay_mS
in r24,EIFR
sbrc r24,1
rjmp INT_1    
    
inc r18
cpi r18,0x01		                    ; If cpi result is 0, then it is the first time and
                                        ; 4 sec (cont) delay will be called, else 0.5 sec (cont1)

brne cont1

cont:		                            ; 4 sec delay
ldi r24,HIGH(3035)
sts TCNT1H,r24
ldi r24,LOW(3035)	                    ; Overflow after 4 sec
sts TCNT1L,r24  

ldi r19,0x01
out PORTB,r19
jmp cont2
    
cont1:		                            ; 0.5 sec delay
ldi r24,HIGH(57722)
sts TCNT1H,r24
ldi r24,LOW(57722)	                    ; Overflow after 0.5 sec
sts TCNT1L,r24  

ldi r19,0xFF
out PORTB,r19

; Check if 0.5 sec passed	  
inc r20
checking:
cpi r20,0x00
brne checking 
    
ldi r18,0x01                            ; Timer1 routine sets r18 = 0, but we are inside the renewal

ldi r24,HIGH(3035)
sts TCNT1H,r24
ldi r24,LOW(3035)	                    ; Overflow after 4 sec
sts TCNT1L,r24  

ldi r19,0x01
out PORTB,r19

cont2: 
pop r24
out SREG ,r24                           ; Restore r24, r25, SREG
pop r24 
pop r25
reti
    
ISR_TIMER1_OVF:
ldi r18, 0x00	                        ; Reset counter
ldi r20,0x00	                        ; Reset 0.5sec counter
ldi r16, 0x00
out PORTB, r16
reti
