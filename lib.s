section	.data
stdin:	equ 0
stdout:	equ 1
stderr:	equ 2

section	.text

;function declarations
global	print
global	strlen
global	println
global	putchar
global	inputb
global	strcmp
global	getchar
global	sleep
global	exp
global	strcpy
global	getc
global	putc
global	strcpy
global	atoi
global	itoa
global	strzero
global	memzero
global	memcpy

strlen:		; int strlen(char *string) ;; returns length of string(without term byte)
	mov	eax, [esp+4] ; rax refers to string
	push	ebx ; save nonvolatile register
	mov	ebx, eax ; rax and rbx refer to string
	.loop: ; loop until the terminating byte
	cmp	byte[ebx], 0 ; check for term. byte
	jz	.cleanup ; if end of string, end loop
	inc	ebx ; otherwise, increment rbx
	jmp	.loop ; loop
	.cleanup: ; calculate distance between rax and rbx
	sub	ebx, eax ; get distance
	mov	eax, ebx ; move distance to rax(return value)
	pop	ebx ; fix volatile register
	ret

print: ; void print(char *string) ;; prints string to stdout
	mov	eax, [esp+4] ; rax refers to string
	push	ebx ; save volatile register
	push	eax ; push argument to strlen
	call	strlen ; get length of string, return to eax
	mov	edx, eax ; prepare syscall, rdx refers to how many bytes to print
	pop	ecx ; take the string, which is on the stack, and store it in rcx
	mov	ebx, stdout ; tell syscall to output to stdout
	mov	eax, 4 ; specify syscall 4(write)
	int	80h ; execute syscall
	pop	ebx ; restore nonvolatile register
	ret

putchar: ; void putchar(char character) ;; prints a single character to stdout
	mov	eax, [esp+4] ; rax refers to character
	mov	ecx, stdout ; rcx refers to stdout
	push	ecx ; push argument to function
	push	eax ; push argument to function
	call	putc ; putc(character, stdout)
	pop	eax ; clear stack
	pop	ecx ; clear stack
	ret

putc: ; void putc(char character, FILE *stream) ;; puts character to stream
	mov	eax, [esp+4] ; rax refers to character
	mov	ecx, [esp+8] ; rbx refers to stream
	push	ebx ; save nonvolatile register
	push	eax ; create character pointer for syscall
	mov	edx, 1 ; print 1 byte
	mov	ebx, ecx ; use stream for syscall
	mov	ecx, esp ; use pointer to character for syscall
	mov	eax, 4 ; specify syscall 4(write)
	int	80h ; execute syscall
	pop	eax ; clean stack 
	pop	ebx ; clean stack
	ret



println: ; void println(char *) ;; print with newline
	mov	eax, [esp+4]
	push	eax
	call	print
	pop	eax
	mov	eax, 0ah
	push	eax
	call	putchar
	pop	eax
	ret

strcmp: ; int strcmp(char *, char *) ;; compares two char *'s, returns 0 if true
	mov	eax, [esp+4]
	mov	edx, [esp+8]
	push	ebx
	push	ecx
	mov	ebx, eax
	mov	ecx, edx
	mov	eax, 0
	.loop:
	mov	byte dl, [ebx]
	mov	byte dh, [ecx]
	cmp	dl, dh
	jg	.add
	jl	.sub
	cmp	dl, 0
	jz	.end
	cmp	dh, 0
	jz	.end
	inc	ebx
	inc	ecx
	jmp	.loop
	.add:
	inc	eax
	inc	ebx
	inc	ecx
	jmp	.loop
	.sub:
	dec	eax
	inc	ebx
	inc	ecx
	jmp	.loop
	.end:
	pop	ecx
	pop	ebx
	ret

getc:	; char getc(FILE *stream); get one byte from stream
	mov	eax, [esp+4]
	push	ebx
	mov	ebx, eax
	push	eax
	mov	edx, 1
	mov	ecx, esp
	mov	eax, 3
	int	80h
	pop	eax
	pop	ebx
	ret
	

getchar: ; char getchar() ;; gets one byte from stdin
	mov	eax, stdin
	push	eax
	call	getc
	pop	ecx
	ret

