; Write character as TTY

go:
    mov AH, 0Eh ; teletype output
    mov AL, 'A' ; character to print
    int 10h ; call BIOS

;;; nasm -f bin -o <file>.img <file>.asm
;;; command to truncate: 
;;; truncate <file> --size 1474560