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
	mov al, byte [r9+r12]
	mov r15b, byte [r10+r12]

	cmp al, 0
	jz print

	inc r9
	inc r10

	cmp al, r15b
	jz compare_token_loop
	jnz exit_wrong_ins

jmp exit

Lpy_print:
	mov rax, 1
	mov rdi, 1
	lea rsi, [anakonda]
	mov rdx, anakonda_len
	syscall
	jmp exit


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

exit:
	mov rax, 60
	xor rdi, rdi
	syscall


section .bss
	file_buffer resb 4096
	token_buffer resb 64

section .data
	file_buffer_size equ 4096

	token_buffer_size equ 64

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
