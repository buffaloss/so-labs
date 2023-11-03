; Display string and update cursor

org 7c00H   ; Set the origin address to 0x7C00, a common starting point for bootloaders

go:
    mov sp, 0x7C00 ; Srt stack pointer to 0x7C00
    mov AX, 1301H ; Load 0x1301 into AX
    mov BH, 0     ; Clear BH (often used for the video page)
    mov BL, 02H   ; Set BL to 0x02, which specifies a green color attribute
    mov CX, 3     ; Set CX to 3, indicating that three characters will be written
    mov DH, 0     ; Set cursor row
    mov DL, 0     ; Set cursor column
    mov BP, chr   ; Load the address of the 'chr' variable (string) into BP
    int 10h       ; Invoke interrupt 10h (INT 10h), which calls the BIOS video service
                  ; to perform the specified video mode setup and write the string to the screen.

jmp $          ; This creates an infinite loop, causing the program to hang indefinitely.

section .text 
    chr db 'LOL' ; Define a data section containing string 'LOL'
