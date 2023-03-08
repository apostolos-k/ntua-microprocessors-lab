.include "m328PBdef.inc"
    
.def temp = r15
.def temp1 = r16
.def A = r17
.def B = r18
.def C = r19
.def D = r20    
.def F0 = r21
.def F1 = r22
   
reset:
    ldi r24 , low(RAMEND)
    out SPL ,r24
    ldi r24 , high(RAMEND)
    out SPH ,r24
    
init:
    ldi r23, 0x07	        ; Counter
    ldi A, 0x55		    
    ldi B, 0x43
    ldi C, 0x22
    ldi D, 0x02
    
main:
    subi r23, 1
    breq end
    
    mov F0,A
    com F0		            ; F0 = A'
    mov temp,B
    com temp		        ; temp = B'
    and F0,temp		        ; F0 = A'B'
    and temp,D		        ; temp = B'D
    or F0,temp		        ; F0 = A'B' + B'D
    com F0		            ; F0 = (A'B' + B'D)'
    
    mov F1,A
    or F1,C		            ; F1 = A+C
    com temp		        ; temp = B+D' (De Morgan's)
    and F1,temp		        ; F1 = (A+C)(B+D')

    ldi temp1,2		        ; Increase variables accordingly
    add A,temp1
    ldi temp1,3
    add B,temp1
    ldi temp1,4
    add C,temp1
    ldi temp1,5
    add D,temp1
    
    jmp main
    
end:
