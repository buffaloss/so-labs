; Program: Convert a 16 bit decimal number to binary

; The menu loop
menu:
    ; Clear screen and buffers
    call menu_clear_screen
    call menu_clear_buffers

    ; Print menu message
    mov dx, 0x0000
    mov bp, menu_message
    mov cx, menu_message_len
    call menu_print

    ; Print decimal prompt
    mov dx, 0x0100
    mov bp, menu_message_dec_prompt
    mov cx, menu_message_dec_prompt_len
    call menu_print

    ; Read decimal number
    call menu_read_b10

    ; Print binary prompt
    mov dx, 0x0200
    mov bp, menu_message_bin_prompt
    mov cx, menu_message_bin_prompt_len
    call menu_print

    ; Convert stored buffer to binary in ASCII equivalent
    call menu_convert_bin

    ; Print binary number
    mov dx, 0x0205
    mov bp, menu_ascii_bin_buffer
    mov cx, 0x10
    call menu_print

    ; Print continue message
    mov dx, 0x0400
    mov bp, menu_message_continue
    mov cx, menu_message_continue_len
    call menu_print

    ; Read key
    call menu_read_key

    ; If ESC, go to bootloader
    cmp al, 0x1B
    je menu_bootloader

    ; Else, go to menu
    jmp menu

; Jump to the bootloader
menu_bootloader:
    ; Call clear screen
    call menu_clear_screen
    jmp 0x0:0x7E00

; Clear screen function
menu_clear_screen:
    pusha
    ; Call clear screen
    mov ah, 07h
    mov al, 0x0
    mov bh, 0x7
    mov cx, 0x0
    mov dx, 0x184F
    int 10h

    ; Place the cursor at the top left
    mov ah, 02h
    mov bh, 0x0
    mov dx, 0x0
    int 10h
    popa
    
    ret

; Print function
menu_print:
    mov ax, 1301h
    mov bx, 0x0007
    ; Add the offset stored in 0x7C00 to the buffer pointer
    add bp, word [0x7C00]
    int 10h

    ret

; Read key function
menu_read_key:
    mov ah, 0x00
    int 16h

    ret

; Clear buffers function
menu_clear_buffers:
    mov si, menu_num_buffer
    add si, word [0x7C00]
    mov word [si], 0x0

    ; Clear the buffer that stores the ASCII equivalent of the binary number
    mov si, menu_ascii_bin_buffer
    add si, word [0x7C00]
    mov dword [si], 0x0
    add si, 0x4
    mov dword [si], 0x0
    add si, 0x4
    mov dword [si], 0x0
    add si, 0x4
    mov dword [si], 0x0

    ret

; Read a decimal number
menu_read_b10:
    call menu_read_key

    cmp al, 0x0D
    je menu_read_b10_return

    cmp al, 0x08
    je menu_read_b10_backspace

    cmp al, 0x30
    jl menu_read_b10
    cmp al, 0x39
    jg menu_read_b10

    sub al, 0x30
    mov cl, al
    mov si, menu_num_buffer
    add si, word [0x7C00]
    mov ax, word [si]

    cmp ax, 0x1999
    je menu_read_b10_limit

    cmp ax, 0x1999
    jb menu_read_b10_accept

    jmp menu_read_b10

    menu_read_b10_accept:
        mov dx, 0xA
        mul dx
        add ax, cx
        mov word [si], ax

        mov ah, 0Eh
        mov al, cl
        add al, 0x30
        int 10h

        jmp menu_read_b10

    menu_read_b10_return:
        ret

    menu_read_b10_backspace:
        mov dx, 0x0
        mov si, menu_num_buffer
        add si, word [0x7C00]
        mov ax, word [si]
        cmp ax, 0x0
        je menu_read_b10

        mov cx, 0xA
        div cx
        mov word [si], ax

        pusha
        mov ah, 03h
        mov bh, 0x0
        int 10h
        mov ah, 02h
        sub dl, 0x1
        int 10h
        mov ah, 0Ah
        mov al, 0x0
        int 10h
        popa

        jmp menu_read_b10

    menu_read_b10_limit:
        cmp cl, 0x5
        jg menu_read_b10

        jmp menu_read_b10_accept

