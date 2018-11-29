section	.data
buffersize: equ 64
str:	db "This string is here to showcase the library", 0 ; can be deleted
userin:	times buffersize db 0
prompt:	db "Type a string: ", 0
section	.text
global	_start
	_start:
	;throw stuff here to play with the library
	;you can delete everything in here without worry
	mov	eax, str
	call	println
	mov	eax, prompt
	call	print
	mov	eax, userin
	call	inputb
	push	eax
	mov	eax, 0ah
	call	putchar
	call	putchar
	pop	eax
	call	println

	
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

	inputb: ; takes user input from stdin and stores it at [eax]
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	edx, buffersize
	dec	edx
	mov	ecx, eax
	mov	ebx, 0
	mov	eax, 3
	int	80h
	mov	byte [ecx + buffersize], 0
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
