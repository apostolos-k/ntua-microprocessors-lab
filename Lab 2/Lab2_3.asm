.include "m328PBdef.inc"                ; ATmega328P microcontroller definitions
    
.equ FOSC_MHZ=16                        ; Microcontroller operating frequency in MHZ
.equ DEL_mS=4000                        ; Delay in mS (valid number from 1 to 4095)
.equ DEL_NU=FOSC_MHZ*DEL_mS             ; delay mS routine: (1000* DEL NU+6) cycles
    
; INTERRUPT INT1
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1
    
reset:
; Interupt on rising edge of INT1 pin
ldi r24,(1<<ISC11) | (1<< ISC10) 
sts EICRA, r24
; Enable the INT1 interrupt (PD3)
ldi r24, (1 << INT1)
out EIMSK, r24
    
sei                                     ; Sets the Global Interrupt Flag
    
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

main:
ldi r18,0x00		                    ; Counter
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
    
ISR1:                                   ; Interupt Routine
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
ldi r19,0x01
out PORTB,r19
ldi r24, low (DEL_NU)	
ldi r25, high (DEL_NU)                  ; Set delay (number of cycles)
rcall delay_mS
ldi r19,0x00
out PORTB,r19
ldi r18,0x00
jmp cont2
    
cont1:		                            ; 0.5 sec delay
ldi r19,0xFF
out PORTB,r19
ldi r24, low (8000)	
ldi r25, high (8000)                    ; Set delay (number of cycles)
rcall delay_mS
ldi r19,0x01
out PORTB,r19
ldi r24, low (DEL_NU)	
ldi r25, high (DEL_NU)                  ; Set delay (number of cycles)
rcall delay_mS
ldi r19,0x00
out PORTB,r19
ldi r18,0x00

cont2: 
pop r24
out SREG ,r24                           ; Restore r24, r25, SREG
pop r24 
pop r25
reti
