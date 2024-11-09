format ELF64 
 
public _start 
 
section '.bss' writable 
    buffer db 1 
 
section '.text' executable 
 
string_to_number: 
    push rcx 
    push rbx 
 
    xor rax, rax 
    xor rcx, rcx 
 
.loop: 
    xor rbx, rbx 
    mov bl, byte [rsi + rcx] 
    cmp bl, 48 
    jl .is_finished_check 
    cmp bl, 57 
    jg .is_finished_check 
 
    sub bl, 48 
    add rax, rbx 
    mov rbx, 10 
    mul rbx 
    inc rcx 
    jmp .loop 
 
.is_finished_check: 
    cmp rcx, 0 
    je .reset 
    mov rbx, 10 
    div rbx 
 
.reset: 
    pop rbx 
    pop rcx 
    ret 
 
print_symbol: 
    xor rbx, rbx 
 
    cmp r12, 1 
    jne .pos 
 
    push rax 
    mov rax, '-' 
    mov [buffer], al 
    mov rax, 1 
    mov rdi, 1 
    mov rsi, buffer 
    mov rdx, 1 
    syscall 
    pop rax 
     
    .pos: 
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
 
.print_loop: 
    pop rax 
    add rax, '0' 
    mov [buffer], al 
 
    mov eax, 1 
    mov edi, 1 
    mov rsi, buffer 
    mov edx, 1 
    syscall 
 
    dec rbx 
    jnz .print_loop 
 
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
    cmp rcx, 4 
    jne .exit 
 
    mov rsi, [rsp + 8] 
    call string_to_number 
    mov r8, rax 
 
    mov rsi, [rsp + 16] 
    call string_to_number 
    mov r9, rax 
 
    mov rsi, [rsp + 24] 
    call string_to_number 
    mov r10, rax 
 
    mov rax, r8 
    xor rdx, rdx 
    idiv r9 
    mov r11, rax 
 
   
    mov rax, r11 
    sub rax, r8 
    mov r11, rax 
 
    cmp r11,0 
    jge .cont_1 
    neg r11 
    mov r12, 1 
 
    .cont_1: 
    mov rax, r11 
    xor rdx, rdx 
    idiv r9 
    mov r11, rax 
   
    imul r11, r10 
 
    cmp r12, 1 
    jne .pos 
 
    sub r8, r11 
    mov r11, r8 
    jmp .print 
    .pos: 
    add r11, r8 
    .print: 
    xor r12, r12 
    mov rax, r11 
 
    cmp rax,0 
    jge .cont_2 
    neg rax 
    mov r12, 1 
 
    .cont_2: 
 
    call print_symbol 
 
.exit: 
    mov eax, 60 
    xor edi, edi 
    syscall