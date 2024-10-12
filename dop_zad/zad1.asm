prompt db "Guess a number between 1 and 10: ", 0
    higher db "The number is higher.", 10, 0
    lower db "The number is lower.", 10, 0
    correct db "Correct! You guessed the number.", 10, 0
    fail db "You've used all your attempts. The number was: ", 0
    newline db 10, 0

section .bss
    guess resb 2  ; Буфер для ввода числа
    number resb 1  ; Загаданное число

section .text
    global _start

_start:
    ; Генерация случайного числа (от 1 до 10)
    call get_random_number

    ; Устанавливаем счетчик попыток
    mov ecx, 3  ; 3 попытки

guess_loop:
    ; Выводим приглашение к вводу
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, len prompt
    int 0x80

    ; Читаем ввод пользователя
    call read_input

    ; Конвертируем введенное число из ASCII в int
    movzx eax, byte [guess]
    sub eax, '0'  ; Преобразуем символ в число

    ; Проверяем угадал ли пользователь
    cmp eax, [number]
    je correct_guess

    ; Если введенное число меньше загаданного
    jl higher_number

    ; Иначе число больше загаданного
lower_number:
    mov eax, 4
    mov ebx, 1
    mov ecx, lower
    mov edx, len lower
    int 0x80
    jmp check_attempts

higher_number:
    mov eax, 4
    mov ebx, 1
    mov ecx, higher
    mov edx, len higher
    int 0x80

check_attempts:
    ; Уменьшаем количество попыток
    dec ecx
    jnz guess_loop

    ; Если попытки закончились, выводим загаданное число
    mov eax, 4
    mov ebx, 1
    mov ecx, fail
    mov edx, len fail
    int 0x80

    ; Выводим загаданное число
    movzx eax, byte [number]
    add eax, '0'  ; Преобразуем число в ASCII
    mov [guess], al
    mov eax, 4
    mov ebx, 1
    mov ecx, guess
    mov edx, 1
    int 0x80

    ; Завершаем программу
    call exit

correct_guess:
    ; Сообщаем, что число угадано
    mov eax, 4
    mov ebx, 1
    mov ecx, correct
    mov edx, len correct
    int 0x80
    jmp done

done:
    call exit

; Чтение ввода от пользователя
read_input:
    mov eax, 3  ; syscall read
    mov ebx, 0  ; from stdin
    mov ecx, guess
    mov edx, 2  ; читаем два символа (число + новая строка)
    int 0x80
    ret

; Генерация случайного числа от 1 до 10
get_random_number:
    mov eax, 0x27 ; syscall for random (Linux)
    mov ebx, 0
    mov ecx, 1
    mov edx, 10
    int 0x80

    ; Сохраняем число в [number]
    mov [number], al
    ret

exit:
    mov eax, 1  ; syscall for exit
    xor ebx, ebx
    int 0x80

section .data
len equ $ - prompt
