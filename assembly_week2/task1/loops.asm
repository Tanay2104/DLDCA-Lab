section .data
    buffer  db 20 dup(0)     ; Output buffer for result string

section .bss
    input_buf resb 20  ; Reserve 20 bytes for input
    num     resq 1     ; 64-bit integer

section .text
    global _start ; essentially just means start here


_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Take in number as input from user
    ; You can do this using read(0, input_buffer, size) syscall, syscall number for read is 0
    ; Make sure your input buffer is stored in rsi :)
    mov rax, 0
    mov rdx, num
    mov rdi, 0 
    mov rsi, input_buf
    syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; The below code simply converts input string to a number, don't worry about it
    mov rsi, input_buf  ; rsi points to buffer
    xor rax, rax        ; accumulator = 0

.convert1:
    movzx rcx, byte [rsi] ; load byte
    cmp rcx, 10           ; check for newline
    je .done1
    sub rcx, '0'          ; convert ASCII to digit
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .convert1

.done1:
    ; Now RAX contains the number entered

    ; Implement following C code:
    ; int a = 0;
    ; int b = 1;
    ; for (int i=0; i < n; i++) {
    ;     int c = a + b;
    ;     a = b;
    ;     b = c;
    ; }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov rbx, 0 ; a
	mov rcx, 1 ; b
	mov rdx, 0 ; i
	cmp rdx, rax
	jl .forBegin
.forBegin:
	; Computing c
	mov r8, 0
	add r8, rbx
	add r8, rcx
	
	; a = b, b = c
	mov rbx, rcx
	mov rcx, r8
	
	; Incrementing i 
	inc rdx
	
	; Comparing i < n, looping if true 
	cmp rdx, rax
	jl .forBegin
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Print the result
    ; C code is:
    ; i = 19
    ; while (a > 0) {
    ;   buff[i] = a % 10 + '0'; Note you must access only the lower 8 bits of your register storing a here :) for example, for rdx, lower 8 bits are stored in dl
    ;   a /= 10;
    ;   i--;
    ; }
    ; write(1, buff + i + 1, 19 - i); 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov r8, 19; i = 19
	mov r9, buffer
	cmp rbx, 0 ; a > 0
	jne .forBegin2 
.forBegin2:
	mov rax, rbx ; Move lower 8 bits a into rax for division, earlier n was in rax, don't care now
	xor rdx, rdx ; Clear rdx
	mov rcx, 10 ; Divisor = 10
	div rcx
	
	; rax contains quotient
	; rdx contains remainder a % 10
	
	add rdx, '0' 
	mov  [r9 + r8], dl
	
	; Doing a/=10
	mov rax, rbx ; Move a to rax
	xor rdx, rdx; Clear rdx
	mov rcx, 10 ; Divisor = 10
	div rcx ; rax holds quotient a/10
	
	mov rbx, rax; Updating a to a%10
	; i = i - 1;
	sub r8, 1;
	
	; Loopinf if a > 0
	cmp rbx, 0
	jne .forBegin2

; Performing write syscall
	mov rax, 1 ;  Write syscall number
	mov rdi, 1 ; Syscall cout
	mov r9, buffer
	add r9, r8
	add r9, 1 ; r9 = buffer + i + 1
	mov rsi, r9 ; Moving buffer to rsi

	xor r9, r9 ; clear r9 for safety	
	mov r9, 19
	sub r9, r8
	mov rdx, r9 ; Max 20 bit output
	syscall 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov rax, 60              ; syscall: exit
    xor rdi, rdi             ; exit code 0
    syscall
