; caller -> rdi, rsi, rdx, rcx, r8, r9, r10, r11
; callee -> rbp, rsp, rbx, r12, r13, r14, r15
; rdi, rsi, 

section .text
    global a
    global f
    global _start

a:
    push rbp
    push rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; r12 = b
    mov rax, r12 ; rax = b
    imul rax, 2 ; rax = 2*b
    add rax, 5 ; rax = 2*b + 5
    sub rax, 3 ; rax = 2*b + 5 - 3
    mov rax, rax ; move return value into rax

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rsp
    pop rbp
    
    ret

f:
    push rbp
    push rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; r12 = x
    mov r13, rsi ; r13 = y

    mov rax, r12 ; rax = x
    mov rbx, 0 ; rbx = 0
    cmp rax, rbx

    jne .nonEqual
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11

    mov rdi, r13 ; rdi = y
    call a ; rax = a(y)

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ; rax = a(y)
    mov rax, rax
    jmp .return

.nonEqual:
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11

    mov rdi, r13 ; rdi = y
    call a ; rax = a(y)

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi

    mov r14, rax ; r14 = a(y)
    mov rax, r12 ; rax = x
    sub rax, 1 ; rax = x - 1
    mov r15, rax ; r15 = x - 1

    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11

    mov rdi, r15 ; rdi = x - 1
    mov rsi, r14 ; rsi = a(y)
    call f ; rax = f(x-1, a(y))
    mov rax, rax

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    jmp .return

.return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rsp
    pop rbp
    ret

_start:
    push rbp
    push rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 24

    mov rax, 0 
    mov [rsp + 16], rax ; x = 0
    mov rax, 3
    mov [rsp + 8], rax ; n = 3

    mov rax, 0
    mov [rsp], rax ; i = 0

.forBegin:
    mov rax, [rsp] ; rax = i
    mov rbx, [rsp + 8] ; rbx = n
    cmp rax, rbx 
    jge .forEnd
    mov rax, [rsp] ; rax = i
    and rax, 1 ; rax = i & 1
    mov rbx, 0 ; rbx = 0
    cmp rax, rbx 
    je .equal

    push rdi ; rsp -= 8, *rsp = rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11

    mov rdi, [rsp + 64] ; rdi = i
    mov rsi, [rsp + 72] ; rsi = n
    call f

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi 
    ; rax = f(i,n)
    mov rbx, [rsp + 16]
    add rax, rbx ; rax = x + f(i,n)
    mov [rsp + 16], rax ; x = rax

    jmp .ifEnd
.equal:
    push rdi ; rsp -= 8, *rsp = rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11

    mov rdi, [rsp + 80]
    call a

    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi 
    ; rax = a(x)
    mov rbx, [rsp + 16] ; rbx = x
    add rax, rbx ; rax = a(x) + x
    mov [rsp+16], rax ; x = rax

.ifEnd:
    mov rax, [rsp] ; rax = i
    add rax, 1 ; rax = rax + 1
    mov [rsp], rax ; i = rax
    jmp .forBegin
.forEnd:

    mov rax, [rsp+16]
    add rsp, 24

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rsp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall
