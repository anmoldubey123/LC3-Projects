; BLOCK 1
; OPERATING SYSTEM CODE

;blockP: sets up interruptvectortable/modifies kbsr to interrupt when key pressed/prepares system stackr6 by saving psr and pc/switches to user program x3000 using RTI


.ORIG x500
        
        ;Purpose: Initializes the interrupt vector table entry at x0180 with the address of the ISR (x1700).
        LD R0, VEC  ; Loads the address x0180 (from label VEC) into register R0.
        LD R1, ISR  ; Loads the ISR starting address (x1700) into register R1.
        STR R1, R0, #0 ; Stores the value in R1 (x1700) into the memory address in R0 (x0180).


        ; Purpose: Enables keyboard interrupts by setting bit 14 in the KBSR to allow interrupts when the keyboard has input data.
        LD  R2, MASK; Loads xBFFF into R2, which will be used to modify the KBSR.
        LDI R3, KBSRPTR ; Loads the content of xFE00 (KBSR) into R3 indirectly via the pointer.
        
        NOT R3, R3; Complements R3, flipping all bits.
        AND R3, R2, R3; Applies bitmask xBFFF to set bit 14 of KBSR to 1.
        NOT R3, R3; Complements R3 again to revert changes for specific bits.
        
        STI R3, KBSRPTR ; Stores the modified value back into KBSR (memory-mapped at xFE00).
        
    
        
        ;Purpose: Sets up the system stack with the Program Counter (PC) and Processor Status Register (PSR), allowing the system to return to the user program.
        LD  R3, PSR      ; Loads x8002 (supervisor mode PSR) into R3.
        LD  R4, PC       ; Loads x3000 (user program start address) into R4.
        LD  R6, PC       ; Loads x3000 into R6 to initialize the stack pointer.
        ADD R6, R6, #-1  ; Decrements the stack pointer (R6) to make space for PSR.
        STR R3, R6, #0   ; Stores PSR (R3) onto the stack at the current stack pointer.
        ADD R6, R6, #-1  ; Decrements the stack pointer (R6) to make space for PC.
        STR R4, R6, #0   ; Stores PC (R4) onto the stack at the current stack pointer.

       ;Purpose: Transitions the processor to user mode and begins executing the user program.
        RTI; Returns from interrupt, switching to user mode and starting the program at x3000.
        
VEC     	.FILL x0180
ISR     	.FILL x1700
KBSRPTR		.FILL xFE00
MASK    	.FILL xBFFF 
PSR     	.FILL x8002
PC      	.FILL x3000
ENABLEBIT   	.FILL   x4000

.END


; BLOCK 2
; INTERRUPT SERVICE ROUTINE

;saves current state of system/reads keyboard input/determines upper/lowercase/displays message/restores system from interrupt

.ORIG x1700

;Purpose: Preserves the registers' values before modifying them in the ISR.

ST R0, SAVER0       ; Saves the value in R0 to memory (SAVER0).
ST R1, SAVER1       ; Saves the value in R1 to memory (SAVER1).
ST R2, SAVER2       ; Saves the value in R2 to memory (SAVER2).
ST R3, SAVER3       ; Saves the value in R3 to memory (SAVER3).
ST R7, SAVER7       ; Saves the value in R7 to memory (SAVER7).


; Purpose: Retrieves the key pressed by the user
LDI R0, KBDR; Loads the keyboard data from memory-mapped address xFE02 into R0.


