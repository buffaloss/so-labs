; Display character + attribute
org 0x7C00 ; BIOS loads boot sector into 0x7C00
            ; the address where BIOS starts the execution
            
go:
    mov sp, 0x7C00  ; Set stack pointer to 0x7C00
    mov AX, 1302h   ; BIOS display character with attribute cells

    mov DH, 0       ; Set row cursor to 0
    mov DL, 0       ; Set column cursor to 0
    mov BP, var     ; Load msg into bp
    mov CX, 6       ; Set loop counter to 6
    int 10h         ; Call BIOS video interrupt

jmp $          ; This creates an infinite loop, causing the program to hang indefinitely.

section .text
    ; var db 'Japan' with individual character attributes
	var db 'J', 0xE1, 'a', 0x42, 'p', 0xD3, 'a', 0x70, 'n', 0x1F

;;; nasm -f bin -o <file>.img <file>.asm
;;; command to truncate: 
;;; truncate <file> --size 1474560