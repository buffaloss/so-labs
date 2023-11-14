org 0x7c00                ; Set program's origin to 0x7c00
mov SI, userInput         ; Point SI register to userInput

inputLoop:                ; Begin input loop
    mov AH, 0             ; Prepare AH for keyboard input
    int 0x16              ; Interrupt 0x16 to get keyboard input
    cmp AH, 0x0e          ; Check if backspace (0x0e) was pressed
    je handleBackspace    ; If true, jump to handleBackspace
    cmp AH, 0x1c          ; Check if enter (0x1c) was pressed
    je handleEnter        ; If true, jump to handleEnter
    cmp SI, userInput + 256  ; Check if end of userInput is reached
    je inputLoop          ; If true, continue with inputLoop
    mov [SI], AL          ; Store pressed key into userInput at [SI]
    inc SI                ; Move to next userInput location
    mov AH, 0x0e          ; Prepare AH for display function
    int 0x10              ; Interrupt 0x10 to display the character

    jmp inputLoop         ; Go back to the start of the inputLoop

handleBackspace:          ; Start handling backspace key press
    cmp SI, userInput     ; Check if start of userInput is reached
    je inputLoop          ; If true, continue with inputLoop
    dec SI                ; Move back in the userInput
    mov byte [SI], 0      ; Clear the character in the userInput at [SI]
    mov AH, 0x03          ; Prepare AH for cursor info
    mov BH, 0             ; Set BH for page 0
    int 0x10              ; Interrupt 0x10 to get cursor info

    cmp DL, 0             ; Check if cursor column is 0
    jz moveToPreviousLine ; If true, jump to moveToPreviousLine
    jmp eraseCharacter    ; Otherwise, jump to eraseCharacter

eraseCharacter:           ; Start erasing a character
    mov AH, 0x02          ; Prepare AH for writing character function
    dec DL                ; Move cursor column back
    int 0x10              ; Interrupt 0x10 to write a space
    mov AH, 0x0a          ; Prepare AH for write attribute function
    mov AL, 0x20          ; Set AL for space character
    mov CX, 1             ; Set CX for number of spaces to write
    int 0x10              ; Interrupt 0x10 to write the space character

    jmp inputLoop         ; Go back to the start of the inputLoop

moveToPreviousLine:       ; Start moving to the previous line
    mov AH, 0x02          ; Prepare AH for setting cursor position
    mov DL, 79            ; Set DL to last column
    dec DH                ; Move cursor row back
    int 0x10              ; Interrupt 0x10 to set the cursor position

handleEnter:              ; Start handling enter key press
    mov AH, 0x03          ; Prepare AH for cursor info
    mov BH, 0             ; Set BH for page 0
    int 0x10              ; Interrupt 0x10 to get cursor info
    sub SI, userInput     ; Calculate characters in userInput
    jz moveToNextLine     ; If SI is 0, jump to moveToNextLine
    cmp DH, 24            ; Check if cursor row is 24
    jl printUserInput     ; If less than 24, jump to printUserInput

    mov AH, 0x06          ; Prepare AH for scroll function
    mov AL, 1             ; Set AL to scroll up by 1 row
    mov BH, 0x07          ; Set BH for new lines' attribute
    mov CX, 0             ; Set CX for start column
    mov DX, 0x184f        ; Set DX for end column and row
    int 0x10              ; Interrupt 0x10 to scroll the screen
    mov DH, 0x17          ; Set DH to end row

printUserInput:           ; Start printing the userInput
    mov BH, 0             ; Set BH for page 0
    mov AX, 0             ; Clear AX register
    mov ES, AX            ; Set ES register to 0 for video memory
    mov BP, userInput     ; Point BP to userInput
    mov BL, 0x07          ; Set BL for text attribute
    mov CX, SI            ; Set CX to characters in userInput
    inc DH                ; Move cursor row down
    mov DL, 0             ; Set DL to start column

    mov AX, 0x1301        ; Set AH for write string and AL for write with attribute
    int 0x10              ; Interrupt 0x10 to write the string with attribute

moveToNextLine:           ; Start moving the cursor down
    mov AH, 0x03          ; Prepare AH for cursor info
    mov BH, 0             ; Set BH for page 0
    int 0x10              ; Interrupt 0x10 to get cursor info
    mov AH, 0x02          ; Prepare AH for setting cursor position
    mov BH, 0             ; Set BH for page 0
    inc DH                ; Move cursor row down
    mov DL, 0             ; Set DL to start column
    int 0x10              ; Interrupt 0x10 to set the cursor position

    add SI, userInput     ; Move SI to start of userInput

clearUserInput:           ; Start clearing the userInput
    mov byte [SI], 0      ; Clear the character at current userInput location
    inc SI                ; Move SI to next userInput location
    cmp SI, 0             ; Compare SI with 0 (end of userInput)
    jne clearUserInput    ; If SI is not at the end, continue clearing

    mov SI, userInput     ; Reset SI to point to start of userInput
    jmp inputLoop         ; Go back to the start of the inputLoop

userInput: times 256 db 0 ; Define a 256-byte userInput for input