LOOP1
    ;Purpose: Waits for the display to be ready for output.
    LDI R1, DSR      ; Loads the display status register (xFE04) into R1.
    BRZP LOOP1       ; Waits until the display is ready (DSR != 0).

    ;The code checks whether the input falls within ascii for lowercase or uppercase letters
    LD R1, ASCHIILCx     ; Loads offset for lowercase letters (-78) into R1.
    ADD R2, R1, R0       ; Adds R1 and R0 to check if the input is a lowercase letter.
    BRZ EXIT             ; If zero, it's a lowercase letter; branch to `EXIT`.
    
    LD R1, ASCHIIUCX     ; Loads offset for uppercase letters (-58) into R1.
    ADD R2, R1, R0       ; Adds R1 and R0 to check if the input is an uppercase letter.
    BRZ EXIT             ; If zero, it's an uppercase letter; branch to `EXIT`.

    ;Purpose: checks if r0 falls 0-9, if neg/>9 branches to ERROR if valid branches DIGITS
    LD R1, ASCHIINUM1  ; Load offset for numeric range start ('0') into R1 (x-30).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is negative, input is less than '0'.
    BRN ERROR          ; If result is negative (R2 < 0), branch to ERROR.
    LD R1, ASCHIINUM2  ; Load offset for numeric range end ('9') into R1 (x-39).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is nonzero, input is greater than '9'.
    BRNZ DIGITS        ; If result is zero (R2 == 0), input is a digit; branch to DIGITS.
    
    ;Purpose: if input <A/>Z branch ERROR if valid uppercase branch ALPHABET
    LD R1, ASCHIIUC1   ; Load offset for uppercase range start ('A') into R1 (x-41).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is negative, input is less than 'A'.
    BRN ERROR          ; If result is negative (R2 < 0), branch to ERROR.
    LD R1, ASCHIIUC2   ; Load offset for uppercase range end ('Z') into R1 (x-5A).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is nonzero, input is greater than 'Z'.
    BRNZ ALPHABET      ; If result is zero (R2 == 0), input is an uppercase letter; branch to ALPHABET.

    
    ;Purpose: checks if input<'a' or >'z' br ERROR otherwise br ALPHABET
    LD R1, ASCHIILC1   ; Load offset for lowercase range start ('a') into R1 (x-61).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is negative, input is less than 'a'.
    BRN ERROR          ; If result is negative (R2 < 0), branch to ERROR.
    LD R1, ASCHIILC2   ; Load offset for lowercase range end ('z') into R1 (x-7A).
    ADD R2, R1, R0     ; Add R0 (keyboard input) to R1. If result is nonzero, input is greater than 'z'.
    BRNZ ALPHABET      ; If result is zero (R2 == 0), input is a lowercase letter; branch to ALPHABET.




;Purpose: Based on the input type, selects the appropriate string to display.
DIGITS
    LEA R4, STRING2  ; Loads the address of "User has entered a decimal digit!" into R4.
    BR PUTSMYWAY     ; Branches to output the string.

ALPHABET
    LEA R4, STRING1  ; Loads the address of "User has entered a letter of the alphabet!" into R4.
    BR PUTSMYWAY     ; Branches to output the string.

ERROR
    LEA R4, STRING3  ; Loads the address of "ERROR: User input is invalid!" into R4.
    BR PUTSMYWAY     ; Branches to output the string.

EXIT
    LEA R4, STRING4  ; Loads the address of "User has Exit the Program" into R4.
    BR PUTSMYWAY2    ; Branches to output the string and halt the program.


;Purpose: Outputs the string stored at the memory location in R4, character by character.
PUTSMYWAY
    LDI R5, DSR      ; Loads display status register (DSR) to check readiness.
    BRZP PUTSMYWAY   ; Loops until the display is ready.
    LDR R5, R4, #0   ; Loads the character from the string pointed to by R4 into R5.
    BRZ end          ; Ends the string output if a null character is reached.
    STI R5, DDR      ; Outputs the character to the display data register (DDR).
    ADD R4, R4, #1   ; Moves to the next character in the string.
    BR PUTSMYWAY     ; Loops to output the next character.

