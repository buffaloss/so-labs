; The 2nd stage bootloader

; Main loop in the 2nd stage bootloader
main:
    ; Print welcome message at row 0, column 0
    mov dx, 0x0000
    mov bp, main_welcome
    mov cx, main_welcome_len
    call main_print

    ; Print author message at row 1, column 0
    mov dx, 0x0100
    mov bp, main_author
    mov cx, main_author_len
    call main_print

    ; Read side from which to read
    main_read_side:
        ; Clear the buffers
        call main_clear_num_buffer
    
        ; Print side prompt
        mov dx, 0x0200
        mov bp, main_side_prompt
        mov cx, main_side_prompt_len
        call main_print

        ; Call the b10 reader function
        call main_read_b10

        ; Limit the side to be less than 2
        mov ax, word [main_num_buffer]
        
        ; If less than to jump to main_accept_side
        cmp ax, 0x2
        jl main_accept_side

        ; If 2 or more, clear the row and re-read the side input
        call main_clear_row
        jmp main_read_side

    ; Accept the side
    main_accept_side:
        ; Place the side in the side variable
        mov word [main_side], ax

    ; Read the track from which to read
    main_read_track:
        ; Clear the buffers
        call main_clear_num_buffer

        ; Print the track prompt
        mov dx, 0x0300
        mov bp, main_track_prompt
        mov cx, main_track_prompt_len
        call main_print

        ; Call the b10 reader function
        call main_read_b10

        ; Limit the track to be between 1 and 18
        mov ax, word [main_num_buffer]
        cmp ax, 0x1
        jl main_track_fault

        ; If greater than 18, clear the row and re-read the track input
        cmp ax, 0x12
        jg main_track_fault

        ; If between 1 and 18, accept the track
        mov word [main_track], ax
        jmp main_read_sector

        ; If not between 1 and 18, clear the row and re-read the track input
        main_track_fault:
            call main_clear_row
            jmp main_read_track

    ; Read the sector from which to read
    main_read_sector:
        ; Clear the buffers
        call main_clear_num_buffer

        ; Print the sector prompt
        mov dx, 0x0400
        mov bp, main_sector_prompt
        mov cx, main_sector_prompt_len
        call main_print

        ; Call the b10 reader function
        call main_read_b10

        ; Limit the sector to be between 0 and 79
        mov ax, word [main_num_buffer]
        cmp ax, 0x50
        jl main_accept_sector

        ; If greater than 79, clear the row and re-read the sector input
        call main_clear_row
        jmp main_read_sector

        ; If between 0 and 79 store the sector in the sector variable
        main_accept_sector:
            mov word [main_sector], ax
    
    ; Read the sector count
    main_read_sector_ct:
        ; Clear the buffers
        call main_clear_num_buffer

        ; Print the sector count prompt
        mov dx, 0x0500
        mov bp, main_sector_ct_prompt
        mov cx, main_sector_ct_prompt_len
        call main_print

        ; Call the b10 reader function
        call main_read_b10

        ; Limit the sector count to less than 31
        mov ax, word [main_num_buffer]
        cmp ax, 0x1F
        ; If less than 31, accept the sector count
        jl main_accept_sector_ct

        ; If greater than 31, clear the row and re-read the sector count input
        call main_clear_row
        jmp main_read_sector_ct

        ; If between 0 and 31, store the sector count in the sector count variable
        main_accept_sector_ct:
            mov word [main_sector_ct], ax

    ; Read the address to which to load the sector
    main_read_address:
        ; Clear the buffers
        call main_clear_num_buffer

        ; Print the address prompt
        mov dx, 0x0600
        mov bp, main_address_prompt
        mov cx, main_address_prompt_len
        call main_print

        ; Read the first part of the address with the b16 reader function
        call main_read_b16

        ; Store the first part of the address in the address 1 variable
        mov ax, word [main_num_buffer]
        mov word [main_address_1], ax

        ; Print a colon
        mov ah, 0Eh
        mov al, ':'
        int 10h

        ; Clear the buffers
        call main_clear_num_buffer
        
        ; Read the second part of the address with the b16 reader function
        call main_read_b16

        ; Store the second part of the address in the address 2 variable
        mov ax, word [main_num_buffer]
        mov word [main_address_2], ax

    ; Place the address in the es:bx register
    push es
    push bx
    mov bx, word [main_address_1]
    mov es, bx
    mov bx, word [main_address_2]

    ; Place the floppy parameters in the registers
    mov cl, byte [main_track]
    mov dh, byte [main_side]
    mov ch, byte [main_sector]

    ; Read sector loop
    main_read_loop:
        ; Call floppy read function
        mov ah, 02h
        mov al, 0x1
        mov dl, 0x0
        int 13h

        ; Check if all sectors have been read
        mov al, byte [main_sector_ct]
        cmp al, 0x0
        ; If all sectors have been read, jump to main_read_loop_end
        je main_read_loop_end

        ; If not all sectors have been read, continue reading
        sub al, 0x1
        mov byte [main_sector_ct], al

        ; Limit the sector to be less than between 1 and 18
        cmp cl, 0x12
        jl main_read_loop_continue
        mov cl, 0x0
        add dh, 0x1

        ; Limit the side to be less than 2
        cmp dh, 0x2
        jl main_read_loop_continue
        mov dh, 0x0
        add ch, 0x1

    ; Prepare for the next sector
    main_read_loop_continue:
        add cl, 0x1
        add bx, 0x200
        jmp main_read_loop

    ; End of the read loop
    main_read_loop_end:
        pop bx
        pop es

    ; If the floppy read function failed, print the error code
    jc main_floppy_error

    ; Print the floppy code 0
    mov bp, main_floppy_code
    mov cx, main_floppy_code_len
    mov dx, 0x0700
    call main_print

    mov ax, 0x0E30
    mov bl, 0x7
    int 10h
    int 10h

    ; Print the 1st address loaded message
    mov bp, main_address_loaded_1
    mov cx, main_address_loaded_1_len
    mov dx, 0x0800
    call main_print

    ; Print the 2nd address loaded message
    mov bp, main_address_loaded_2
    mov cx, main_address_loaded_2_len
    mov dx, 0x0900
    call main_print

    ; Place the address in the es:bx register
    mov bx, [main_address_1]
    mov es, bx
    mov bx, [main_address_2]

    ; Wait for a keypress
    mov ah, 00h
    int 16h

    ; Clear the screen
    call main_clear_screen

    ; Place the offset of the program in the program_offset variable from 0x7C00
    mov word [program_offset], bx

    ; Jump to the program
    jmp bx

    ; Error handler
    main_floppy_error:
        mov dx, 0x0
        mov al, 0x0
        mov cx, 0x10
        div cx

        mov ah, al
        mov ah, 0Eh
        mov bl, 0x7
        cmp al, 0xA
        jl main_floppy_error_num1

        add al, 0x7

        main_floppy_error_num1:
            add al, 0x30

        int 10h

        mov ah, 0Eh
        mov bl, 0x7
        mov al, dh
        cmp al, 0xA
        jl main_floppy_error_num2

        add al, 0x7

        main_floppy_error_num2:
            add al, 0x30

        int 10h

        clc

        mov ah, 00h
        int 16h

        jmp main

