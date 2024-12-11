section .text
global _start

_start:
	; open the file
	mov rax, 2
	mov rdi, [rsp + 16]
	test rdi, rdi
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
	lea r9, [token_buffer]
	lea r10, [py_print]
compare_token_loop:
	mov al, byte [r9]
	mov r15b, byte [r10]

	; if there is an instruction or variable
	; named the same but more characters at
	; the end this will not fail, because
	; it checks until the end of the
	; token_buffer, not the instruction buffer
	cmp al, 0
	jz Lpy_print

	inc r9
	inc r10

	cmp al, r15b
	jz compare_token_loop
	jnz exit_wrong_ins

jmp exit

Lpy_print:
	; takes r9 as token_buffer

	; test for parantheses()
	inc r9
	mov al, byte [r9]
	mov bl, "("
	cmp al, bl
	jnz exit_print_paran
	
	; test if "string" or not
Lpy_print_compare1:
	inc r9
	mov al, byte [r9]
	cmp al, 34 ; "
	jne Lpy_print_compare2
	call string_to_print_buffer
Lpy_print_compare2:
	cmp al, 39 ; '
	jne something_else
	call string_to_print_buffer

string_to_print_buffer:
	; should push values onto stack
	; theoretically
	; r9 contains token_buffer
	; read string and put in print_buffer
	inc r9
	cmp byte [r9], 34 ; "
	je Lret
	cmp byte [r9], 39 ; '
	je Lret
	mov byte [r9], [print_buffer]
	

Lret:
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

exit_print_paran:
	mov rax, 1
	mov rdi, 1
	lea rsi, [print_paran]
	mov rdx, print_paran_len
	syscall

something_else:
exit:
	mov rax, 60
	xor rdi, rdi
	syscall


section .bss
	file_buffer resb 4096
	token_buffer resb 64
	print_buffer resb 64

section .data
	file_buffer_size equ 4096
	token_buffer_size equ 64
	print_buffer_size equ 64

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

	py_print db "print", 0
	py_print_len equ $ - py_print

	print_paran db "You forgot the (.", 10
	print_paran_len equ $ - print_paran
