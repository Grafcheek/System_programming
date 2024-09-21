format ELF64

public _start
public exit
public print_symb

section '.bss' writable
  array db 9 dup ('$')
  newline db 17 dup (0xA)
  place db 1

section '.text' executable
  _start:
    xor rsi, rsi
    .iter1:
      xor rdi, rdi  
      .iter2:
        mov al, [array+rdi]
        push rdi
        call print_symb
        pop rdi
        inc rdi
        cmp rdi,9
        jne .iter2

      mov al, [newline+rsi]
      push rsi
      call print_symb
      pop rsi

      inc rsi
      cmp rsi,17
      jne .iter1
    call exit

print_symb:
  push rax           
  mov [place], al    
  mov eax, 4         
  mov ebx, 1         
  mov ecx, place     
  mov edx, 1        
  int 0x80           
  pop rax            
  ret

exit:
  mov eax, 1         
  mov ebx, 0         
  int 0x80