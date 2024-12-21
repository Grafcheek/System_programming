format ELF64

include 'func.asm'

public _start

section '.bss' writable
    msg1 db "Введите команду", 0
    filename1 db "input", 0
    filename2 db "result", 0
    argv rq 5
    input rb 100

section '.text' executable
_start:
    .loop:
        mov rsi, msg1
        call print_str
        call new_line

        mov rsi, input
        call input_keyboard

        cmp byte[input], 'q'
        je .break

        mov rax, 57
        syscall
        cmp rax, 0
        jne .wait

        mov rax, 59
        mov rdi, input
        mov [argv], input
        mov [argv+8], filename1
        mov [argv+16], filename2
        mov [argv+24], 0
        mov rsi, argv
        syscall
        call exit

        .wait:
        mov rax, 61
        mov rdi, -1
        mov rdx, 0
        mov r10, 0
        syscall
        jmp .loop

    .break:
    call exit
