section	.data
stdin:	equ 0
stdout:	equ 1
stderr:	equ 2
S_IRUSR: equ 256
S_IWUSR: equ 128
O_RDONLY: equ 0
O_WRONLY: equ 1

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
global	open
global	read

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



println: ; void println(char *string) ;; print with newline
	mov	eax, [esp+4] ; rax refers to string
	push	eax ; print(string);
	call	print ; call print
	pop	eax ; clean the stack
	mov	eax, 0ah ; rax refers to '\n'
	push	eax ; putchar('\n');
	call	putchar ; call putchar
	pop	eax ; clean stack
	ret

strcmp: ; int strcmp(char *s1, char *s2) ;; compares two char *'s, returns 0 if true
	mov	eax, [esp+4] ; puts s1 in rax
	mov	edx, [esp+8] ; puts s2 in rdx
	push	ebx ; save nonvolatile register 
	mov	ebx, eax ; move s1 to rbx
	mov	ecx, edx ; mov s2 to rcx
	mov	eax, 0 ; set the counter to 0 
	.loop: ; while neither are at terminating byte
	mov	byte dl, [ebx] ; load s1[eax] into dl
	mov	byte dh, [ecx] ; load s2[eax] into dh
	cmp	dl, dh ; compare the two bytes
	jg	.add ; if s1[eax] > s2[eax], add to the value
	jl	.sub ; if s1[eax] > s2[eax], subtract from the value
	cmp	dl, 0 ; check for terminating byte
	jz	.end ; if so, end the function
	cmp	dh, 0 ; check for terminating byte
	jz	.end ; if so, end the function
	inc	ebx ; increment the byte selected in rbx
	inc	ecx ; increment the byte selected in rcx
	jmp	.loop ; loop again
	.add:
	inc	eax ; increment return value
	inc	ebx ; increment the byte selected in rbx
	inc	ecx ; increment the byte selected in rcx
	jmp	.loop ; loop again
	.sub:
	dec	eax ; subtract return value
	inc	ebx ; increment the byte selected in rbx
	inc	ecx ; increment the byte selected in rcx
	jmp	.loop ; loop again
	.end:
	pop	ebx ; clean the stack
	ret

getc:	; char getc(FILE *stream); get one byte from stream
	mov	eax, [esp+4] ; move stream in rax
	push	ebx ; save nonvolatile register
	mov	ebx, eax ; move stream into rbx for syscall
	push	eax ; push rax to create a character pointer
	mov	edx, 1 ; specify to read one byte when syscall executes
	mov	ecx, esp ; select the character pointer to store the value in
	mov	eax, 3 ; select read() syscall
	int	80h ; execute syscall
	pop	eax ; clean stack, set the return value
	pop	ebx ; clean stack
	ret
	

getchar: ; char getchar() ;; gets one byte from stdin
	mov	eax, stdin ; move stdin into rax
	push	eax ; use stdin as a parameter for getc()
	call	getc ; getc(stdin)
	pop	ecx ; clean up the stack
	ret

sleep: ; void sleep(int seconds) ;; sleeps for however many seconds the parameter specifies
	mov	eax, [esp+4] ; move rax to seconds
	push	ebx ; save nonvolatile register
	mov	ecx, 0 ; set nanoseconds to 0
	mov	ebx, eax ; move seconds into rbx
	push	ecx ; create pointer for nanoseconds
	mov	ecx, esp ; load that pointer into rcx
	push	ebx ; create pointer for seconds
	mov	ebx, esp ; load that pointer into rbx
	mov	eax, 162 ; select syscall -- sleep()
	int	80h ; execute syscall
	pop	ebx ; restore stack
	pop	ecx ; restore stack
	pop	ebx ; restore stack
	ret

