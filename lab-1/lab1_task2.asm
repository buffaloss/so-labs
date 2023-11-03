; Write character
go: 
    mov AH, 0aH     ; write character
    mov AL, 0x42    ; 'B'
    int 10h         ; call BIOS
