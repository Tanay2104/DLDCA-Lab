section .data

complex1:
    complex1_name db 'a'
    complex1_pad  db 7 dup(0)  
    complex1_real dq 1.0
    complex1_img  dq 2.5

complex2:
    complex2_name db 'b'
    complex2_pad  db 7 dup(0)  
    complex2_real dq 3.5
    complex2_img  dq 4.0

polar_complx:
    polar_complx_name db 'c'
    polar_complx_pad db 7 dup(0)
    polar_complx_mag dq 10.0
    polar_complx_ang dq 0.0001

fmt db "%s => %f %f", 10, 0     ;
label_polar2rect db "Testing polars to rectangular",0
label_exp db "Testing exp",0
label_sin db "Testing sin",0
label_cos db "Testing cos",0

;;;;;;;;;;;;;
seventwenty dq 720.0
twentyfour dq 24.0
fivezerofourzero dq 5040.0
onetwenty dq 120.0
six dq 6.0
two dq 2.0
one dq 1.0
temp dq 0.0
;;;; Fill other constants needed 
;;;;;;;;;;;;;

temp_cmplx:
    temp_name db 'r'
    temp_pad  db 7 dup(0)
    temp_real dq 0.0
    temp_img  dq 0.0

section .text
    default rel
    extern print_cmplx,print_float
    global main

main:
    push rbp
    
    ; --- Test: Polar to Rectangular ---
    lea rdi, [polar_complx]         ; pointer to input polar struct
    lea rsi, [temp_cmplx]     ; pointer to output rect struct
    
    call polars_to_rect

    lea rdi, [label_polar2rect]
    lea rsi, [temp_cmplx]
    call print_cmplx          ; should show converted rectangular form

    ; --- Test: exp ---
    movups xmm0, [two]
    mov rdi, 0x6

    call exp

    movups [temp],xmm0 
    lea rdi, [label_exp]
    lea rsi , [temp]
    call print_float

    ; --- Test: sin ---
    movups xmm0, [two]

    call sin

    movups [temp],xmm0 
    lea rdi, [label_sin]
    lea rsi , [temp]
    call print_float

    ; --- Test: cos ---
    movups xmm0, [two]
    call cos

    movups [temp],xmm0 
    lea rdi, [label_cos]
    lea rsi , [temp]
    call print_float

    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall

    pop rbp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FILL FUNCTIONS BELOW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
polars_to_rect:
    push rbp
    ; rdi contains polar complex, rsi temp rect complex
    ; rect = x + i*y. polar = re^i*theta
    ; real x = r*cos(theta)
    ; img y = r*sin(theta)
    movsd xmm0, [rdi+16] ; xmm0 contains theta
    call cos ; now xmm0 will have cos(theta)
    movsd xmm1, [rdi+8] ; xmm1 contains r
    mulsd xmm1, xmm0 ; xmm1 = r*cos(theta)
    movsd [rsi + 8], xmm1 ; Now rsi + 8 has real part

    movsd xmm0, [rdi+16] ; xmm0 contains theta
    call sin ; now xmm0 will have cos(theta)
    movsd xmm1, [rdi+8] ; xmm1 contains r
    mulsd xmm1, xmm0 ; xmm1 = r*sin(theta)
    movsd [rsi + 16], xmm1

    pop rbp
    ret
;-------------------------------------------------
exp:
    ; xmm0 [two], rdi: 0x6
    push r8
    movsd xmm1, xmm0 ; xmm1 will contain our power of two
    ; we initialise a counter in r8
    mov r8, 0
    sub rdi, 1 
    cmp r8, rdi
    jl exp_loop ; if counter < exp, loop 

    exp_loop:
        mulsd xmm1,  xmm0 ; temp = temp * base
        inc r8 ; incrementing counter
        cmp r8, rdi ;  Loop if less
        jl exp_loop
        jmp .end_exp_loop
        
    .end_exp_loop:
        movsd xmm0, xmm1 ; Storing return value in xmm0
        pop r8
        ret
;-------------------------------------------------
sin:
; xmm0 contains input theta, [two]
; return theta - exp(theta, 3)/6 + exp(theta, 5)/120 - exp(theta, 7)/5040
    movsd xmm3, xmm0 ; xmm3 has theta
    push rdi
    ; Calculating first term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x3
    movsd xmm0, xmm3
    call exp ; second term exp(theta, 3)
    movups xmm1, [six] ; We need to put divisor  6 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 3) / 6
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    subsd xmm0, xmm2 ; xmm0 = theta - exp(theta,3) / 6

    ; Calculating second term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x5
    movsd xmm0, xmm3
    call exp ; second term exp(theta, 5)
    movups xmm1, [onetwenty] ; We need to put divisor 120 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 5) / 120
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    addsd xmm0, xmm2 ; xmm0 = theta - exp(theta,3)/6 + exp(theta, 5)/120


    ; Calcualting third term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x7
    movsd xmm0, xmm3
    call exp ; term exp(theta, 7)
    movups xmm1, [fivezerofourzero] ; We need to put divisor 5040 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 7) / 5040
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    subsd xmm0, xmm2 ; xmm0 = theta - exp(theta,3)/6 + exp(theta, 5)/120 - exp(theta,7)/5040

    pop rdi
    ret


cos:
; return 1 - exp(theta, 2)/2 + exp(theta,4)/24 - ex(theta,6)/720
    movsd xmm3, xmm0 ; xmm3 has theta
    push rdi

    movups xmm0, [one]
    ; Calculating first term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x2
    movsd xmm0, xmm3
    call exp ; second term exp(theta, 2)
    movups xmm1, [two] ; We need to put divisor 2 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 2) / 2
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    subsd xmm0, xmm2 ; xmm0 = 1 - exp(theta,2) / 2

    ; Calculating second term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x4
    movsd xmm0, xmm3
    call exp ; second term exp(theta, 4)
    movups xmm1, [twentyfour] ; We need to put divisor 23 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 4) / 24
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    addsd xmm0, xmm2 ; xmm0 = 1 - exp(theta, 2)/2 + exp(theta,4)/24


    ; Calcualting third term
    sub rsp, 16 ; Making space in stack to store xmm0
    movaps [rsp], xmm0 ; push
    mov rdi, 0x6
    movsd xmm0, xmm3
    call exp ; term exp(theta, 6)
    movups xmm1, [seventwenty] ; We need to put divisor 720 in xmm1 register
    divsd xmm0, xmm1 ; xmm0 = exp(theta, 6) / 720
    movsd xmm2, xmm0 ; We need to store this elsewhere as we'll restore xmm0
    movaps xmm0, [rsp] ; pop
    add rsp, 16
    subsd xmm0, xmm2 ; xmm0 =  1 - exp(theta, 2)/2 + exp(theta,4)/24 - ex(theta,6)/720

    pop rdi
    ret
;-------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE ENDS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
