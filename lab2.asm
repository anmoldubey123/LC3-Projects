    .ORIG x3000
; BLOCK 1
; Register R0 is loaded with x7500.
; Register R1 is loaded with the address of the location where the number is located.
; 

	LD R0,PTR
	LDR R1,R0, #0
; 
; The two 8-bit numbers are now loaded into R1.

    LDR R1, R1, #0

    
    
; BLOCK 2
; In this block, the two unsigned numbers in bits [15:8] and [7:0] on register R1, are first isolated by using masks.
; Mask1 is loaded into R4. The mask is then used to isolate Number 1, which is then loaded into R2.
; Mask2 is loaded into R4. The mask is then used to isolate Number 2, which is then loaded into R3.
; 
; 
	LD R4, MASK1
	AND R2, R1, R4; R2 stores output of (R1 AND MASK1), R2 is number 1 aka bits[7:0]
	





	LD R4, MASK2	
	AND R3, R1, R4; R3 stores output of (R1 AND MASK2), R3 is number 2 aka bits [15:8]
	
; BLOCK 3
; In this block Number 2 is rotated so that the bits are in R3[7:0].
    LD R5, CHECKER; load r5 with checker x0008
    
ITERATOR
    ADD R3, R3, #0
    BRP SIGBITZERO
    BRN SIGBITONE

SIGBITZERO
    ADD R3, R3, R3
    ADD R5, R5, #-1
    BRnp ITERATOR
    BRZ NEWITERATOR

SIGBITONE
    ADD R3, R3, #0
    ADD R3, R3, R3
    ADD R3, R3, #1
    ADD R5, R5, #-1
    BRnp ITERATOR
    BRZ NEWITERATOR



; BLOCK 4
; The numbers are added. The result is stored at the location whose address is in x750A.
NEWITERATOR
    ADD R2, R2, R3
    LDI R0, FINALPOINTER
    STR R2, R0, #0












    HALT
    
    
PTR     .FILL   x7500
MASK1	.FILL	x00FF
MASK2	.FILL	xFF00
CHECKER .FILL   X0008
FINALPOINTER .FILL  X750A


    .END

