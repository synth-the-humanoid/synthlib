section	.data
filename: db "testfile", 0
text: db "Hello, World!", 0ah, 0


O_RDONLY: equ 0 		;constant for read
O_WRONLY: equ 1			;constant for write
S_IRUSR: equ 256		;constant for file I/O
S_IWUSR: equ 128		;constant for file I/O

section	.text
global	_start
	_start:
	;throw stuff here to play with the library
	;you can delete everything in here without worry
	mov	eax, text
	mov	ebx, filename
	call	write
	call	exit

	;functions
	strlen: ; takes string in eax, returns length in eax
	push	ebx
	mov	ebx, eax
	.loop:
	cmp	byte [ebx], 0
	jz	.clean
	inc	ebx
	jmp	.loop
	.clean:
	sub	ebx, eax
	mov	eax, ebx
	pop	ebx	
	ret

	print: ; prints string in eax, no newline
	push	edx
	push	ecx
	push	ebx
	push	eax
	mov	ecx, eax
	mov	ebx, 1
	call	strlen
	mov	edx, eax
	mov	eax, 4
	int	80h
	pop	eax
	pop	ebx
	pop	ecx
	pop	edx
	ret

	exit: ; clean program exit
	mov	ebx, eax
	mov	eax, 1
	int	80h


	putchar: ; puts character referred to by eax
	push	eax
	mov	eax, esp
	call	print
	pop	eax
	ret

	println: ; print with newline
	call	print
	push	eax
	mov	eax, 0ah
	call	putchar
	pop	eax
	ret

	inputb: ; takes user input from stdin and stores it at [eax], ebx is buffersize
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	edx, ebx
	dec	edx
	mov	ecx, eax
	push	ebx
	mov	ebx, 0
	mov	eax, 3
	int	80h
	pop	ebx
	mov	byte [ecx + ebx], 0
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

	strcmp: ; compares string at [eax] and [ebx], sets eax to 1 if equal, 0 otherwise
	push	ebx
	push	ecx
	push	edx
	.loop:
	mov	cl, byte [eax]
	mov	dl, byte [ebx]
	cmp	dl, cl
	jne	.false
	cmp	dl, 0
	jz	.true
	inc	eax
	inc	ebx
	jmp	.loop
	.false:
	mov	eax, 0
	jmp	.end
	.true:
	mov	eax, 1
	.end:
	pop	edx
	pop	ecx
	pop	ebx
	ret

	strcpy: ; copy the string in [eax] to [ebx], checks for null byte to end
	push	eax
	push	ebx
	push	ecx
	.loop:
	cmp	byte [eax], 0
	jz	.end
	mov	cl, byte [eax]
	mov	byte [ebx], cl
	inc	eax
	inc	ebx
	jmp	.loop
	.end:
	pop	ecx
	pop	ebx
	pop	eax
	ret

	memcpy: ; copies ecx bytes from [eax] to [ebx]
	push	eax
	push	ebx
	push	ecx
	push	edx
	.loop:
	cmp	ecx, 0
	jz	.end
	mov	dl, byte [eax]
	mov	byte [ebx], dl
	inc	eax
	inc	ebx
	dec	ecx
	jmp	.loop
	.end:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

	memzero: ;clears ebx bytes from [eax]
	push	eax
	push	ebx
	.loop:
	cmp	ebx, 0
	jz	.end
	mov	byte [eax], 0
	dec	ebx
	inc	eax
	jmp	.loop
	.end:
	pop	ebx
	pop	eax
	ret

	strcat: ;concatenate strings
	push	eax
	.loop:
	cmp	byte [eax], 0
	jz	.eloop
	inc	eax
	jmp	.loop
	.eloop:
	push	ebx
	mov	ebx, eax
	pop	eax
	call	strcpy
	pop	eax
	ret
	

	sleep: ;sleep for <eax> seconds
	push	eax
	push	ebx
	push	ecx
	push	eax
	mov	ebx, esp
	xor	ecx, ecx
	push	ecx
	mov	ecx, esp
	mov	eax, 162
	int	80h
	pop	eax
	pop	eax
	pop	ecx
	pop	ebx
	pop	eax
	ret



	read: ; read <ebx> bytes from file at <eax>, store in <ecx>
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	ebx
	mov	ebx, O_RDONLY
	call	_open
	pop	ebx
	mov	edx, ebx
	mov	ebx, eax
	mov	eax, 3
	int	80h
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

	write: ; write <eax> to file at <ebx>
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	eax
	push	ebx
	push	ecx
	mov	ecx, S_IRUSR
	or	ecx, S_IWUSR
	mov	eax, 8
	int	80h
	pop	ecx
	pop	ebx
	pop	eax

	push	eax
	mov	eax, ebx
	mov	ebx, O_WRONLY
	call	_open
	mov	ebx, eax
	pop	eax
	push	eax
	call	strlen
	mov	edx, eax
	pop	ecx
	mov	eax, 4
	int	80h
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret


	_open: ; open file at <eax> in mode specified by <ebx> -- use read or write instead
	push	ebx
	push	ecx
	push	edx
	mov	edx, S_IRUSR
	mov	ecx, ebx
	mov	ebx, eax
	mov	eax, 5
	int	80h
	pop	edx
	pop	ecx
	pop	ebx
	ret
