.include "m328PBdef.inc"                ; ATmega328P microcontroller definitions
   
.equ FOSC_MHZ=16                        ; Microcontroller operating frequency in MHZ
.equ DEL_mS=600                         ; Delay in mS (valid number from 1 to 4095)
.equ DEL_NU=FOSC_MHZ*DEL_mS             ; delay mS routine: (1000* DEL NU+6) cycles
    
; INTERRUPT INT0
.org 0x0
rjmp reset
.org 0x2
rjmp ISR0
    
reset:
; Interupt on rising edge of INT0 pin
ldi r24,(1<<ISC01) | (1<< ISC00) 
sts EICRA, r24
; Enable the INT0 interrupt (PD2)
ldi r24, (1 << INT0)
out EIMSK, r24
    
sei                                     ; Sets the Global Interrupt Flag
    
; Init Stack Pointer
ldi r24, LOW (RAMEND)
out SPL, r24
ldi r24, HIGH (RAMEND)
out SPH, r24
    
; Init PORTC as output
ser r26
out DDRC, r26
    
; Init PORTB as input
clr r27
out DDRB,r27

ldi r20,0                               ; Input from PORTB
ldi r21,0                               ; Counter of zeros
ldi r18, 0x00	                        ; LED output
    
loop1:
clr r26
    
loop2:
out PORTC, r26
    
ldi r24, low (DEL_NU)	
ldi r25, high (DEL_NU)                  ; Set delay (number of cycles)
rcall delay_mS
    
inc r26
    
cpi r26, 32                             ; Compare r26 with 32
breq loop1
rjmp loop2
    
    
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
    
ISR0:                                   ; Interupt Routine
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
  
;1st iteration
in r20, PINB
ror r20	                                ; C flag <- LSB
brcs next_1	                            ; if C = 1 then jump to next_1
inc r21

;2nd
next_1:
ror r20	                                ; C flag <- LSB
brcs next_2	                            ; if C = 1 then jump to next_2
inc r21

;3d
next_2:
ror r20	                                ; C flag <- LSB
brcs next_3	                            ; if C = 1 then jump to next_3
inc r21
 
;4th
next_3:
ror r20	                                ; C flag <- LSB
brcs next_4	                            ; if C = 1 then jump to next_4
inc r21

;5th
next_4:
ror r20		                            ; C flag <- LSB
brcs next_5	                            ; if C = 1 then jump to next_5
inc r21

;6th    
next_5:
ror r20		                            ; C flag <- LSB
brcs next_6	                            ; if C = 1 then jump to next_6
inc r21   
    
next_6:
ldi r18, 0x00

check:
cpi r21, 0x00	                        ; Compare zeros counter to 0
breq fin
inc r18
rol r18
subi r21,1
rjmp check   
    
fin:
ldi r21, 0x00
ror r18
out PORTC, r18
ldi r24,low(8000)	
ldi r25,high(8000) 
rcall delay_mS	                        ; Show how many are pressed for 0.5 sec
pop r24
out SREG ,r24                           ; Restore r24, r25, SREG
pop r24 
pop r25
reti
