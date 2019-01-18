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

strlen:		; int strlen(char *string) ;; returns length of string(without term byte)
	mov	eax, [esp+4]
	push	ebx
	mov	ebx, eax
	.loop:
	cmp	byte[ebx], 0
	jz	.cleanup
	inc	ebx
	jmp	.loop
	.cleanup:
	sub	ebx, eax
	mov	eax, ebx
	pop	ebx
	ret

print: ; void print(char *string) ;; prints string to stdout
	mov	eax, [esp+4]
	push	edx
	push	ecx
	push	ebx
	push	eax
	call	strlen
	mov	edx, eax
	pop	ecx
	mov	ebx, 1
	mov	eax, 4
	int	80h
	pop	ebx
	pop	ecx
	pop	edx
	ret

putchar: ; void putchar(char) ;; prints a char to stdout
	mov	eax, [esp+4]
	mov	ecx, stdout
	push	ecx
	push	eax
	call	putc
	pop	eax
	pop	ecx
	ret

putc: ; void putc(char, FILE *stream) ;; prints char to stream
	mov	eax, [esp+4]
	mov	ecx, [esp+8]
	push	ebx
	push	eax
	mov	edx, 1
	mov	ebx, ecx
	mov	ecx, esp
	mov	eax, 4
	int	80h
	pop	eax
	pop	ebx
	ret



println: ; void println(char *string) ;; print string with newline
	mov	eax, [esp+4]
	push	eax
	call	print
	pop	eax
	mov	eax, 0ah
	push	eax
	call	putchar
	pop	eax
	ret

strcmp: ; int strcmp(char *str1, char *str2) ;; compares str1 and str2, returning either a negative, zero, or positive depending on if the result is less than, equal to, or greater than(in that order)
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

sleep: ; void sleep(int time) ;; sleeps for time seconds
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

exp: ; long exp(int base, int power) ;; raises base to power
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


strcpy: ; void strcpy(char *src, char *dest, int buffer) ;; copies from src to dest, using buffer to prevent overflow
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



error: ; called in-case of library error -- unused as of Jan. 18, 2019
	mov	eax, 1
	xor	ebx, ebx
	dec	ebx
	int	80h

inputb: ; void inputb(char *string, int buffersize) ;; input from stdin into string. cuts off at buffersize bytes
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



finputb: ; void inputb(char *string, int buffersize, FILE *stream) ;; input from stream into string. cuts off at buffersize bytes
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


atoi: ; signed long atoi(char *string) ;; converts string into a signed long integer
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


strzero: ; void strzero(char *string) ;; convert all the bytes in string into zeroes
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


memzero: ; void memzero(void *memory, int length) ;; overwrite (length) bytes of data, starting at memory, ending at (memory + length - 1), with zeroes
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