; The print function
main_print:
    ; Call print string function
    mov ax, 1301h
    mov bx, 0x0007
    int 10h

    ret

; The clear row function
main_clear_row:
    ; Read the current cursor position
    mov ah, 03h
    int 10h

    ; Clear the row at the current cursor position
    mov bp, clean_row
    mov cx, 0x50
    mov dl, 0x0
    mov ax, 1301h
    mov bx, 0x0007
    int 10h

    ret

; The clear num buffer function
main_clear_num_buffer:
    mov ax, 0x0
    mov word [main_num_buffer], ax

    ret

; The b10 reader function
main_read_b10:
    mov ah, 00h
    int 16h

    cmp al, 0x0D
    je main_read_b10_return

    cmp al, 0x08
    je main_read_b10_backspace

    cmp al, 0x30
    jl main_read_b10
    cmp al, 0x39
    jg main_read_b10

    sub al, 0x30
    mov cl, al
    mov ax, word [main_num_buffer]

    cmp ax, 0xCCC
    je main_read_b10_limit
    
    cmp ax, 0xCCC
    jl main_read_b10_accept

    jmp main_read_b10

    main_read_b10_accept:
        mov dx, 0xA
        mul dx
        add ax, cx
        mov word [main_num_buffer], ax

        mov ah, 0Eh
        mov al, cl
        add al, 0x30
        int 10h

        jmp main_read_b10

    main_read_b10_return:
        ret
    
    main_read_b10_backspace:
        mov dx, 0x0
        mov ax, word [main_num_buffer]
        cmp ax, 0x0
        je main_read_b10

        mov cx, 0xA
        div cx
        mov word [main_num_buffer], ax

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

        jmp main_read_b10

    main_read_b10_limit:
        cmp cl, 0x7
        jg main_read_b10

        jmp main_read_b10_accept

