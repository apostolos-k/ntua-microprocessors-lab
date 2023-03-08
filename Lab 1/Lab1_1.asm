.include "m328PBdef.inc"
    
reset:
    ldi r24 , low(RAMEND)	        ; Initialize Stack Pointer
    out SPL ,r24    
    ldi r24 , high(RAMEND)
    out SPH ,r24

main:
    ldi r24,low(2000)		        ; 2000 msec delay
    ldi r25,high(2000)
    rcall wait_msec
    rjmp end
    
wait_msec:			                ; 1 msec delay per call
    push r24			            ; 2 cycles
    push r25			            ; 2 cycles
    ldi r24,low(125)		        ; 1 cycle
    ldi r25,high(125)		        ; 1 cycle
    rcall wait_usec		            ; 3 cycles
    pop r25			                ; 2 cycles
    pop r24			                ; 2 cycles
    sbiw r24,1			            ; 2 cycles
    brne wait_msec		            ; 1 or 2 cycles
    ret				                ; 4 cycles
    
wait_usec:			                ; Called 125 times
                                    ; Because 8 * 125 = 1000 usec = 1msec (needs 8 cycles => 8 usec per call)
    sbiw r24,1		                ; 2 cycles (2 usec)
    nop				                ; 1 cycle (1 usec)
    nop				                ; 1 cycle (1 usec)
    nop				                ; 1 cycle (1 usec)
    nop				                ; 1 cycle (1 usec)
    brne wait_usec		            ; 1 or 2 cycles (1 or 2 usec)
    ret				                ; 4 cycles (4 usec)

end:
