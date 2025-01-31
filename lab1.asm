    .ORIG x3000
    
; Name: Anmol Dubey
; Date: 10/11/2024
; Lab #1
;

; BLOCK 1
; Register R0 is loaded with x7000, which will serve as a pointer.
; The two data are read into registers R1 and R2. 

    LD  R0, PTR ; R0 will serve as the pointer to x7000
    LDR R1, R0, #0 ; R1 gets loaded with m[x7000]
    LDR R2, R0, #5 ; R2 gets loaded with m[x7005]
    

; BLOCK 2
; In this block, the two 2's complement numbers in bits [15:8], are first isolated by clearing bits [7:0].
; The sum of these two numbers is performed, followed by the check for overflow, which will be done in BLOCK 3.
; Number 1 will be loaded in R1[15:8].
; Number 2 will be loaded in R2[15:8].
; The sum will be loaded in R3[15:8].
; 
    
    LD R3, MASK1 ; R3 R3 will be loaded with FF00 as a mask
    AND R1, R1, R3 ; R1 stores output of R1 AND R3
    AND R2, R2, R3 ; R2 stores output of R2 AND R3 
    
    ADD R3, R1, R2 ; R3 stores output of R1 + R2







; BLOCK 3

; The first 2's complement number has been loaded into R1 - this was done in BLOCK 2.
; The second 2's complement number has been loaded into R2 - this was done in BLOCK 2.
; The sum of the two numbers has been loaded into R3 - this was done in BLOCK 2.
; All numbers are in bits [15:8] with zeros in [7:0].
; 
; In this block we will check for overflow of the 2's complement integer addition.
; The signs of the two numbers and the sign of the calculated sum will be checked. 
; A mismatch indicates an overflow.
; 
; 
; If there was no overflow, then store the sum in x700F[15:8].
; If there was overflow, then store xBADD in x700F.




;check sign of first number, if pos, check next number, if neg, check next neg, else if zero, store the number

    LD R4, CHECKSIGN; load bit mask to check sign of operand 1
    AND R5, R4, R1
    BRZ CHECKNEXTPOS; if positive, then check the sign of operand 2
    BRN CHECKNEXTNEG;if negative, then check the sign of operand 2
    STR R3, R0, xF; if neither positive nor negative, then operand 1 must be 0, so store the sum
    BR DONE

CHECKNEXTPOS 
    AND R5, R4, R2
    BRZ CHECKSUMPOS; if operand 2 is also positive, check if sum if also positive
    STR R3, R0, xF; if operand 2 is negative or 0, store the sum
    BR DONE

CHECKNEXTNEG
    AND R5, R4, R2
    BRN CHECKSUMNEG; if operand 2 is also negative, check if sum if also negative
    STR R3, R0, xF; if operand 2 is positive or 0, store the sum
    BR DONE

CHECKSUMPOS
    AND R5, R4, R3
    BRN OVERFLOW; if both the operands are positive but sum is negative, overflow has occurred
    STR R3, R0, xF; else if the sum is positive, store the sum
    BR DONE

CHECKSUMNEG
    AND R5, R4, R3
    BRZ OVERFLOW; if both the operands are negative but sum is positive, overflow has occurred
    STR R3, R0, xF; else if the sum is negative, store the sum
    BR DONE

OVERFLOW
    LD R4, OVERFLOWVAL
    STR R4, R0, xF; store xBADD 





    
; BLOCK 4
; In this block, the two unsigned numbers in bits [7:0], are first isolated by clearing bits [15:8].
; The sum of these two numbers is performed, followed by the check for overflow, which will be done in BLOCK 5.
; 

DONE    LD R0, PTR ; R0 will serve as pointer to x7000
        LDR R1, R0, #0 
        LDR R2, R0, #5
        
        LD R3, MASK2
        AND R1, R1, R3
        AND R2, R2, R3
        
        ADD R3, R1, R2







; BLOCK 5
; In this block we will check for overflow of the unsigned integer addition.
; The final carry out is what indicates overflow for unsigned integers.
; Since the unsigned integers are in bits [7:0], the final carry out will be in bit position 8.
; If there was no overflow, then store the sum in x700A.
; If there was overflow, then store xBADD in x700A.
    
    LD R0, PTR
    STR R3, R0, xA ; m[700A] <-- R3
    
    LD R4, OVER ; R4 is pointer to x0100
    AND R4, R3, R4 ; R4 stores output of R3 AND R4
    
    BRZ FINISH
    
    LD R3, OVERFLOWVAL
    
    STR R3, R0, xA
    
FINISH    HALT
    
    
PTR .FILL x7000
CHECKSIGN .FILL x8000
OVERFLOWVAL .FILL XBADD
MASK1 .FILL XFF00
MASK2 .FILL x00FF
OVER .FILL X0100


    .END

