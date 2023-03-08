.include "m328PBdef.inc"    ; ATmega328P microcontroller definitions
 
.equ PD3 = 3
.equ PD2 = 2
    
.def temp = r16 
.def counter = r17
.def ADC_L = r21 
.def ADC_H = r22
  
.org 0x00
rjmp reset
.org 0x2A	                ; ADC Conversion Complete Interrupt
rjmp adc_int  
    
write_2_nibbles:
push r24
in r25 ,PIND 
andi r25 ,0x0f 
andi r24 ,0xf0 
add r24 ,r25
out PORTD ,r24 
sbi PORTD ,PD3
cbi PORTD ,PD3 
nop
nop
pop r24
swap r24
andi r24 ,0xf0 
add r24 ,r25
out PORTD ,r24 
sbi PORTD ,PD3
cbi PORTD ,PD3
nop
nop
ret
    
lcd_data:
sbi PORTD ,PD2
rcall write_2_nibbles
ldi r24 ,100
ldi r25 ,0
rcall wait_usec
ret
    
lcd_command:
cbi PORTD ,PD2
rcall write_2_nibbles
ldi r24 ,100
ldi r25 ,0
rcall wait_usec
ret

lcd_init:
ldi r24 ,100
ldi r25 ,0
rcall wait_msec
ldi r24 ,0x30
out PORTD ,r24 
sbi PORTD ,PD3 
cbi PORTD ,PD3 
ldi r24 ,100
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x30
out PORTD ,r24 
sbi PORTD ,PD3 
cbi PORTD ,PD3 
ldi r24 ,100
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x20
out PORTD ,r24 
sbi PORTD ,PD3 
cbi PORTD ,PD3 
ldi r24 ,100
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x28
rcall lcd_command
ldi r24 ,0x0c
rcall lcd_command
ldi r24 ,0x01
rcall lcd_command
ldi r24 ,low(5000) 
ldi r25 ,high(5000) 
rcall wait_usec
ldi r24 ,0x06
rcall lcd_command
ret
 
reset:
ldi temp, high(RAMEND)
out SPH,temp
ldi temp, low(RAMEND) 
out SPL,temp
    
ldi temp, 0xFF 
out DDRD, temp	                ; Set PORTD as output
out DDRB, temp
	
ldi temp, 0x00 
out DDRC, temp	                ; Set PORTC as input
    
sei
    
; REFSn[1:0]=01 => select Vref=5V, MUXn[4:0]=0000 => select ADC0(pin PC0), 
; ADLAR=0 => RIGHT adjust the ADC result
ldi temp, 0b01000010 
sts ADMUX, temp
    
; ADEN=1 => ADC Enable, ADCS=0 => No Conversion,
; ADIE=1 => ENable adc interrupt, ADPS[2:0]=111 => fADC=16MHz/128=125KHz 
ldi temp, 0b11101111
sts ADCSRA, temp 
    
ldi temp, 0b00000000
sts ADCSRB, temp  

ldi temp,0x00

main:   
out PORTB,temp
inc temp
ldi r24, low(1000)
ldi r25, high(1000) 
rcall wait_msec
jmp main
   
wait_msec:			        ; 1 msec delay per call
push r24			        ; 2 cycles
push r25			        ; 2 cycles
ldi r24,low(125)		    ; 1 cycle
ldi r25,high(125)		    ; 1 cycle
rcall wait_usec		        ; 3 cycles
pop r25			            ; 2 cycles
pop r24			            ; 2 cycles
sbiw r24,1			        ; 2 cycles
brne wait_msec		        ; 1 or 2 cycles
ret				            ; 4 cycles
    
wait_usec:			        ; Called 125 times
sbiw r24,1			        ; 2 cycles (2 usec)
nop				            ; 1 cycle (1 usec)
nop				            ; 1 cycle (1 usec)
nop				            ; 1 cycle (1 usec)
nop				            ; 1 cycle (1 usec)
brne wait_usec		        ; 1 or 2 cycles (1 or 2 usec)
ret				            ; 4 cycles (4 usec)
    
adc_int:
rcall lcd_init 
ldi r24, low(2)
ldi r25, high(2) 
rcall wait_msec
lds r17,ADCL 
lds r18,ADCH 
mov r22,r18
mov r21,r17
lsl r17
rol r18
lsl r17
rol r18
add r17,r21
adc r18,r22
mov r22,r18
andi r18,0b00011100
sub r22,r18
lsr r18
lsr r18
ori r18,0b00110000
mov r26,r18	                ; MSB -> r26

;gia to 2o psifio
mov r21,r17
mov r18,r22
lsl r17
rol r18
lsl r17
rol r18
lsl r17
rol r18
add r17,r21
adc r18,r22
add r17,r21
adc r18,r22
mov r22,r18
andi r18,0b00111100
sub r22,r18
lsr r18
lsr r18
ori r18,0b00110000
mov r27, r18	            ; 1st decimal -> r27
    
;gia to 3o psifio
mov r21,r17
mov r18,r22
lsl r17
rol r18
lsl r17
rol r18
lsl r17
rol r18
add r17,r21
adc r18,r22
add r17,r21
adc r18,r22
mov r22,r18
andi r18,0b00111100
sub r22,r18
lsr r18
lsr r18
ori r18,0b00110000
 
mov r24,r26
rcall lcd_data
    
ldi r24,'.'
rcall lcd_data
    
mov r24,r27
rcall lcd_data
    
mov r24,r18
rcall lcd_data
ldi r24, low(500)
ldi r25, high(500)
rcall wait_msec
    
reti
