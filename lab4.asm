    .ORIG x3000

; BLOCK 1
; Register R0 is loaded with m[x6000].
; This will serve as the pointer to the head node of the linked list.
;  

	LDI R0, PTR1
	LD R7, COUNTER

	

; 

    BR  BLOCK2
PTR1    .FILL   x6000


    
    
; BLOCK 2
; 
; In this block you will prompt the user for the Building Abbreviation and Room Number 
; by printing on the monitor the string “Type the room to be reserved and press Enter: ” 
; and wait for the user to input a string followed by <Enter> (ASCII: x0A). 
; (Assume that there is no case where the user input exceeds the maximum number of characters).

BLOCK2  LEA R0, PROMPT
        PUTS
        
        LEA R1, USERINPUT
        

LOOP    GETC

        BR CHECKENTER

RESUME  OUT
        STR R0, R1, #0; Store R0 ascii in MEM[R1]
        ADD R1, R1, #1; increment R1 to next reserved memory location
        BR LOOP
        


CHECKENTER
    LD R2, ASCII; loads R2 with X0A aka +10
    NOT R2, R2; nots R2
    ADD R2, R2, #1; R2 is now -10
    ADD R3, R0, R2; Perform R0-R2(10-10)
    BRz BLOCK3; if R2 is zero go to block 3
    BR RESUME; if r2 not zero then continue reading characters
    
; Check if the user inputs an Enter, whose ASCII code is x0A.
; If it is not Enter, then store the character at the reserved block of memory labeled USERINPUT
; The reserved block of memory is 11 locations (maximum of 10 characters, and null terminator).
; In this block you must also display each character that the user types.


    







        

PROMPT  .STRINGZ    "Type the room to be reserved and press Enter: "  
USERINPUT   .BLKW   xB
ASCII .FILL X0A


; Block 3: In this block you will check if there is a match between the entered 
; user string with an entry in the linked list.
; Your program must search the list of currently available rooms to find a match for the 
; entered Building Abbreviation and Room Number. The list stores all the currently available rooms. 
; You will find a match only if the room is in the list. It is possible to not find a match in the list. 

; If your program finds a match, then it must print out “<Building Abbreviation and Room Number> 
; is currently available!” (eg., “GSB 2.126 is currently available!”)

; Note that if there is a match, it must branch to DONE.
; If there is no match, it must branch to BLOCK4

BLOCK3
    LDI R0, PTR1; loads R0 with mem[x6000] = x6005
    BRz NO_MATCH
    
    

SEARCH_LOOP
    ;check if first word in node is 0
    LDR R1, R0, #0; loads R1 with mem[R0]
    BRz NODE_COUNTER

RUNNER 
    LDR R1, R0, #1; loads R1 with mem[R0+1] ex x7000
    
    LEA R2, USERINPUT;  R2 points to userinput
    
    ;r3 goes through room entries and r4 goes through userinput
    LDR R3, R1, #0; loads R3 with MEM[R1] ex MEM[X7000] points to room entry
    LDR R4, R2, #0; R4 = MEM[R3] aka going through userinput memory blocks
    BRz CHECK_COUNTER
    ADD R7, R7, #1
    ADD R4, R4, #0
    BRz STRINGS_MATCH; if nullptr reached then strings match

    BR COMPARE_LOOP
    

NODE_COUNTER
    ADD R7, R7, #0
    BRz RUNNER
    BRnp NO_MATCH

CHECK_COUNTER
    ADD R7, R7, #0
    BRz NO_MATCH
    
COMPARE_LOOP
    
    NOT R5, R3; not R3
    ADD R5, R5, #1; R5 = -R3
    ADD R5, R4, R5; R5 = R4-R5
    BRnp STRINGS_DIFFER
    
    ADD R1, R1, #1; increment R1 by 1 ex: X7000 + 1
    ADD R2, R2, #1; increment R2 by 1 to get next memLoc in userinput
    BRnzp COMPARE_UPDATE_CHECK

;loads r3 and r4 with updated r1 and r2 values and runs checks again
COMPARE_UPDATE_CHECK
    LDR R3, R1, #0; loads R3 with MEM[R1] ex MEM[X7000] points to room entry
    LDR R4, R2, #0; R4 = MEM[R3] aka going through userinput memory blocks
    BRz STRINGS_MATCH; if nullptr reached then strings match
    
    BR COMPARE_LOOP
    
STRINGS_MATCH
    LEA R0, USERINPUT
    PUTS
    
    LEA R0, MATCHLIST
    PUTS
    
    BR DONE
    

STRINGS_DIFFER
    LDR R0, R0, #0; R0 = MEM[R0] ex: MEM[X6005] = X600A
    BRz NO_MATCH
    BR SEARCH_LOOP
    
    
    
    
    
NO_MATCH
    BR BLOCK4
    



















COUNTER .FILL #0
MATCHLIST  .STRINGZ    " is currently available!"

; Block 4: You will enter this block only if there was no match with the linked list. 
; In this block you must print out “<Building Abbreviation and Room Number> is NOT currently available.” 
; (eg., “GSB 2.126 is NOT currently available.”).
;

BLOCK4
    LEA R0, USERINPUT
    PUTS
    
    LEA R0, NOMATCHTLIST
    PUTS
    
    BR DONE




















NOMATCHTLIST  .STRINGZ    " is NOT currently available."








DONE    HALT
    

    .END

