format ELF64

include 'func.asm'

public _start

THREAD_FLAGS=2147585792
ARRLEN=10

section '.bss' writable
    array rb ARRLEN
    digits rq 10
    buffer rb 10
    f db "/dev/random", 0
    stack1 rq 4096
    msg1 db "0.75 квантиль:", 0xA, 0
    msg2 db "Медиана:", 0xA, 0
    msg3 db "Количество чисел, сумма цифр  которых кратна 3:", 0xA, 0
    msg4 db "Среднее арифметическое значение", 0xA, 0
    space db " ", 0

section '.text' executable
_start:
    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov r8, rax

    mov rax, 0
    mov rdi, r8
    mov rsi, array
    mov rdx, ARRLEN
    syscall

    .filter_loop:
        call filter
        cmp rax, 0
        jne .filter_loop

    mov rcx, ARRLEN
    .print:
        dec rcx
        xor rax, rax
        mov al, [array+rcx]
        mov rsi, buffer
        call number_str
        call print_str
        mov rsi, space
        call print_str
        inc rcx
    loop .print

    call new_line

    mov rax, 56                 ; first child
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .quantile

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call input_keyboard

    mov rax, 56                 ; second child
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .median

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call input_keyboard

    mov rax, 56                 ; third child
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .div3

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call input_keyboard

    mov rax, 56                 ; fourth child
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall

    cmp rax, 0
    je .average

    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call exit
    call exit


    .quantile:
        mov rsi, msg1
        call print_str

        mov rax, ARRLEN
        mov rbx, 4
        xor rdx, rdx
        div rbx
        mov rbx, ARRLEN-1
        sub rbx, rax
        xor rax, rax
        mov al, [array+rbx]
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit
        call exit

    .median:
        mov rsi, msg2
        call print_str

        mov rax, ARRLEN
        mov rbx, 2
        div rbx
        mov bl, [array+rax]
        mov rax, rbx
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit
        call exit

    .div3:
        mov rsi, msg3
        call print_str

        xor r8, r8
        xor rax, rax
        xor r9, r9

        .ar_iter:
            xor rbx, rbx
            xor rax, rax
            xor rdx, rdx
            mov al, [array + r9]
            mov rbx, 3
            div rbx

            inc r9

            cmp rdx, 0
            jne .ar_iter

            inc r8
            cmp r9, ARRLEN
            jl .ar_iter

        xor rax, rax
        mov rax, r8
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit
        call exit

    .average:
        mov rsi, msg4
        call print_str

        xor rcx, rcx
        mov rbx, ARRLEN-1
        .loop:
            mov al, [array+rbx]

            add rcx, rax

            dec rbx
            cmp rbx, 0
        jne .loop

        mov rax, rcx
        mov rcx, ARRLEN
        xor rdx, rdx
        div rcx
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit
        call exit


;output rax = 0 if filtered
filter:
    xor rax, rax ; swap counter
    mov rsi, array ; iter
    mov rcx, ARRLEN
    dec rcx
    .check:
        mov dl, [rsi]
        mov dh, [rsi+1]
        cmp dl, dh
        jbe .ok

        mov [rsi], dh
        mov [rsi+1], dl
        inc rax

        .ok:
        inc rsi
    loop .check
    ret