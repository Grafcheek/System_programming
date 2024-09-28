format ELF64

public _start

section '.bss' writable
    buffer db 20

section '.data'
    msg_div_zero db 'Ошибка: Деление на ноль', 10, 0
    msg_length equ $ - msg_div_zero

section '.text' executable

string_to_number:
    push rbx
    push rcx

    xor rax, rax
    xor rcx, rcx

.loop:
    movzx rbx, byte [rsi + rcx]
    cmp rbx, '0'
    jb .done
    cmp rbx, '9'
    ja .done

    sub rbx, '0'
    mov rdx, rax
    mov rax, rax
    mul rdi
    add rax, rbx
    inc rcx
    jmp .loop

.done:
    pop rcx
    pop rbx
    ret

print_number:
    mov rbx, 10
    xor rcx, rcx

.convert:
    xor rdx, rdx
    div rbx
    push rdx
    inc rcx
    test rax, rax
    jnz .convert

.print:
    pop rax
    add al, '0'
    mov [buffer + rcx - 1], al
    dec rcx
    mov eax, 1
    mov edi, 1
    lea rsi, [buffer]
    mov rdx, 20
    sub rdx, rcx
    syscall
    ret

_start:
    pop rcx
    cmp rcx, 4
    jne .exit

    mov rsi, [rsp + 8]
    mov rdi, 10
    call string_to_number
    mov rbx, rax

    mov rsi, [rsp + 16]
    mov rdi, 10
    call string_to_number
    mov rcx, rax

    mov rsi, [rsp + 24]
    mov rdi, 10
    call string_to_number
    mov rdx, rax

    test rcx, rcx
    jz .division_by_zero
    mov rax, rbx
    imul rax, 100
    xor rdx, rdx
    div rcx

    sub rax, rbx

    test rax, rax
    jz .division_by_zero
    xor rdx, rdx
    div rcx

    imul rax, rdx
    add rax, rbx

    call print_number
    jmp .exit

.division_by_zero:
    mov rsi, msg_div_zero
    mov rdx, msg_length
    mov rax, 1
    mov edi, 1
    syscall
    jmp .exit

.exit:
    mov eax, 60
    xor edi, edi
    syscall
