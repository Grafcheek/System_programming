format ELF64

public _start

section '.bss' writable
    input_buffer rb 256
    result_buffer rb 32

section '.text' executable

include 'func.asm'

_start:
    mov rsi, input_buffer
    call input_keyboard

    mov rsi, input_buffer
    call str_number

    mov rdi, 481
    xor rdx, rdx
    div rdi

    mov rsi, result_buffer
    call number_str

    mov rsi, result_buffer
    call print_str

    call new_line
    call exit