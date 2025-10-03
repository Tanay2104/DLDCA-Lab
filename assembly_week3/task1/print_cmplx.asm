section .data 

fmt_complex db "%s => Real: %f Imaginary: %f", 10, 0     ;
fmt_float db "%s => Float: %f", 10, 0

label_demo_print_float db "Demo of print_float", 0
label_print db "Testing print complex:",0

one dq 1.0

complex1:
    complex1_name db 'a'
    complex1_pad  db 7 dup(0)  
    complex1_real dq 1.0
    complex1_img  dq 2.5

section .text
    default rel
    extern printf
    global print_cmplx
    global main
main:
    push rbp
    ; --- Demo: print_float --- ;
    lea rdi, [label_demo_print_float]
    lea rsi, [one]
    call print_float

    ; --- Test: print_cmplx --- ; 
    lea rdi, [label_print]
    lea rsi, [complex1]
    call print_cmplx

    pop rbp
    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall


print_float:
    push rbp
    mov rbp, rsp
    mov     rax, rsi
    mov     rsi, rdi         ; rsi = label
    mov     rdi, fmt_float
    movq    xmm0, qword [rax]
    mov     eax, 1 ; Number of xmm arguments passed
    call    printf
    pop rbp
    ret


;------------------------------------
print_cmplx:
    push rbp
    mov rbp, rsp

    mov     rax, rsi
    mov     rsi, rdi         ; rsi = label
    mov     rdi, fmt_complex
    movq    xmm0, qword [rax + 8]
    movq    xmm1, qword [rax + 16]
    mov     eax, 2
    call    printf
    pop rbp
    ret