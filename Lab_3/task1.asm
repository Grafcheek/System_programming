format ELF64

public _start

section '.bss' writable
  buffer db 1

section '.text' executable
print_symbol:
    xor rbx, rbx

    cmp rax, 9
    jle .one_symbol

    mov rcx, 10
.loop:
    xor rdx, rdx
    div rcx
    push rdx
    inc rbx
    test rax, rax
    jnz .loop

.print:
    pop rax
    add rax, '0'
    mov [buffer], al

    mov eax, 1
    mov edi, 1
    mov rsi, buffer
    mov edx, 1
    syscall

    dec rbx
    jnz .print

    
    mov rax, 10           
    mov [buffer], al       
    mov eax, 1             
    mov edi, 1             
    mov rsi, buffer        
    mov edx, 1       
    syscall                
    ret


.one_symbol:
    add rax, '0'
    mov [buffer], al

    mov eax, 1
    mov edi, 1
    mov rsi, buffer
    mov edx, 1
    syscall
    ret

_start:
    pop rcx
    cmp rcx, 2
    jl .exit

    mov rsi, [rsp + 8]
    movzx rax, byte [rsi]
    call print_symbol

.exit:
    mov eax, 60
    xor edi, edi
    syscall