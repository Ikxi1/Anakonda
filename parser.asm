section .text
global _start

_start:
	; open the file
	mov rax, 2
	mov rdi, [rsp + 16]
	test rdi, rdi
	js exit_no_file
	cmp rdi, 0
	jz exit_no_file
	mov rsi, 0
	mov rdx, 0
	syscall
	test rax, rax
	js exit_bad_file

	mov rdi, rax
	mov r10, rax

	; read file into file_buffer
	xor rax, rax
	lea rsi, [file_buffer]
	mov rdx, file_buffer_size
	syscall
	test rax, rax
	js exit_read_fail
	cmp rax, 0
	jz exit_empty_file
	mov r8, rax
	xor r9, r9


; read file piece by piece


read_file_buffer:
	cmp r8, 0
	jz compare_token

	mov al, [file_buffer+r9]
	cmp al, "a"
	jl compare_token
	cmp al, "z"
	jg compare_token

	mov [token_buffer+r9], al

	inc r9
	dec r8
	jmp read_file_buffer

compare_token:
	lea r14, [token_buffer]
	lea r10, [py_print]
compare_token_loop:
	mov al, byte [r14]
	mov r15b, byte [r10]

	; if there is an instruction or variable
	; named the same but more characters at
	; the end this will not fail, because
	; it checks until the end of the
	; token_buffer, not the instruction buffer
	cmp al, 0
	jne compare_token_loop2
	call Lpy_print

	jmp exit

compare_token_loop2:
	inc r14
	inc r10

	cmp al, r15b
	jz compare_token_loop

compare_token_declaration:
	; check if it's a variable or function declarations
	; ERROR TOKEN_BUFFER ONLY GOES UP TO lowercase letters
	; ANY OTHER SYMBOL IS NOT IN TOKEN_BUFFER
	lea r14, [token_buffer]
compare_token_declaration_loop:
	cmp byte [r14], 61 ; =
	jz declare_variable
	cmp byte [r14], 40 ; (
	jz declare_function
	inc r14
	jmp compare_token_declaration_loop

declare_variable:
	inc r14
	cmp byte [r14], 61 ; =
	jnz exit_declaration_fail
	inc r14
	cmp byte [r14], 40 ; space " "
	jnz exit_declaration_fail
	xor r13, r13
declare_variable_load:
	inc r14
	mov al, byte [r14]
	cmp al, 34 ; "x
	mov [variable_buffer+r13], al




declare_function:
	jmp exit


Lpy_print:
	; takes r9 as file_buffer

	; test for parantheses()
	cmp byte [file_buffer+r9], 40 ; (
	jnz exit_print_paran
	
	; test if "string" or not
Lpy_print_compare1:
	inc r9
	cmp byte [file_buffer+r9], 34 ; "
	jne Lpy_print_compare2 ; instead of jumping to check )
	; it needs to read a variable or function
	call Lpy_print_buffer
Lpy_print_compare2:
	inc r9
	cmp byte [file_buffer+r9], 41 ; )
	jne exit_print_paran3

	call fun_print

	ret

Lpy_print_buffer:
	; should push values onto stack
	; theoretically
	; r9 contains token_buffer
	; read string and put in print_buffer
	xor r15, r15
Lpy_print_buffer_loop:
	inc r9
	cmp byte [file_buffer+r9], 41 ; )
	je exit_print_paran2
	cmp byte [file_buffer+r9], 34 ; "
	je Lret
	cmp byte [file_buffer+r9], 39 ; '
	je Lret
	mov al, byte [file_buffer+r9]
	mov [print_buffer+r15], al

	je exit_print_paran2
	cmp byte [file_buffer+r9], 34 ; "
	je Lret
	cmp byte [file_buffer+r9], 39 ; '
	je Lret
	mov al, byte [file_buffer+r9]
	mov [print_buffer+r15], al
	inc r15
	jmp Lpy_print_buffer_loop

Lret:
	ret

; all the different in-built functions


fun_print:
	; add newline to the buffer
	inc r9
	mov al, 10
	mov [print_buffer+r9], al
	mov rax, 1
	mov rdi, 1
	lea rsi, [print_buffer]
	mov rdx, print_buffer_size
	syscall
	ret


; all the different exits


exit_no_file:
	mov rax, 1
	mov rdi, 1
	lea rsi, [no_file]
	mov rdx, no_file_len
	syscall
	jmp exit

exit_bad_file:
	mov rax, 1
	mov rdi, 1
	lea rsi, [bad_file]
	mov rdx, bad_file_len
	syscall
	jmp exit

exit_read_fail:
	mov rax, 1
	mov rdi, 1
	lea rsi, [read_fail]
	mov rdx, read_fail_len
	syscall
	jmp exit

exit_empty_file:
	mov rax, 1
	mov rdi, 1
	lea rsi, [empty_file]
	mov rdx, empty_file_len
	syscall
	jmp exit

exit_wrong_ins:
	mov rax, 1
	mov rdi, 1
	lea rsi, [wrong_ins]
	mov rdx, wrong_ins_len
	syscall
	jmp exit

exit_print_paran:
	mov rax, 1
	mov rdi, 1
	lea rsi, [print_paran]
	mov rdx, print_paran_len
	syscall
	jmp exit

exit_print_paran2:
	mov rax, 1
	mov rdi, 1
	lea rsi, [print_paran2]
	mov rdx, print_paran2_len
	syscall
	jmp exit

exit_print_paran3:
	mov rax, 1
	mov rdi, 1
	lea rsi, [print_paran3]
	mov rdx, print_paran3_len
	syscall
	jmp exit

exit_declaration_fail:
	mov rax, 1
	mov rdi, 1
	lea rsi, [declaration_fail]
	mov rdx, declaration_fail_len

something_else:
	mov rax, 1
	mov rdi, 1
	lea rsi, [undefined]
	mov rdx, undefined_len
	syscall

exit:
	mov rax, 60
	xor rdi, rdi
	syscall


section .bss
	file_buffer resb 4096
	token_buffer resb 64
	print_buffer resb 64
	variable_buffer resb 64

section .data
	file_buffer_size equ 4096
	token_buffer_size equ 64
	print_buffer_size equ 64
	variable_buffer_size equ 64

	anakonda db "Anakonda", 10
	anakonda_len equ $ - anakonda

	no_file db "Specify a file as the first argument.", 10
	no_file_len equ $ - no_file

	bad_file db "Couldn't open the file.", 10
	bad_file_len equ $ - bad_file

	read_fail db "Couldn't read the file.", 10
	read_fail_len equ $ - read_fail

	empty_file db "The specified file is empty.", 10
	empty_file_len equ $ - empty_file

	wrong_ins db "Recognized unrecognized instruction.", 10
	wrong_ins_len equ $ - wrong_ins

	undefined db "Undefined error", 10
	undefined_len equ $ - undefined

	py_print db "print", 0
	py_print_len equ $ - py_print

	print_paran db "You forgot the (.", 10
	print_paran_len equ $ - print_paran

	print_paran2 db "You forgot the quotes before the ).", 10
	print_paran2_len equ $ - print_paran2

	print_paran3 db "You forgot the ).", 10
	print_paran3_len equ $ - print_paran3

	declaration_fail db "Failed to declare variable or function.", 10
	declaration_fail_len equ $ - declaration_fail

	debut db "debut", 0
	debut_len equ $ - debut

	graduate db "graduate", 0
	graduate_len equ $ - graduate
