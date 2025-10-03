; save this as write.asm
section .data
    msg db "Hello", 10     ; "Hello\n"
    len equ $ - msg

section .text
    global _start

_start:
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; fd: stdout
    mov rsi, msg        ; buf: pointer to msg
    mov rdx, len        ; count: length
    syscall             ; perform syscall

    ; Exit
    mov rax, 60         ; syscall: exit
    xor rdi, rdi
    syscall
