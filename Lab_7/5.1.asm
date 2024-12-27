format ELF64

public _start

include 'func.asm'

section '.bss' writable
    buffer rb 1024
    letters_count rq 1
    digits_count rq 1
    output_buffer rb 256

section '.data'
    result_letters db 'number of letters: ', 0
    result_digits db 'number of digits: ', 0
    newline db 0xA, 0

section '.text' executable
_start:
    pop rcx
    cmp rcx, 1
    je exit

    mov rdi, [rsp+8]
    mov rax, 2
    mov rsi, 0
    syscall
    cmp rax, 0
    jl exit
    mov r8, rax

    mov rdi, [rsp+16]
    mov rax, 2
    mov rsi, 577
    mov rdx, 438
    syscall
    cmp rax, 0
    jl exit
    mov r9, rax

    xor rax, rax
    mov [letters_count], rax
    mov [digits_count], rax

.read_loop:
    mov rax, 0
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 1024
    syscall
    cmp rax, 0
    je .write_result
    cmp rax, 0
    js exit

    mov rcx, rax
    xor rbx, rbx
.process_buffer:
    cmp rbx, rcx
    jge .read_loop
    mov al, [buffer + rbx]

    cmp al, 'A'
    jb .check_digit
    cmp al, 'Z'
    jbe .count_letter
    cmp al, 'a'
    jb .check_digit
    cmp al, 'z'
    jbe .count_letter

.check_digit:
    cmp al, '0'
    jb .next_char
    cmp al, '9'
    jbe .count_digit
    jmp .next_char

.count_letter:
    inc qword [letters_count]
    jmp .next_char

.count_digit:
    inc qword [digits_count]
    jmp .next_char

.next_char:
    inc rbx
    jmp .process_buffer

.write_result:
    lea rsi, [result_letters]
    mov rdi, r9
    call write_str_to_file
    
    mov rax, [letters_count]
    lea rsi, [output_buffer]
    call number_str
    mov rdi, r9
    call write_str_to_file
    mov rsi, newline
    mov rdi, r9
    call write_str_to_file

    lea rsi, [result_digits]
    mov rdi, r9
    call write_str_to_file
    
    mov rax, [digits_count]
    lea rsi, [output_buffer]
    call number_str
    mov rdi, r9
    call write_str_to_file
    mov rsi, newline
    mov rdi, r9
    call write_str_to_file

    mov rax, 3
    mov rdi, r8
    syscall
    mov rdi, r9
    syscall
    call exit

write_str_to_file:
    push rax
    push rdi
    push rdx
    push rcx
    mov rax, rsi
    call len_str
    mov rdx, rax
    mov rax, 1
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret