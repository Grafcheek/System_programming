format ELF64

public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep
extrn printw

section '.bss' writable
    screen_width dq 1
    screen_height dq 1
    palette dq 1
    delay dq ?

section '.text' executable

_start:
    call initscr
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [screen_width], rax
    call getmaxy
    dec rax
    mov [screen_height], rax

    call start_color
    ; COLOR_CYAN
    mov rdi, 1
    mov rsi, 6  ; COLOR_CYAN
    mov rdx, 6  ; COLOR_CYAN
    call init_pair

    ; COLOR_YELLOW
    mov rdi, 2
    mov rsi, 3  ; COLOR_YELLOW
    mov rdx, 3  ; COLOR_YELLOW
    call init_pair

    call refresh
    call noecho
    call raw

    mov rax, ' '
    or rax, 0x200
    mov [palette], rax

    .begin:
    mov rax, [palette]
    and rax, 0x100
    cmp rax, 0
    jne .set_yellow

    mov rax, [palette]
    and rax, 0xff
    or rax, 0x100
    jmp .update_palette

    .set_yellow:
    mov rax, [palette]
    and rax, 0xff
    or rax, 0x200

    .update_palette:
    mov [palette], rax

    mov r8, [screen_width]
    xor r9, r9
    jmp .loop_left_start

    .to_left:
    inc r9
    cmp r9, [screen_height]
    jg .begin
    mov r8, [screen_width]

    .loop_left_start:
        mov rdi, [delay]
        call usleep
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh

        mov rdi, 1
        call timeout
        call getch
        cmp rax, 'l'
        jne .check_q_key_left
        jmp .exit

    .check_q_key_left:
        cmp rax, 'q'
        jne .resume_left_loop
        cmp [delay], 4000
        je .set_fast_left
        mov [delay], 4000
        jmp .resume_left_loop

    .set_fast_left:
        mov [delay], 100

    .resume_left_loop:
        pop r9
        pop r8
        dec r8
        cmp r8, 0
        jl .to_right
        jmp .loop_left_start

    .to_right:
    inc r9
    cmp r9, [screen_height]
    jg .begin
    mov r8, 0

    .loop_right_start:
        mov rdi, [delay]
        call usleep
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh

        mov rdi, 1
        call timeout
        call getch
        cmp rax, 'l'
        jne .check_q_key_right
        jmp .exit

    .check_q_key_right:
        cmp rax, 'q'
        jne .resume_right_loop
        cmp [delay], 4000
        je .set_fast_right
        mov [delay], 4000
        jmp .resume_right_loop

    .set_fast_right:
        mov [delay], 100

    .resume_right_loop:
        pop r9
        pop r8
        inc r8
        cmp r8, [screen_width]
        jg .to_left
        jmp .loop_right_start

    .exit:
    call endwin
    call exit
