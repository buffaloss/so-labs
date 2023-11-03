; Write character/attribute

go:
    mov AH, 09h ; Write character/attribute at cursor position
	mov AL, 'J' ; Character to write 'J'
	mov bl, 0x4F ; Attribute to write 'J' in white on red background
 	int 10h ; Call BIOS video interrupt