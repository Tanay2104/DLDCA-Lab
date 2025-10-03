; db -> define byte
; dw -> define word (16 bits)
; dd -> define double word (32 bits)
; dq -> define quad word (64 bits)
section .data
    num1    dq 5             ; num1 contains address of a 64 bit memory chunk, which has the value 5
    num2    dq 7             ; num1 contains address of a 64 bit memory chunk, which has the value 7
    buffer  db 20 dup(0)     ; Output buffer for result string, ignore

section .text
    global _start ; essentially just means start here

_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Load numbers and add
    ; Store the result in rax register
    ; You may add two numbers by using the add instruction
    ; add r1, r2 => r1 = r1 + r2
    mov rcx, [num1]
    mov rdx, [num2]
    add rcx, rdx
    mov rax, rcx
    ; mov r1, [num] => r1 = *num (* is pointer dereference :D)
    ; mov r1, num1 => r1 = num1 
    ; mov r1, r2 => r1 = r2 (copy r2 to r1)
    ; mov [r1], r2 => *r1 = r2 (store r2 in memory pointed by r1)
    ; mov num, r1 => Illegal
    ; mov [num], r1 => *num = r1 (store r1 in memory pointed by num) -> Never do this please
    ; mov rax, 2220934 ; Remove this line :-)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Don't worry too much about the below code, it's just converting the number to a string
    ; Convert rax (result) to string
    mov rdi, buffer          ; rdi = pointer to buffer
    add rdi, 19              ; point to end of buffer
    mov byte [rdi], 10       ; newline
    dec rdi                  ; move before newline

    mov rcx, 10              ; divisor
.convert_loop:
    xor rdx, rdx             ; clear rdx before div
    div rcx                  ; rax ÷ 10 → quotient in rax, remainder in rdx
    add dl, '0'              ; convert digit to ASCII
    mov [rdi], dl            ; store digit
    dec rdi 
    test rax, rax
    jnz .convert_loop

    inc rdi                  ; point to first digit

    ; Write to stdout using syscall
    ; NOTE: IMPORTANT, Stack must be 16-byte aligned before syscall
    ; Arguments for syscall are in: rdi->rsi->rdx->r10->r8->r9
    ; write(fd=1, buffer, size)
    mov rax, 1               ; syscall: write
    mov rsi, rdi             ; rsi = pointer to string
    mov rdi, 1               ; fd: stdout
    mov rdx, buffer + 20
    sub rdx, rsi             ; rdx = length of string
    syscall

    ; Exit program
    mov rax, 60              ; syscall: exit
    xor rdi, rdi             ; exit code 0
    syscall
