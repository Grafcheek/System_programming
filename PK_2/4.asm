format elf64
public _start

section '.data' writable
    prompt_msg db "Enter N: ", 0
    newline_char db 0xa, 0
    result_msg db "Result: ", 0
    

section '.bss' writable
    array_size dq 0
    positive_sum dq 0
    negative_sum dq 0

section '.text' executable


_start:
    mov rdi, [rsp]        ; argc
    cmp rdi, 2            ; Должно быть хотя бы 2 аргумента
    jl exit_with_error    ; Если меньше, завершить с ошибкой

    mov rsi, [rsp + 8]    ; Указатель на argv
    mov rsi, [rsi + 8]    ; Первый аргумент (argv[1])

    call string_to_int
    mov [array_size], rax
    test rax, rax         ; Проверка, что число не равно 0
    jz exit_with_error

    ; Обработка положительных чисел
    call process_positive

    ; Обработка отрицательных чисел
    call process_negative

    ; Суммирование результатов
    mov rax, [positive_sum]
    add rax, [negative_sum]

    ; Вывод результата
    mov rsi, prompt_msg
    call output_string
    call print_number
    call print_newline

    ; Завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall

process_positive:
    xor rbx, rbx
    mov rcx, [array_size]
positive_loop:
    test rcx, 1
    jz skip_positive
    add rbx, rcx
skip_positive:
    dec rcx
    jnz positive_loop
    mov [positive_sum], rbx
    ret

process_negative:
    xor rbx, rbx
    mov rcx, [array_size]
negative_loop:
    test rcx, 1
    jnz skip_negative
    sub rbx, rcx
skip_negative:
    dec rcx
    jnz negative_loop
    mov [negative_sum], rbx
    ret

exit_with_error:

    call output_string
    mov rax, 60
    mov rdi, 1
    syscall

output_string:
    mov rax, 1
    mov rdi, 1
    xor rdx, rdx
strlen_loop:
    cmp byte [rsi + rdx], 0
    je strlen_done
    inc rdx
    jmp strlen_loop
strlen_done:
    syscall
    ret

print_newline:
    mov rsi, 0xA
    call output_string
    ret

string_to_int:
    xor rax, rax
    xor rbx, rbx
atoi_loop:
    mov bl, byte [rsi]
    test bl, bl
    jz atoi_done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp atoi_loop
atoi_done:
    ret

print_number:
    mov rsi, rax
    xor rcx, rcx
    mov rbx, 10
reverse_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz reverse_loop
output_number:
    pop rax
    test rcx, rcx
    jz output_done
    call output_string
    loop output_number
output_done:
    ret