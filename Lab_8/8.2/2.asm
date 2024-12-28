format elf64
;fasm 2.asm && ld 2.o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o 2 && ./2
public _start

extrn printf     
extrn scanf
extrn atof 

section '.data' writable
input db "%lf", 0  
ftype db "%.10f", 0xa, 0   
output db "%d %.10f %.10f", 0xa, 0 
header db "passes       target      result", 0xa, 0 
const_2 dq 2.0     
e_const dq 2.718281828459045

section '.bss' writable
target rq 1   
composition_1 rq 1   
composition_2 rq 1   
composition rq 1 
precesion rq 1     
diff rq 1    
count rq 1   
count_2 rq 1
divider rq 1


section '.text' executable
_start:
    finit  
    fldpi  
    fld [e_const]
    fmul st0, st1
    fld [const_2]
    fdiv st1, st0
    fxch st1
    fsqrt  

    fstp [target] 

    ;выводим посчитанную константу
    mov rdi, ftype 
    movq xmm0, [target]     
    mov rax, 2
    call printf     
    
    ;считываем
    mov rdi, input  
    mov rsi, precesion    
    movq xmm0, rsi  
    mov rax, 1
    call scanf

    mov rdi, header 
    call printf     

xor rbx, rbx

;инициализация делителя и композишена_1
mov [count], 0  
finit     
fld1
fstp [composition_1]    

finit
fld1
fstp [divider]

.loop:
    ;сложение композишенов
    finit
    fld [composition_1]
    fld [composition_2]
    fadd st0, st1
    fstp [composition]
    
    ;считаем разницу
    finit
    fld [target]     
    fld [composition] 
    fsub st0, st1   
    fabs
    fstp [diff]     

    ;если точность достигнута прыгаем на вывод
    finit
    fld [diff]
    fld [precesion] 
    fcomip st0, st1 
    ja .next  

    inc [count]
    
    ;начало вычисления делителя
    finit
    fld [const_2]
    fild [count]
    fmul st0, st1

    fld1
    fxch
    fadd st0, st1

    fld [divider]
    fmul st0, st1
    fstp [divider]
    ;посчитан

    ;делим
    finit
    fld [divider]
    fld1
    fdiv st0, st1

    fld [composition_1]     
    fadd st0, st1
    fstp [composition_1]    

    ;цепная дробь 
    mov rbx, [count]
    mov [count_2], rbx
    finit
    fild [count]
    fstp [composition_2]
    .loop2:
        cmp [count_2], 1
        jle .next2

        finit 
        fld1
        fld [composition_2]
        fadd st0, st1
        fstp [composition_2]

        dec [count_2]

        finit
        fld [composition_2]
        fild [count_2]
        fdiv st0, st1
        fstp [composition_2]

    jmp .loop2

    .next2:
    finit 
    fld1
    fld [composition_2]
    fadd st0, st1
    fxch
    fdiv st0, st1
    fstp [composition_2]
    ;посчитали

    ;отладочный вывод
    ;mov rdi, ftype 
    ;movq xmm0, [composition]     
    ;mov rax, 2
    ;call printf     

jmp .loop

.next:
    ;вывод данных таблицы
    mov rdi, output 
    mov rsi, [count]     
    mov rax, 1
    movq xmm0, [target]
    movq xmm1, [composition]    
    call printf     

.end:
    mov rax, 60     
    syscall   