;outputs string to display by checking if display is ready, loading char from string, and moving through each char till null is found
PUTSMYWAY2
    LDI R5, DSR           ; Load the value of the Display Status Register (DSR) into R5.
    BRZP PUTSMYWAY2       ; If the display is not ready (DSR = 0), branch back to `PUTSMYWAY2`.
    LDR R5, R4, #0        ; Load the character at the address pointed to by R4 into R5.
    BRZ end2              ; If the character is null (`0`), branch to `end2` to terminate the string output.
    STI R5, DDR           ; Store the character in R5 to the Display Data Register (DDR).
    ADD R4, R4, #1        ; Increment R4 to point to the next character in the string.
    BR PUTSMYWAY2         ; Loop back to check if the display is ready and process the next character.

    

ASCHIILCx   .FILL x-78
ASCHIIUCX   .FILL x-58
ASCHIINUM1  .FILL x-30
ASCHIINUM2  .FILL x-39
ASCHIIUC1   .FILL x-41
ASCHIIUC2   .FILL x-5A
ASCHIILC1   .FILL x-61
ASCHIILC2   .FILL x-7A

end2
    HALT
    
;Purpose: Restores the saved state of registers and returns control to the interrupted program.
end
    LD R0, SAVER0    ; Restores the saved value of R0.
    LD R1, SAVER1    ; Restores the saved value of R1.
    LD R2, SAVER2    ; Restores the saved value of R2.
    LD R3, SAVER3    ; Restores the saved value of R3.
    LD R7, SAVER7    ; Restores the saved value of R7.
    RTI              ; Returns from the interrupt.



ASCII_NUM .FILL x-30
ASCII_LC  .FILL x-61
ASCII_UC  .FILL x-41

KBSR2 .FILL xFE00
KBDR  .FILL xFE02
DSR   .FILL xFE04
DDR   .FILL xFE06

SAVER0 .BLKW x1
SAVER1 .BLKW x1
SAVER2 .BLKW x1
SAVER3 .BLKW x1
SAVER7 .BLKW x1

STRING1 .STRINGZ "\nUser has entered a letter of the alphabet!\n"
STRING2 .STRINGZ "\nUser has entered a decimal digit!\n"
STRING3 .STRINGZ "\nERROR: User input is invalid!\n"
STRING4 .STRINGZ "\n---------- User has Exit the Program ----------\n"




.END




; BLOCK 3
; USER PROGRAM
;Purpose: displays message waits for input and simulates looping behavior to demonstrate how program runs in user mode

.ORIG x3000

;Purpose: displays msg "enter character" and initializes r1 for future looping
UPPER_LOOP  LEA R0, MESSAGE    ; Load the address of the string "Enter a character…" into R0.
            PUTS               ; Display the string starting at the address in R0.
            LD  R1, COUNT      ; Load the value of COUNT (xFFFF) into R1.


;Purpose: implements countdown loop starting from r1 and terminates when r1 is neg           
LOOP_MAIN   ADD R1, R1, #-1    ; Decrement the counter R1.
            BRNP LOOP_MAIN     ; If R1 is positive or zero, branch back to LOOP_MAIN.


;Purpose: repettion of same countdown process to serve as placeholders for processor cycle
            LD R1, COUNT       ; Reload the counter value (xFFFF) into R1.
LOOP_MAIN2 ADD R1, R1, #-1     ; Decrement the counter R1.
            BRNP LOOP_MAIN2    ; If R1 is positive or zero, branch back to LOOP_MAIN2.

            LD R1, COUNT       ; Reload the counter value (xFFFF) into R1.
LOOP_MAIN3 ADD R1, R1, #-1     ; Decrement the counter R1.
            BRNP LOOP_MAIN3    ; If R1 is positive or zero, branch back to LOOP_MAIN3.

            LD R1, COUNT       ; Reload the counter value (xFFFF) into R1.
LOOP_MAIN4 ADD R1, R1, #-1     ; Decrement the counter R1.
            BRNP LOOP_MAIN4    ; If R1 is positive or zero, branch back to LOOP_MAIN4.

            BR  UPPER_LOOP     ; Branch unconditionally back to UPPER_LOOP.




COUNT .FILL xFFFF
MESSAGE .STRINGZ  "Enter a character…\n"
.END