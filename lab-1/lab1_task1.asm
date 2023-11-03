; Write character as TTY

go:
    mov AH, 0Eh ; teletype output
    mov AL, 'A' ; character to print
    int 10h ; call BIOS

;;; nasm -f bin -o echo.com echo.asm
;;; command to truncate: 