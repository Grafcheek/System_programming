format ELF64

public _start
public read
public compare

include '/workspaces/System_programming/Lab_4/func.asm'

section '.bss' writable
input dq ?
output dq ?
password db "pass123", 0
success db "Вошли", 0
failure db "Неудача", 0
retry db "Неверный пароль", 0

section '.text' executable
_start:
mov rsi, 5
mov rax, password
call len_str
mov r9, rax
.loop:
push rsi
call read
call compare
cmp r8, 1
je .suc
mov rsi, retry
call print_str
call new_line
pop rsi
dec rsi
cmp rsi, 0
jg .loop
mov rsi, failure
call print_str
call new_line
call exit
.suc:
mov rsi, success
call print_str
call new_line
call exit

read:
push rax
push rdi
push rsi
push rdx
mov rax, 0
mov rdi, 0
mov rsi, input
mov rdx, 255
syscall
mov rax, input
call len_str
mov byte [input + rax-1], 0
pop rax
pop rdi
pop rsi
pop rdx
ret

compare:
mov rax, input
mov rdx, password
mov rsi, -1
xor r8, r8
.loop:
inc rsi
cmp rsi, r9
jg .f1
mov bl, byte [rdx+rsi]
cmp byte [rax+rsi], bl
je .loop
.f1:
cmp byte [rax+rsi], bl
jne .notequal
mov r8, 1
ret
.notequal:
ret