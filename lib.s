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

strlen:		; int strlen(char*) ;; returns length of string(without term byte)
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

print: ; void print(char *) ;; prints char * to stdout
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

putchar: ; void putchar(char) ;; prints a single character to stdout
	mov	eax, [esp+4]
	push	edx
	push	ecx
	push	ebx
	push	eax
	mov	eax, esp
	mov	edx, 1
	mov	ecx, eax
	mov	ebx, 1
	mov	eax, 4
	int	80h
	pop	eax
	pop	ebx
	pop	ecx
	pop	edx
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

getchar: ; char getchar() ;; gets one byte from stdin
	push	ebx
	push	ecx
	push	edx
	push	eax
	mov	edx, 1
	mov	ecx, esp
	mov	ebx, 0
	mov	eax, 3
	int	80h
	pop	eax
	pop	edx
	pop	ecx
	pop	ebx
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