; The b16 reader function
main_read_b16:
    mov ah, 00h
    int 16h
    
    cmp al, 0x1B
    je main_read_b16_return

    cmp al, 0x0D
    je main_read_b16_return

    cmp al, 0x08
    je main_read_b16_backspace

    cmp al, 0x30
    jl main_read_b16

    cmp al, 0x3A
    jl main_read_b16_handle_number

    cmp al, 0x41
    jl main_read_b16

    cmp al, 0x47
    jl main_read_b16_handle_uppercase

    cmp al, 0x61
    jl main_read_b16

    cmp al, 0x67
    jl main_read_b16_handle_lowercase

    jmp main_read_b16

    main_read_b16_handle_number:
        sub al, 0x30
        jmp main_read_b16_handle_value

    main_read_b16_handle_uppercase:
        sub al, 0x37
        jmp main_read_b16_handle_value

    main_read_b16_handle_lowercase:
        sub al, 0x57
        jmp main_read_b16_handle_value

    main_read_b16_handle_value:
        mov cl, al
        mov ax, [main_num_buffer]

        cmp ax, 0xFFF
        ja main_read_b16

        mov dx, 0x10
        mul dx

        add ax, cx
        mov [main_num_buffer], ax

        mov ah, 0Eh
        mov al, cl
        cmp cx, 0x9
        jg main_read_b16_print_letter
            add al, 0x30
            int 10h
            jmp main_read_b16

        main_read_b16_print_letter:
            add al, 0x37
            int 10h
            jmp main_read_b16

    main_read_b16_return:
        ret
    
    main_read_b16_backspace:
        mov dx, 0x0
        mov ax, [main_num_buffer]
        cmp ax, 0x0
        je main_read_b16

        mov cx, 0x10
        div cx
        mov [main_num_buffer], ax
        
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

        jmp main_read_b16

; The clear screen function
main_clear_screen:
    pusha
    ; Call the clear screen function
    mov ah, 07h
    mov al, 0x0
    mov bh, 0x7
    mov cx, 0x0
    mov dx, 0x184F
    int 10h

    ; Place the cursor at the top left corner
    mov ah, 02h
    mov bh, 0x0
    mov dx, 0x0
    int 10h
    popa
    
    ret

section .data
    main_welcome db "Welcome to BeeOS."
    main_welcome_len equ $ - main_welcome

    main_author db "Made by Beatricia Golban."
    main_author_len equ $ - main_author

    main_sector_ct_prompt db "SEC CT: "
    main_sector_ct_prompt_len equ $ - main_sector_ct_prompt

    main_side_prompt db "SIDE:   "
    main_side_prompt_len equ $ - main_side_prompt

    main_track_prompt db "TRACK:  "
    main_track_prompt_len equ $ - main_track_prompt

    main_sector_prompt db "SECTOR: "
    main_sector_prompt_len equ $ - main_sector_prompt

    main_address_prompt db "ADDRESS: "
    main_address_prompt_len equ $ - main_address_prompt

    main_floppy_code db "Floppy code: "
    main_floppy_code_len equ $ - main_floppy_code

    main_address_loaded_1 db "Sectors loaded."
    main_address_loaded_1_len equ $ - main_address_loaded_1

    main_address_loaded_2 db "Press any key to continue..."
    main_address_loaded_2_len equ $ - main_address_loaded_2

    main_num_buffer dw 0x0

    main_side dw 0x0
    main_track dw 0x0
    main_sector dw 0x0
    main_sector_ct dw 0x0

    main_address_1 dw 0x0
    main_address_2 dw 0x0

    clean_row times 0x50 db 0x0
