section	.text
;function declarations
global	print
global	strlen
global	println
global	putchar

strlen:
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

print:
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

putchar:
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

println:
	mov	eax, [esp+4]
	push	eax
	call	print
	pop	eax
	mov	eax, 0ah
	push	eax
	call	putchar
	pop	eax
	ret