sleep: ; void sleep(int) ;; sleeps for however many seconds the parameter specifies
	mov	eax, [esp+4]
	push	ebx
	push	ecx
	mov	ecx, 0
	mov	ebx, eax
	push	ecx
	mov	ecx, esp
	push	ebx
	mov	ebx, esp
	mov	eax, 162
	int	80h
	pop	ebx
	pop	ecx
	pop	ecx
	pop	ebx
	ret

exp: ; long exp(int, int) ;; raises first param to second param
	mov	eax, [esp+4]
	mov	edx, [esp+8]
	push	ebx
	mov	ebx, edx
	cmp	ebx, 0
	jz	.ret1
	dec	ebx
	.loop:
	cmp	ebx, 0
	jz	.clean
	imul	eax
	dec	ebx
	jmp	.loop
	.ret1:
	mov	eax, 1
	pop	ebx
	ret
	.clean:
	pop	ebx
	ret


memcpy: ; void memcpy(void *src, void *dest, int buffer) ;; copies from src to dest, using buffer to prevent overflow
	mov	eax, [esp+4]
	mov	edx, [esp+8]
	mov	ecx, [esp+12]
	push	esi
	push	edi
	mov	esi, eax
	mov	edi, edx
	cld
	rep	movsb
	pop	edi
	pop	esi
	ret



error: ; called in-case of library error
	mov	eax, 1
	xor	ebx, ebx
	dec	ebx
	int	80h

inputb: ; void inputb(char *, int) ;; buffered stdin input
	mov	eax, [esp+4]
	mov	ecx, [esp+8]
	mov	edx, stdin
	push	edx
	push	ecx
	push	eax
	call	finputb
	pop	eax
	pop	ecx
	pop	edx
	ret



finputb: ; void inputb(char *, int, FILE *) ;; buffered input from file
	mov	eax, [esp+4]
	mov	ecx, [esp+8]
	mov	edx, [esp+12]
	push	ebx
	mov	ebx, eax
	dec	ecx
	xor	eax, eax
	.loop:
	cmp	ecx, 0
	jz	.clean
	dec	ecx
	push	ecx
	push	edx
	call	getc
	pop	edx
	pop	ecx
	cmp	eax, 0ah
	je	.clean
	mov	byte [ebx], al
	inc	ebx
	jmp	.loop
	.clean:
	mov	byte [ebx], 0
	pop	ebx
	push	edx
	.cloop:
	cmp	eax, 0ah
	je	.end
	cmp	eax, 0
	jz	.end
	call	getc
	jmp	.cloop
	.end:
	pop	edx
	ret


atoi: ; signed long atoi(char *) ;; ascii to integer
	mov	ecx, [esp+4]
	xor	eax, eax
	xor	edx, edx
	.loop:
	cmp	byte [ecx], '0'
	jl	.nonint
	cmp	byte [ecx], '9'
	jg	.nonint
	mov	dl, [ecx]
	sub	edx, '0'
	imul	eax, 10
	add	eax, edx
	inc	ecx
	jmp	.loop
	.nonint:
	cmp	eax, 0
	jz	.error
	ret
	.error:
	xor	eax, eax
	dec	eax
	ret


strzero: ; void strzero(char *) ;; nullify a string
	mov	eax, [esp+4]
	push	eax
	call	strlen
	mov	edx, eax
	pop	eax
	push	edx
	push	eax
	call	memzero
	pop	eax
	pop	edx
	ret


memzero: ; void memzero(void *, int length) ;; overwrite (length) bytes with zero
	mov	eax, [esp+4]
	mov	ecx, [esp+8]
	.loop:
	cmp	ecx, 0
	jz	.clean
	mov	byte [eax], 0
	inc	eax
	dec	ecx
	jmp	.loop
	.clean:
	ret

strcpy: ; void strcpy(void *src, void *dst, int length) ;; copies length bytes from src to dst.
	mov	eax, [esp+4]
	mov	ecx, [esp+8]
	mov	edx, [esp+12]
	push	edx
	push	ecx
	push	eax
	call	memcpy
	pop	eax
	pop	ecx
	pop	edx
	ret
