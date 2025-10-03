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

label_add db "Testing Addition",0
label_sub db "Testing subtraction",0
label_mul db "Testing Multiplication", 0
label_recip db "Testing Reciprocal", 0

temp_cmplx:
    temp_name db 'r'
    temp_pad  db 7 dup(0)
    temp_real dq 0.0
    temp_img  dq 0.0

section .text
    default rel
    extern print_cmplx
    global main

main:
    push rbp

    ; --- Test: Addition ---
    lea rdi, [complex2]
    lea rsi, [complex1]
    lea rdx, [temp_cmplx]
    call add_cmplx
    lea rdi, [label_add]
    lea rsi, [temp_cmplx]
    call print_cmplx  ; Expect 4.5 6.5

    ; --- Test: Subtraction ---
    lea rdi, [complex2]
    lea rsi, [complex1]
    lea rdx, [temp_cmplx]
    call sub_cmplx
    lea rdi, [label_sub]
    lea rsi, [temp_cmplx]
    call print_cmplx  ; Expect 2.5 1.5

    ; --- Test: Multiplication ---
    lea rdi, [complex2]
    lea rsi, [complex1]
    lea rdx, [temp_cmplx]
    call mul_cmplx
    lea rdi, [label_mul]
    lea rsi, [temp_cmplx]
    call print_cmplx  ; Expect -6.500000 12.750000

    ; --- Test: Reciprocal ---
    lea rdi, [complex1]
    lea rsi, [temp_cmplx]
    call recip_cmplx
    lea rdi, [label_recip]
    lea rsi, [temp_cmplx]
    call print_cmplx  ; Reciprocal of (1 + 2.5i) = (0.137931 -0.344828i)

    pop rbp
    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall

add_cmplx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to input three addresses of complex numbers subtract the complexes at the first two addresses and 
; write the result into the thrid address (source1,source2,destination) => write (source1 + source2) into destination
; rdi: complex 2, rsi: complex 1, rdx: tmp_complex.

movq xmm0, qword[rdi + 8]; real of cmp2
movq xmm1, qword[rsi + 8]; real of cmp1
addsd xmm0, xmm1 ; xmm0 = cmp2.real + cm1.real
movq qword[rdx + 8], xmm0; storing result
movq xmm0, qword[rdi + 16]; img of cmp2
movq xmm1, qword[rsi + 16]; img of cmp1
addsd xmm0, xmm1 ; xmm0 = cmp2.img - cm1.real
movq qword[rdx + 16], xmm0; storing result
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
sub_cmplx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to input three addresses of complex numbers subtract the complexes at the first two addresses and 
; write the result into the thrid address (source1,source2,destination) => write (source1 - source2) into destination
; rdi: complex 2, rsi: complex 1, rdx: tmp_complex.  tmp_comples = cmp2 - cmp1
movq xmm0, qword[rdi + 8]; real of cmp2
movq xmm1, qword[rsi + 8]; real of cmp1
subsd xmm0, xmm1 ; xmm0 = cmp2.real - cm1.real
movq qword[rdx + 8], xmm0; storing result
movq xmm0, qword[rdi + 16]; img of cmp2
movq xmm1, qword[rsi + 16]; img of cmp1
subsd xmm0, xmm1 ; xmm0 = cmp2.img - cm1.img
movq qword[rdx + 16], xmm0; storing result
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
mul_cmplx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to input three addresses of complex numbers multiply the complexes at the first two addresses and 
; write the result into the thrid address
; rdi: complex 2, rsi: complex 1, rdx: tmp_complex. 
movq xmm0, qword[rdi + 8]; real of cmp2
movq xmm1, qword[rsi + 8]; real of cmp1
movq xmm2, qword[rdi + 16]; img of cmp2
movq xmm3, qword[rsi + 16]; img of cmp1
mulsd xmm0, xmm1 ; xmm0 = cmp2.real * cmp1.real
mulsd xmm2, xmm3 ; xmm2 = cmp2.img * cmp1.img
subsd xmm0, xmm2 ; xmm0 = cmp2.real * cmp1.real -  cmp2.img * cmp1.img
movq qword[rdx + 8], xmm0; storing result

movq xmm0, qword[rdi + 8]; real of cmp2
movq xmm1, qword[rsi + 8]; real of cmp1
movq xmm2, qword[rdi + 16]; img of cmp2
movq xmm3, qword[rsi + 16]; img of cmp1
mulsd xmm0, xmm3 ; xmm0 = cmp2.real * cmp1.img
mulsd xmm2, xmm1 ; xmm2 = cmp2.img * cmp1.real
addsd xmm0, xmm2 ; xmm0 = cmp2.real * cmp1.real -  cmp2.img * cmp1.img
movq qword[rdx + 16], xmm0; storing result
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
recip_cmplx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to input two addresses of complex numbers find reciprocal of the complex at the first address and 
; write the result into the second address (source1,destination) => write (1/source1) into destination
    ; b->real = (a->real) / (a->real ^ 2 + b->real ^ 2)
    movq xmm0, qword[rdi+8] ; real part a-> real
    movq xmm1, qword[rdi+16] ; complex part a -> complex
    mulsd xmm0, xmm0 ; xmm0 = a->real ^ 2
    mulsd xmm1, xmm1 ; xmm1 = a->img ^ 2
    addsd xmm0, xmm1 ;  xmm0 = a->real ^ 2 + a->img ^ 2
    
    movq xmm1, qword[rdi+8] ; xmm1 = a->real
    divsd xmm1, xmm0; xmm0 = a->real / (a->real ^ 2 + b->real ^ 2)

    movq qword[rsi + 8], xmm1

    ; b->img = (a->img) / (a->real ^ 2 + b->real ^ 2)
    movq xmm0, qword[rdi+8] ; real part a-> real
    movq xmm1, qword[rdi+16] ; complex part a -> complex
    mulsd xmm0, xmm0 ; xmm0 = a->real ^ 2
    mulsd xmm1, xmm1 ; xmm1 = a->img ^ 2
    addsd xmm0, xmm1 ;  xmm0 = a->real ^ 2 + a->img ^ 2

    mov r8, 0
    movq xmm2, r8; for negation
    movq xmm1, qword[rdi+16] ; xmm1 = a->img
    subsd xmm2, xmm1
    divsd xmm2, xmm0; xmm0 = a->img / (a->real ^ 2 + b->real ^ 2)

    movq qword[rsi + 16], xmm2
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
