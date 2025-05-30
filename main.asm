format ELF64
public _start


; ========== Константы ==========
SIZE  equ 5
CELLS equ SIZE*SIZE


section '.data' writeable
    board db  1,  2,  3,  4,  5
          db  6,  7,  8,  9, 10
          db 11, 12, 13, 14, 15
          db 16, 17, 18, 19, 20
          db 21, 22, 23, 24,  0

    fmt           db "%2d ", 0
    space         db "   ", 0
    victory_msg   db "You win!", 0
    help_msg      db "WASD - move, Q - quit, R - shuffle", 0
    shuffling_msg db "Shuffling...", 0
    keymap        db 'a','s','d','w'

section '.text' executable

extrn initscr
extrn endwin
extrn refresh
extrn getch
extrn mvprintw
extrn move
extrn addstr
extrn exit
extrn noecho
extrn curs_set
extrn keypad
extrn stdscr




_start:
    call initscr
    call noecho
    mov edi, 0
    call curs_set
    mov rdi, [stdscr]
    mov esi, 1
    call keypad

    call show_shuffling
    call shuffle_board

main_loop:
    call draw_board
    call draw_help
    call refresh

    call getch
    movzx edi, al

    cmp dil, 'q'
    je quit_game

    cmp dil, 'r'
    je .reshuffle

    call handle_key
    jmp .after_key

.reshuffle:
    call shuffle_board
.after_key:
    call draw_board
    call draw_help
    call refresh

    call check_win
    test rax, rax
    jz .no_win

    mov edi, SIZE+3
    mov esi, 0
    call move
    mov rdi, victory_msg
    call addstr
    call refresh
    call getch
    call endwin
    mov edi, 0
    call exit

.no_win:
    jmp main_loop

quit_game:
    call endwin
    mov edi, 0
    call exit

; ---------- вспомогательная отрисовка ----------
show_shuffling:
    mov edi, 0
    mov esi, 0
    call move
    mov rdi, shuffling_msg
    call addstr
    call refresh
    ret

draw_board:
    xor rcx, rcx
.draw_loop:
    mov rdi, rcx
    call draw_cell
    inc rcx
    cmp rcx, CELLS
    jl .draw_loop
    ret

draw_help:
    mov edi, SIZE+1
    mov esi, 0
    call move
    mov rdi, help_msg
    call addstr
    ret

draw_cell:
    push rdi rsi rdx rcx rbx r8
    mov rax, rdi
    mov rbx, SIZE
    xor rdx, rdx
    div rbx
    mov r8d, edi
    mov edi, eax
    mov esi, edx
    imul esi, 3
    movzx eax, byte [board + r8]
    test eax, eax
    jz .draw_space
    mov rdx, fmt
    mov ecx, eax
    call mvprintw
    jmp .done

.draw_space:
    mov rdx, space
    call mvprintw

.done:
    pop r8 rbx rcx rdx rsi rdi
    ret

; ---------- управление ----------
handle_key:
    mov r9b, dil
    xor rcx, rcx
.find_zero:
    cmp rcx, CELLS
    je .done
    cmp byte [board + rcx], 0
    je .found
    inc rcx
    jmp .find_zero

.found:
    mov rbx, rcx
    mov rax, rbx
    xor rdx, rdx
    mov rcx, SIZE
    div rcx
    mov esi, edx
    mov edi, eax

    cmp r9b, 'w'
    je .up
    cmp r9b, 's'
    je .down
    cmp r9b, 'a'
    je .left
    cmp r9b, 'd'
    je .right
    ret

.up:
    cmp edi, 0
    je .done
    dec edi
    jmp .swap

.down:
    cmp edi, SIZE-1
    je .done
    inc edi
    jmp .swap

.left:
    cmp esi, 0
    je .done
    dec esi
    jmp .swap

.right:
    cmp esi, SIZE-1
    je .done
    inc esi
    jmp .swap

.swap:
    lea rax, [rdi*SIZE]
    add rax, rsi
    cmp rax, 0
    jl .done
    cmp rax, CELLS
    jge .done
    mov dl, [board + rbx]
    mov dh, [board + rax]
    mov [board + rbx], dh
    mov [board + rax], dl

.done:
    ret

; ---------- проверка победы ----------
check_win:
    xor rax, rax
    xor rcx, rcx
.loop:
    cmp rcx, CELLS-1
    je .check_last
    mov dl, [board + rcx]
    inc cl
    cmp dl, cl
    jne .ret
    jmp .loop

.check_last:
    cmp byte [board + (CELLS-1)], 0
    jne .ret
    mov rax, 1

.ret:
    ret

; ---------- перемешивание ----------
shuffle_board:
    mov r12d, 80
.loop:
    rdtsc
    add eax, edx
    and eax, 3
    movzx edi, byte [keymap + rax]
    call shuffle_move
    dec r12d
    jnz .loop
    ret

shuffle_move:
    push rcx
    push rbx
    mov r9b, dil
    xor rcx, rcx
.find_zero:
    cmp rcx, CELLS
    je .restore
    cmp byte [board + rcx], 0
    je .found
    inc rcx
    jmp .find_zero

.found:
    mov rbx, rcx
    mov rax, rbx
    xor rdx, rdx
    mov r10d, SIZE
    div r10d
    mov esi, edx
    mov edi, eax

    cmp r9b, 'w'
    je .up
    cmp r9b, 's'
    je .down
    cmp r9b, 'a'
    je .left
    cmp r9b, 'd'
    je .right
    jmp .restore

.up:
    cmp edi, 0
    je .restore
    dec edi
    jmp .swap

.down:
    cmp edi, SIZE-1
    je .restore
    inc edi
    jmp .swap

.left:
    cmp esi, 0
    je .restore
    dec esi
    jmp .swap

.right:
    cmp esi, SIZE-1
    je .restore
    inc esi
    jmp .swap

.swap:
    lea rax, [rdi*SIZE]
    add rax, rsi
    mov dl, [board + rbx]
    mov dh, [board + rax]
    mov [board + rbx], dh
    mov [board + rax], dl

.restore:
    pop rbx
    pop rcx
    ret
