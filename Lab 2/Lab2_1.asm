.include "m328PBdef.inc"            ; ATmega328P microcontroller definitions

.equ FOSC_MHZ=16                    ; Microcontroller operating frequency in MHZ
.equ DEL_mS=500                     ; Delay in mS (valid number from 1 to 4095)
.equ DEL_NU=FOSC_MHZ*DEL_mS         ; delay mS routine: (1000* DEL NU+6) cycles

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

sei                                 ; Sets the Global Interrupt Flag

; Init Stack Pointer
ldi r24, LOW (RAMEND)
out SPL, r24
ldi r24, HIGH (RAMEND)
out SPH, r24

; Init PORTB and PORTC as output
ser r26
out DDRB, r26
out DDRC, r26

; Init PORTD as input
clr r27
out DDRD,r27

ldi r20,0

loop1:
clr r26

loop2:
out PORTB, r26

ldi r24, low (DEL_NU)
ldi r25, high (DEL_NU)              ; Set delay (number of cycles)
rcall delay_mS

inc r26

cpi r26, 16                         ; compare r26 with 16
breq loop1
rjmp loop2

;delay of 1000* F1+6 cycles (almost equal to 1000* Fl cycles)
delay_mS:

; total delay of next 4 insruction group = 1+ (249*4-1) 996 cycles
ldi r23, 249                        ; (1 cycle)

loop_inn:

dec r23		                        ; 1 cycle
nop		                            ; 1 cycle
brne loop_inn	                    ; 1 or 2 cycles
sbiw r24,1	                        ; 2 cycles
brne delay_mS	                    ; 1 or 2 cycles
ret		                            ; 4 cycles

ISR1:                               ; Interupt Routine
push r25
push r24
in r24, SREG		                ; Save r24, r25, SREG
push r24

INT_1:
ldi r24,(1<<INTF1)
out EIFR,r24
ldi r24,low(80)
ldi r25,high(80)                    ; Set delay (number of cycles)
rcall delay_mS
in r24,EIFR
sbrc r24,1                          ; If bit1 = 0 (clear) then skip next line
rjmp INT_1

in r23,PIND
andi r23,0x80	                    ; Mask PD7
cpi r23,0x00	                    ; 0 = Pressed
breq exodos

cpi r20,0x1F ;31 dec
brne cont
ldi r20, 0x00
cont:
inc r20
out PORTC,r20

exodos:
pop r24
out SREG ,r24                       ; Restore r24, r25, SREG
pop r24
pop r25
reti
