asm
format ELF64

public _start

volume = 1000

extrn initscr
extrn getmaxx
extrn getmaxy
extrn start_color
extrn init_pair
extrn refresh
extrn noecho
extrn raw
extrn usleep
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn endwin
extrn exit
extrn timeout
extrn printw
extrn open
extrn read
extrn close
extrn fstat
extrn mmap
extrn munmap

section '.bss' writable
    xmax dq 1
    ymax dq 1
    xmid dq 1
    ymid dq 1
    palette dq 1
    delay dq ?
    count dq 1
    color_index rw 1
    file_descriptor rq 1
    file_size rq 1
    file_buffer rq 1

section '.data' writable
    filename db 'text', 0
    colors dw 1, 2, 3, 4, 5
    color_pairs dw 0, 0, 0, 0, 0

section '.text' executable

_start:
    mov rdi, filename
    mov rsi, 0
    mov rax, 2
    syscall
    cmp rax, 0
    jl error_exit
    mov [file_descriptor], rax

    mov rax, 196
    mov rdi, [file_descriptor]
    syscall
    mov rbx, rax
    mov [file_size], rbx

    mov rdi, 0
    mov rsi, [file_size]
    mov rdx, 1
    mov r10, 2
    mov r8, [file_descriptor]
    mov r9, 0
    mov rax, 9
    syscall
    cmp rax, -1
    je error_exit
    mov [file_buffer], rax

    call initscr
    call start_color

    mov rdi, 1
    mov rsi, 1
    mov rdx, 0
    call init_pair

    mov rdi, 2
    mov rsi, 2
    mov rdx, 0
    call init_pair

    mov rdi, 3
    mov rsi, 3
    mov rdx, 0
    call init_pair

    mov rdi, 4
    mov rsi, 4
    mov rdx, 0
    call init_pair

    mov rdi, 5
    mov rsi, 5
    mov rdx, 0
    call init_pair

    call getmaxx
    dec rax
    mov [xmax], rax

    call getmaxy
    dec rax
    mov [ymax], rax

    xor rbx, rbx
    xor r12, r12

    xor r13, r13

.output_loop:
    cmp rcx, [file_size]
    jge end_output

    mov al, byte [file_buffer + rcx]
    mov ax, [colors + r13*2]
    mov rdi, ax
    call attron

    mov rdi, al
    call addch

    inc r13
    cmp r13, 5
    jl @next_color
    xor r13, r13
@next_color:

    inc rbx
    cmp rbx, [xmax]
    jle @f
    mov rbx, 0
    inc r12
    cmp r12, [ymax]
    jg end_output
@@:

    mov rdi, r12
    mov rsi, rbx
    call move

    call refresh

    inc rcx
    jmp .output_loop

end_output:
    mov rdi, 0
    call getch

error_exit:
    cmp qword [file_buffer], 0
    je close_file
    mov rdi, [file_buffer]
    mov rsi, [file_size]
    mov rax, 11
    syscall

close_file:
    cmp qword [file_descriptor], -1
    je end_program
    mov rdi, [file_descriptor]
    mov rax, 3
    syscall

end_program:
    call endwin
    call exit