exp: ; long exp(int base, int power) ;; raises first param to second param
	mov	eax, [esp+4] ; move base into rax 
	mov	edx, [esp+8] ; move power into rdx
	push	ebx ; save nonvolatile register
	mov	ebx, edx ; move power into rbx
	cmp	ebx, 0 ; if power is 0, return 1
	jz	.ret1 
	dec	ebx ; lower power by one to set counter
	.loop:
	cmp	ebx, 0 ; while power(a decrementing counter) isn't 0 or less
	jz	.clean ; if the power is at zero naturally, return the value
	jl	.ret1 ; if the power is negative, return 1
	imul	eax ; multiply rax by itself
	dec	ebx ; lower the counter
	jmp	.loop ; do the loop again
	.ret1:
	mov	eax, 1 ; set return value to 1
	pop	ebx ; clean stack
	ret
	.clean:
	pop	ebx ; clean stack
	ret


memcpy: ; void memcpy(void *src, void *dest, int buffer) ;; copies from src to dest, using buffer to prevent overflow
	mov	eax, [esp+4] ; move src into rax
	mov	edx, [esp+8] ; move dest into rdx
	mov	ecx, [esp+12] ; move buffer into rcx
	push	esi ; save nonvolatile register
	push	edi ; save nonvolatile register
	mov	esi, eax ; move src into source index
	mov	edi, edx ; move dest into destination index
	cld ; clear direction flag so the bytes write in incrementing value
	rep	movsb ; repeatedly copy bytes until ecx runs out
	pop	edi ; clean the stack
	pop	esi ; clean the stack
	ret



error: ; called in-case of library error
	mov	eax, 1 ; set syscall for exit
	xor	ebx, ebx ; set rbx to 0
	dec	ebx ; set rbx to -1
	int	80h ; execute syscall -- exit()

inputb: ; void inputb(char *buffer , int length) ;; buffered stdin input
	mov	eax, [esp+4] ; move buffer into rax
	mov	ecx, [esp+8] ; move length into rcx
	mov	edx, stdin ; move stdin into rdx
	push	edx ; push stdin as an argument to finputb
	push	ecx ; push length as an argument to finputb
	push	eax ; push buffer as an argument to finputb
	call	finputb ; finputb(buffer, length, stdin);
	pop	eax ; clean stack
	pop	ecx ; clean stack
	pop	edx ; clean stack
	ret



finputb: ; void inputb(char *buffer, int length, FILE *stream) ;; buffered input from file
	mov	eax, [esp+4] ; move buffer into rax
	mov	ecx, [esp+8] ; move length into rcx
	mov	edx, [esp+12] ; move stream into rdx
	push	ebx ; save nonvolatile register
	mov	ebx, eax ; move buffer into rbx for read syscall
	dec	ecx ; decrement length by one to account for term byte
	xor	eax, eax ; set rax to 0
	.loop: ; continue reading a byte until the length is 0, or we reach newline
	cmp	ecx, 0 ; check for buffer end
	jz	.clean ; if so, end the function
	dec	ecx ; lower the available space by 1 byte
	push	ecx ; save the value of ecx, so it isnt overwritten by getc
	push	edx ; push stream as argument for getc
	call	getc ; getc(stream);
	pop	edx ; clean stack
	pop	ecx ; clean stack
	cmp	eax, 0ah ; check for '\n'
	je	.clean ; if last character was a newline, end function
	mov	byte [ebx], al ; if last character wasn't newline, write to buffer
	inc	ebx ; increment the byte specified by buffer
	jmp	.loop ; loop again
	.clean: ; end the function
	mov	byte [ebx], 0 ; append terminating byte
	pop	ebx ; clean stack
	.cloop: ; make sure to flush stdin
	cmp	eax, 0ah ; check for newline
	je	.end ; if newline, end for good
	cmp	eax, 0 ; check for terminating byte(in the case of a file, EOF)
	jz	.end ; if term. byte or EOF, end for good
	call	getc ; otherwise, getc to clean 1 byte from stdin
	jmp	.cloop ; loop until EOF or '\n'
	.end:
	ret


