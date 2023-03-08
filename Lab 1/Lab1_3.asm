.include "m328PBdef.inc"

.def cnt = r20
.def temp = r21

reset:
	ldi r24,low(RAMEND)	    ; Initialize Stack Pointer
	out SPL,r24
	ldi r24,high(RAMEND)
	out SPH,r24
	clr r22			        ; r22 <- LED register
	
main:				    					
	ser temp		        ; Set temp register
	out DDRD,temp		    ; PORTD is output
	ldi r22,0x01		    ; Initialize r22 (LED) to 0x01 (LSB)
	ldi cnt,7		        ; Initialize counter to 7
	set			            ; Initialize T flag to 1 (first time led moves towards left)

left_wait:
	ldi r24,low(500)	    
	ldi r25,high(500)
	rcall wait_msec
	ldi r22,0x01
	out PORTD,r22		    ; Show on PORTD
	ldi r24,low(1000)	    ; Extra 1 sec delay when reaches LSB
	ldi r25,high(1000)	    
	rcall wait_msec
	dec cnt
	
left:	
	set			            ; T flag = 1
	ldi r24,low(500)	    ; 0.5 sec delay
	ldi r25,high(500)	    
	rcall wait_msec
	clc			            ; Reset C flag, because changed from wait function
	rol r22			        ; So we can do rotate left + carry
	out PORTD,r22		    ; Show on PORTD
	dec cnt			    
	cpi cnt,0
	breq right_wait		    ; When reach 0100 0000 go to right_wait		    
	rjmp left		    
	
right_wait:						
	ldi r24,low(500)	    
	ldi r25,high(500)
	rcall wait_msec
	ldi r22,0x80
	out PORTD,r22		    ; Show on PORTD
	ldi r24,low(1000)	    ; Extra 1 sec delay when reaches MSB
	ldi r25,high(1000)	   
	rcall wait_msec	
	inc cnt
		
right:       
	clt			            ; T flag = 0
	ldi r24,low(500)	    ; 0.5 sec delay
	ldi r25,high(500)	    
	rcall wait_msec	
	clc			            ; Reset C flag, because changed from wait function
	ror r22			        ; So we can do rotate left + carry
	out PORTD,r22		    ; Show on PORTD	    
	inc cnt			    
	cpi cnt,7		    
	breq left_wait		    ; When reach 0000 0010 go to left_wait      
	rjmp right		   

wait_msec:			        ; Same with Lab1_1.asm	    
	push r24		    
	push r25		     
	ldi r24,low(125)	     
	ldi r25,high(125)	    
	rcall wait_usec		    
	pop r25			  
	pop r24			 
	sbiw r24,1		   
	brne wait_msec		    
	ret			   

wait_usec:				    			 
	sbiw r24,1		    
	nop			    
	nop			  
	nop			    
	nop			   
	brne wait_usec		    
	ret			    
