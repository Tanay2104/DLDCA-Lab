; Caller Registers: rdi, rsi, rdx, rcx, r8, r9, r10, r11
; Callee Registers: rbp, rsp, rbx, r12, r13, r14, r15
section .data
    shifted_disk db "Shifted disk "
    from_str db " from "
    to_str db " to "
    a_rod db 'A'
    b_rod db 'B'
    c_rod db 'C'
    newline db 10
    shifted_len equ 13
    from_len equ 6
    to_len equ 4
    buffer db 100 dup(0) ; Output buffer for result string

section .bss
    input_buf resb 20  ; Reserve 20 bytes for input
    num resq 1         ; 64-bit integer

section .text
    global printNum
    global hanoi
    global _start 
    global printFromAndTo

printNum:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to print an arbitary number stored in rax
	; We will first push the callee saved registers
	push rbp
	push rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	; We now need to convert the integer stored in rax to string.	
	mov r12, 19 ; Number has 64 bits which translates to max 20 characters
	mov r13, buffer ; Address of output buffer
	
	cmp rax, 0 ; We compare the number to 0 and repeatedly divide by 10 to convert to str
	jne .printNumLoop
	jmp .printEnd
.printNumLoop:
	mov rax, rax ; rax contains the number to be divides
	xor rdx, rdx ; Clearing rdx
	mov rcx, 10 ; Divisor is 10
	div rcx 
	; rax contains quotient rax = rax / 10
	; rdx contains remainder rdx = rax % 10
	add rdx, '0'; Converting the last digit of old rax to character
	mov [r12 + r13], dl ; Move only lower 8 bytes of rdx so that previous values are not overwritten
	
	sub r12, 1 ; Decrementing Counter for addressing
	
	; value of rax has already been divided by 10 for next loop
	 
	cmp rax, 0
	jne .printNumLoop

	; Now we execute the write syscall
	mov rax, 1 ; Syscall number for write
	mov rdi, 1 ; Syscall write to standard out
	mov rsi, buffer ;  Moving the output buffer
	mov rdx, 64 ; Number of digits in number
	syscall 
	

	; Now we restore the callee saved registers
.printEnd:
	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rsp
	pop rbp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printFromAndTo:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to print " from " *rax " to " *rdi

	push rbp
	push rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r12, rax
	mov r13, rdi	

	mov rax, 1
	mov rdi, 1
	mov rsi, from_str
	mov rdx, from_len
	syscall
	
	
	mov rax, 1
	mov rdi, 1
	mov rsi, r12
	mov rdx, 1 ; Length of 'A' or 'B' or 'C' is 1
	syscall
	
	mov rax, 1
	mov rdi, 1
	mov rsi, to_str
	mov rdx, to_len
	syscall

	mov rax, 1
	mov rdi, 1
	mov rsi, r13
	mov rdx, 1
	syscall


	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rsp
	pop rbp 
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hanoi:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; C code for function
;;;; void hanoi(int n, char from, char to, char aux) {
;;;;     if (n == 1) {
;;;;         printf("Shifted disk 1 from %c to %c\n", from, to);
;;;;         return;
;;;;     }
;;;;     hanoi(n - 1, from, aux, to);
;;;;     printf("Shifted disk %d from %c to %c\n", n, from, to);
;;;;     hanoi(n - 1, aux, to, from);
;;;; }
	push rbp
	push rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	; rdi contains n, rsi contains from peg, rdx contains to peg, rcx contains aux peg
	
	cmp rdi, 1
	je .printHanoi

 	; We will now recursively call hanoi	
	; Temporarily storing from, aux, to
	mov r12, rsi ; From peg
	mov r13, rdx ; To peg
	mov r14, rcx ; Aux peg

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10
	push r11

	sub rdi, 1 ; n--
	mov rsi, r12 ; New from = old from
	mov rdx, r14 ; New to = old aux
	mov rcx, r13 ; New aux = old to
	call hanoi	

	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi	

	jmp .printHanoi

.printHanoi:

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10
	push r11

	; We first print shifted disk
	mov rax, 1 ;  Syscall number for write
	mov rdi, 1 ;  Write to standard out
	mov rsi, shifted_disk 
	mov rdx, shifted_len
	syscall

	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi

	mov rax, rdi ; Storing the value of rdi in rax as we need it
	
	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10
	push r11

	call printNum ; This prints the number in rax
	
	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	;  pop rdi

	; Now we need to call printFromAndTo. However, this number accepts from in [rax].
	; and to in [rdi]. This means we will have to store and later retrieve our rax value
	mov rax, rsi ; rsi contained from peg
	mov rdi, rdx ; rdx contained to peg. 
	; It is caller's responsibilty to restore rsi, rdx, rdi

	; push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10
	push r11
	
	call printFromAndTo
	
	; Now we print newline
	mov rax, 1
	mov rdi, 1
	mov rsi, newline
	mov rdx, 1
	syscall

	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	cmp rdi, 1
	je .endHanoi


 ; The second recursive call
	mov r12, rsi ; From peg
	mov r13, rdx ; To peg
	mov r14, rcx ; Aux peg

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10
	push r11

	sub rdi, 1
	mov rsi, r14 ; New from = old aux
	mov rdx, r13 ; New to = old to
	mov rcx, r12 ; New aux = old from
	call hanoi	

	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi	

.endHanoi:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rsp
	pop rbp 
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to take in number as input, then call hanoi(num, 'A','B','C')
	mov rax, 0 ; Syscall number for read
	mov rdi, 0 ; 
	mov rsi, input_buf
	mov rdx, 20 ; 20 byte input maximum
	syscall

; Now we need to convert the character array of input_buf to an integer stored in rax
	mov r8, input_buf ; r8 contains address of input_buf
	mov r9, rax ; Max number of digits in the number
	sub r9, 1
	xor r10, r10 ; Our counter register
	xor rax, rax ; Clear rax
	cmp r9, 0 
	jne .startConvertToInt

.startConvertToInt:
	mov bl, [r8 + r10] ; Moving the 8 bytes following [r8 + r9] into bl
	sub bl, '0'
	imul rax, 10
	movzx rbx, bl ;  Since bl is 8 bit we can't directly add it to rax
	add rax, rbx 

	sub r9, 1 ;  Decrementing r9
	add r10, 1 
	cmp r9, 0
	jne .startConvertToInt

; Now rax contains our 64 bit integer
	mov [num], rax
; We now call hanoi, after taking care of caller saved registers

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push r10

	mov rdi, rax ; First argument of hanoi is num
	mov rsi, a_rod ; Second arguement is A, the from peg
	mov rdx, b_rod ;  Third arguement is B, the to peg
	mov rcx, c_rod ; Fourth arguement is C, the auxilliary peg
	call hanoi ; Calling the hanoi function

	pop r11
	pop r10
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall
