format ELF64

public _start

section '.bss' writable
  place db 1
  buffer rb 256

section '.text' executable

include 'func.asm'

_start:
  mov rsi, buffer
  call input_keyboard

  mov rax, buffer
  call len_str

  mov rcx, rax
  dec rcx
  .loop:
    mov bl, [buffer+rcx]
    mov [place], bl

    mov rsi, place
    call print

    dec rcx
    cmp rcx, -1
    jg .loop

  call exit

  print:
    push rax
    push rdi
    push rdx
    push rcx
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret