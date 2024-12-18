; uncluttering the main code a bit

; functions


write:
	; arg 1 = rsi buffer
	; arg 2 = rdx buffer size
	push rax
	push rdi
	mov rax, 1
	mov rdi, 1
	syscall
	pop rdi
	pop rax
	ret

fun_print:
	; add newline to the buffer
	inc r9
	mov al, 10 ; newline char
	mov [print_buffer+r9], al
	lea rsi, [print_buffer]
	mov rdx, print_buffer_size
	call write
	ret


; exit statements


exit_no_file:
	lea rsi, [no_file]
	mov rdx, no_file_len
	call write
	jmp exit

exit_bad_file:
	lea rsi, [bad_file]
	mov rdx, bad_file_len
	call write
	jmp exit

exit_read_fail:
	lea rsi, [read_fail]
	mov rdx, read_fail_len
	call write
	jmp exit

exit_empty_file:
	lea rsi, [empty_file]
	mov rdx, empty_file_len
	call write
	jmp exit

exit_wrong_ins:
	lea rsi, [wrong_ins]
	mov rdx, wrong_ins_len
	call write
	jmp exit

exit_print_paran:
	lea rsi, [print_paran]
	mov rdx, print_paran_len
	call write
	jmp exit

exit_print_paran2:
	lea rsi, [print_paran2]
	mov rdx, print_paran2_len
	call write
	jmp exit

exit_print_paran3:
	lea rsi, [print_paran3]
	mov rdx, print_paran3_len
	call write
	jmp exit

exit_declaration_fail:
	lea rsi, [declaration_fail]
	mov rdx, declaration_fail_len
	call write
	jmp exit

something_else:
	lea rsi, [undefined]
	mov rdx, undefined_len
	call write

exit:
	mov rax, 60
	xor rdi, rdi
	syscall


; data


section .bss
	file_buffer resb 4096
	token_buffer resb 64
	print_buffer resb 64
	variable_buffer resb 64
    file_descriptor resb 1

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
