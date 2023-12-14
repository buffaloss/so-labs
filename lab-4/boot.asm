; The 1st stage bootloader

[bits 16]
org 0x7C00

; Buffer to store the offset of the program after the 2nd stage bootloader
program_offset dw 0x0

; Set stack pointer
mov sp, 0x7C00

boot:
; Set data segment for 2nd stage bootloader
mov bx, 0x0
mov es, bx
mov bx, 0x7E00

; Start of the 2nd stage bootloader in the floppy disk
mov cl, 0x2
mov dh, 0x0
mov ch, 0x0

; The read loop for each sector
boot_read_loop:
    ; Call floppy read
    mov ah, 0x2
    mov al, 0x1
    int 0x13

    ; Check if the all sectors have been read
    mov al, [boot_sectors_to_read]
    mov ah, [boot_sectors_read]
    cmp al, ah
    ; If yes jump to boot_finish_read
    je boot_finish_read

    ; If no, addvance to the next sector in the floppy drive
    ; Limit the sector to 1-18
    cmp cl, 0x12
    jl boot_read_continue
    mov cl, 0x0
    add dh, 0x1

    ; Limit the head to 0-1
    cmp dh, 0x2
    jl boot_read_continue
    mov dh, 0x0
    add ch, 0x1

    ; Prepare the next sector to be read
    boot_read_continue:
        ; Advance the sector pointer
        add cl, 0x1

        ; Increment the number of sectors read
        mov ax, 0x0
        mov ah, [boot_sectors_read]
        add ah, 0x1
        mov [boot_sectors_read], ah

        ; Advance the location to store the next sector by 512 bytes
        add bx, 0x200

    ; Loop to boot_read_loop
    jmp boot_read_loop

; Finish reading the 2nd stage bootloader
boot_finish_read:
    mov bx, 0x0
    mov es, bx 
    mov bx, 0x7E00

    ; Jump to the 2nd stage bootloader
    jmp main

; The number of sectors to read
boot_sectors_to_read db 0x8

; The number of sectors read
boot_sectors_read db 0x0

times 510-($-$$) db 0
dw 0xaa55

; The 2nd stage bootloader
%include "main.asm"