; Convert the decimal number to binary
menu_convert_bin:
    ; Get the decimal number
    mov si, menu_num_buffer
    add si, word [0x7C00]
    mov ax, word [si]

    ; Place di at the start of the ascii bin buffer
    mov di, menu_ascii_bin_buffer
    add di, word [0x7C00]
    add di, 0xC

    ; Take in each digit and convert it to binary from the right
    mov dx, 0x0
    mov cx, 0x10
    div cx
    ; Divide by 16 to get the digit from the right as the remainder
    ; The remainder is stored in dx
    ; Call the function to convert the hex digit to binary
    call menu_hex_to_bin
    ; Move di the left by 4 bytes
    sub di, 0x4
    mov dx, 0x0
    div cx
    ; Divide by 16 to get the digit from the right as the remainder
    ; The remainder is stored in dx
    ; Call the function to convert the hex digit to binary
    call menu_hex_to_bin
    ; Move di the left by 4 bytes
    sub di, 0x4
    mov dx, 0x0
    div cx
    ; Divide by 16 to get the digit from the right as the remainder
    ; The remainder is stored in dx
    ; Call the function to convert the hex digit to binary
    call menu_hex_to_bin
    ; Move di the left by 4 bytes
    sub di, 0x4
    mov dx, 0x0
    div cx
    ; Divide by 16 to get the digit from the right as the remainder
    ; The remainder is stored in dx
    ; Call the function to convert the hex digit to binary
    call menu_hex_to_bin

    ret
    
menu_hex_to_bin:
    ; dl has the value
    ; Place ad di the 4 bit equivalent of the hex digit
    cmp dl, 0x0
    je menu_dl_00

    cmp dl, 0x1
    je menu_dl_01

    cmp dl, 0x2
    je menu_dl_02

    cmp dl, 0x3
    je menu_dl_03

    cmp dl, 0x4
    je menu_dl_04

    cmp dl, 0x5
    je menu_dl_05

    cmp dl, 0x6
    je menu_dl_06

    cmp dl, 0x7
    je menu_dl_07

    cmp dl, 0x8
    je menu_dl_08

    cmp dl, 0x9
    je menu_dl_09

    cmp dl, 0xA
    je menu_dl_0A

    cmp dl, 0xB
    je menu_dl_0B

    cmp dl, 0xC
    je menu_dl_0C

    cmp dl, 0xD
    je menu_dl_0D

    cmp dl, 0xE
    je menu_dl_0E

    cmp dl, 0xF
    je menu_dl_0F

    menu_dl_00:
        mov dword [di], "0000"
        ret

    menu_dl_01:
        mov dword [di], "0001"
        ret

    menu_dl_02:
        mov dword [di], "0010"
        ret

    menu_dl_03:
        mov dword [di], "0011"
        ret

    menu_dl_04:
        mov dword [di], "0100"
        ret

    menu_dl_05:
        mov dword [di], "0101"
        ret

    menu_dl_06:
        mov dword [di], "0110"
        ret

    menu_dl_07:
        mov dword [di], "0111"
        ret

    menu_dl_08:
        mov dword [di], "1000"
        ret

    menu_dl_09:
        mov dword [di], "1001"
        ret

    menu_dl_0A:
        mov dword [di], "1010"
        ret

    menu_dl_0B:
        mov dword [di], "1011"
        ret

    menu_dl_0C:
        mov dword [di], "1100"
        ret

    menu_dl_0D:
        mov dword [di], "1101"
        ret

    menu_dl_0E:
        mov dword [di], "1110"
        ret

    menu_dl_0F:
        mov dword [di], "1111"
        ret

section .data
    menu_message db "Decimal to Binary Converter"
    menu_message_len equ $ - menu_message

    menu_message_dec_prompt db "Dec: "
    menu_message_dec_prompt_len equ $ - menu_message_dec_prompt

    menu_message_bin_prompt db "Bin: "
    menu_message_bin_prompt_len equ $ - menu_message_bin_prompt

    menu_message_continue db "Press ESC to go to the menu or any key to continue..."
    menu_message_continue_len equ $ - menu_message_continue

    menu_num_buffer dw 0x0000

    menu_ascii_bin_buffer times 0x20 db 0x0
