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
extrn timeout
extrn usleep
extrn printw
extrn mvaddch
extrn erase
extrn curs_set

section '.bss' writable
    x_max dq 1
	  y_max dq 1
	  colors dq 1
    delay dq ?
    buffer db ?
    f db "/dev/random", 0
    rand_num dq ?

section '.text' executable
_start:

    call initscr
    xor rdi, rdi
	  mov rdi, [stdscr]
	  call getmaxx
    dec rax
	  mov [x_max], rax
	  call getmaxy
    dec rax
	  mov [y_max], rax

    mov rdi, 0
    call curs_set

    call start_color

    mov rdi, 1
    mov rsi, 4
    mov rdx, 4
    call init_pair

    mov rdi, 2
    mov rsi, 5
    mov rdx, 5
    call init_pair

    call refresh
	  call noecho
    call raw

    xor rax, rax
    mov rax, ' '
    or rax, 0x100
    mov [colors], rax

    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov [rand_num], rax

    xor r9, r9
    xor r10, r10

    .loop:
        mov rdi, r10
        mov rsi, r9
        push r9
        push r10
        mov rdx, [colors]
        call mvaddch
        call refresh

        mov rdi, 1
        call timeout
        call getch
        cmp rax, 'q'  ; ЗАВЕРШЕНИЕ ПРОГРАММЫ!!!
        je .end

        mov rax, 0
        mov rdi, [rand_num]
        mov rsi, buffer
        mov rdx, 1
        syscall

        pop r10
        pop r9
        xor rax, rax
        xor rbx, rbx
        xor rdx, rdx
        mov al, [buffer]
        mov rbx, 3
        div rbx
        sub rdx, 1
        add r9, rdx
        xor rdx, rdx
        div rbx
        sub rdx, 1
        add r10, rdx

        xor rcx, rcx
        cmp r9, 0
        jnl @f
        inc r9
        inc rcx

        @@:
        cmp r9, [x_max]
        jle @f
        dec r9
        inc rcx

        @@:
        cmp r10, 0
        jnl @f
        inc r10
        inc rcx

        @@:
        cmp r10, [y_max]
        jle @f
        dec r10
        inc rcx

        @@:
        cmp rcx, 0
        je .sleep
        mov rax, [colors]
        and rax, 0x100
        cmp rax, 0
        jne .mag
        mov rax, [colors]
        and rax, 0xff
        or rax, 0x100
        jmp @f
        .mag:
        mov rax, [colors]
        and rax, 0xff
        or rax, 0x200
        @@:
        mov [colors], rax

        .sleep:
        push r10
        push r9
        mov rdi, 100000
        call usleep
        call erase
        pop r9
        pop r10

        jmp .loop

    .end:
    mov rdi, 1
    call curs_set
    call endwin
    mov rax, 60
    syscall
