format ELF64

public _start
public exit
public print_symb

section '.bss' writable
  number dq 2634342072    
  result dq 0            
  ten dq 10                  
  place db 1         

section '.text' executable
  _start:
    mov rax, [number]      
    xor rbx, rbx            
    .sum_loop:
      xor rdx, rdx           
      div qword [ten]         
      add rbx, rdx            
      test rax, rax              
      jnz .sum_loop        
    mov [result], rbx        
    call print_symb         
    mov eax, 60              
    xor edi, edi        
    syscall                  

print_symb:
    mov rax, [result]       
    mov rdi, 10             
    xor rbx, rbx             
    cmp rax, 0
    je .print_zero
    .loop:
        xor rdx, rdx           
        div rdi               
        push rdx                
        inc rbx                
        test rax, rax           
        jnz .loop                 
    .print_loop:
        pop rax                  
        add rax, '0'             
        mov [place], al         
        mov eax, 1              
        mov edi, 1              
        mov rsi, place         
        mov edx, 1              
        syscall
        dec rbx                 
        jnz .print_loop       
    ret
    .print_zero:
        mov byte [place], '0'
        mov eax, 1              
        mov edi, 1              
        mov rsi, place         
        mov edx, 1              
        syscall
        ret

exit:
  mov eax, 60
  xor edi, edi
  syscall
