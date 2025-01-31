    .ORIG x3000
; BLOCK 1
; Register R0 is loaded with x4000, which will serve as a pointer to the numbers.
;  

	LD R0, PTR; R0 = x4000
	LD R1, PTR2; R1 = x4001
	
	
    
    
; BLOCK 2
; This is the code that sorts in ascending order.
; You can break up this block into sub-blocks.
; 

LD R5, MASK

START
    LDR R2, R0, #0; R2 = m[R0]
    
ITERATOR
    AND R2, R2, R5; R2 stores output of R2 AND X00FF
    BRnp RUNNER
    BRz FIN

RUNNER
    LDR R2, R0, #0; R2 = M[R0]
    LDR R3, R1, #0; R3 = M[R1]
    
    AND R3, R3, R5; R3 = R3 AND X00FF
    
    BRz METHOD0 
    BRnp METHOD1

METHOD0
    ADD R0, R0, #1; R0 = R0 + 1
    ADD R1, R0, #1; R1 = R0 + 1
    BR START

METHOD1
    LDR R3, R1, #0; R3 = M[R1]
    JSR COMPARE; CALL JSR SUBROUTINE COMPARE
    
    ADD R4, R4, #0
    BRp SWAP
    BRz NOSWAP

SWAP
    STR R2, R1, #0; MEM[R1] = R2
    STR R3, R0, #0; MEM[R0] = R3
    
    ADD R1, R1, #1; R1 = R1 + 1
    BR RUNNER

NOSWAP
    ADD R1, R1, #1
    BR RUNNER

COMPARE
    ST R2, SaveR2; Save R2 in memory
    ST R3, SaveR3; Save R3 in memory
    ST R5, SaveR5; Save R5 in memory
    ST R6, SaveR6; Save R6 in memory 
    ST R7, SaveR7
    
    LD R4, MASK2
    AND R5, R2, R4; R5 = R2 AND XFF00
    
    LD R4, COUNTER
    
    LOOP5
        ADD R5, R5, #0
        BRP SBZ5
        BRN SBO5
    
    SBZ5
        ADD R5, R5, R5
        ADD R4, R4, #-1
        BRnp LOOP5
        BRz REGISTER6PRE
    
    SBO5
        ADD R5, R5, #0
        ADD R5, R5, R5
        ADD R5, R5, #1
        ADD R4, R4, #-1
        BRnp LOOP5
        BRz REGISTER6PRE
    
    REGISTER6PRE
        LD R4, MASK2
        AND R6, R3, R4
        LD R4, COUNTER
        BR LOOP6
    
    LOOP6
        ADD R6, R6, #0
        BRp SBZ6
        BRn SBO6
    
    SBZ6
        ADD R6, R6, R6
        ADD R4, R4, #-1
        BRnp LOOP6
        BRz FINISH
    
    SBO6
        ADD R6, R6, #0
        ADD R6, R6, R6
        ADD R6, R6, #1
        ADD R4, R4, #-1
        BRnp LOOP6
        BRz FINISH
    
    FINISH
        NOT R6, R6
        ADD R6, R6, #1
        ADD R5, R5, R6
        
        BRp YES
        BRn NO
    
    YES
        LD R4, ONE
        BR RESTORE
    
    NO 
        AND R4, R4, #0
        BR RESTORE
        
        
        
    
    
    RESTORE
        LD R2, SaveR2
        LD R3, SaveR3
        LD R5, SaveR5
        LD R6, SaveR6
    
        LD R7, SaveR7
        RET
        
    

SaveR2: .BLKW #1        
SaveR3: .BLKW #1        
SaveR5: .BLKW #1        
SaveR6: .BLKW #1        
SaveR7: .BLKW #1
    
FIN
    HALT
    

	
























    HALT
    
    
PTR .FILL x4000
PTR2 .FILL X4001
MASK .FILL X00FF
MASK2 .FILL XFF00
COUNTER .FILL X0008
ONE .FILL X0001

    .END