atoi: ; signed long atoi(char *string) ;; ascii to integer
	mov	ecx, [esp+4] ; move string to rcx
	xor	eax, eax ; set eax to 0
	xor	edx, edx ; set edx to 0 so that dh will be zero and won't overwrite our values
	.loop: ; iterate over string, checking for numbers
	cmp	byte [ecx], '0' ; check if the current byte is less than ASCII 0
	jl	.nonint ; if so, jump to .nonint
	cmp	byte [ecx], '9' ; check if the current byte is more than ASCII 9
	jg	.nonint ; if so, jump to .nonint
	mov	dl, [ecx] ; set dl to current byte
	sub	edx, '0' ; subtract ASCII 0 from whatever ASCII number we got
	imul	eax, 10 ; multiply rax(return value)
	add	eax, edx ; add current byte to rax(return value)
	inc	ecx ; increment our byte to iterate over the string
	jmp	.loop ; do loop again
	.nonint: ; if we didnt find an integer
	cmp	eax, 0 ; if we found 0 integers whatever in the string
	jz	error ; then there was an error. the input wasnt a number
	ret
	


strzero: ; void strzero(char *string) ;; nullify a string
	mov	eax, [esp+4] ; move string to rax
	push	eax ; save the starting address of string, also set as a parameter for strlen
	call	strlen ; get length of our string
	mov	edx, eax ; move the length of string into rdx
	pop	eax ; move string back into rax
	push	edx ; use the length as an argument for memzero
	push	eax ; use the string as an argument for memzero
	call	memzero ; nullify the bytes
	pop	eax ; clean stack
	pop	edx ; clean stack
	ret


memzero: ; void memzero(void *buffer, int length) ;; overwrite (length) bytes with zero
	mov	eax, [esp+4] ; move buffer into rax
	mov	ecx, [esp+8] ; move length into rcx
	.loop: ; overwrite all ze bytes
	cmp	ecx, 0 ; if our counter in ecx tells us to stop, we stop
	jz	.clean ; and then we clean our function call like good little boys and girls
	mov	byte [eax], 0 ; overwrite the byte with 0
	inc	eax ; increment our memory address in rax
	dec	ecx ; tell ourselves that we wrote a byte by lowering our counter
	jmp	.loop ; do it again
	.clean:
	ret

strcpy: ; void strcpy(void *src, void *dst, int length) ;; copies length bytes from src to dst.
	mov	eax, [esp+4] ; move src into rax
	mov	ecx, [esp+8] ; move dst into rcx
	mov	edx, [esp+12] ; move length into rdx
	push	edx ; use length as a parameter for memcpy
	push	ecx ; use dst as a parameter for memcpy
	push	eax ; use src as a parameter for memcpy
	call	memcpy ; call memcpy -- strcpy is just a wrapper for memcpy
	pop	eax ; clean stack
	pop	ecx ; clean stack
	pop	edx ; clean the stack -- like good little boys and girls
	ret

open: ; int open(char *filename, int flags, int mode);
	mov	eax, [esp+4] ; move filename to rax
	mov	ecx, [esp+8] ; move flags to rcx
	mov	edx, [esp+12] ; move mode into rdx
	push	ebx ; save nonvolatile register
	mov	ebx, eax ; move filename to rbx for syscall
	mov 	eax, 5 ; specify sys_open syscall
	int	80h
	pop	ebx
	ret

read: ; int read(char *filename, char *buffer, int length) ; read length bytes from filename into buffer
	mov	eax, [esp+4] ; move filename to rax
	mov	ecx, [esp+8] ; move buffer to rcx
	mov	edx, [esp+12] ; move length to rdx
	push	ebx ; save nonvolatile register
	push	edx ; save parameter for read
	push	ecx ; save parameter for read
	mov	edx, S_IRUSR ; set mode for open
	mov	ecx, O_RDONLY ; set flag for open
	mov	ebx, eax ; set filename for open
	push	edx ; push parameter
	push	ecx ; push parameter
	push	ebx ; push parameter
	call	open ; open file
	pop	ebx ; clean stack
	pop	ecx ; clean stack
	pop	edx ; clean stack
	pop	ecx ; set parameter for sys_read
	pop	edx ; set parameter for sys_read
	dec	edx ; decrement the length by one to account for term. byte
	mov	byte [ecx+edx], 0
	mov	ebx, eax ; set parameter for sys_read
	mov	eax, 3 ; specify sys_read
	int	80h	; sys_read
	pop	ebx ; clean stack
	ret
