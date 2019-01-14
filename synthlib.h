#ifndef synthlib
#define synthlib

//functions declared in lib.asm

extern void print(char *);
extern int strcmp(char *, char *);
extern void putchar(char);
extern void println(char *);
extern int strlen(char *);
extern char getchar();
extern void sleep(int);
extern long exp(int, int);

//functions declared in C
void inputb(char *, int); // buffered input -- written in C to prevent overflow
void strcpy(char *, char *, int); // string copy, buffered

//functions

void inputb(char *buffer, int buffersize) {
	buffersize--; //nullbyte
	int current;
	while((current = getchar()) != '\n' && buffersize) {
		*buffer = current;
		buffer++;
		buffersize--;
	}
	*buffer = 0;
	//in case of attempted overflow, we clear the stdin buffer. this function is only safe for use with STDIN
	if(current != '\n' && current != '\r') {
		while((current = getchar()) != '\n' && current != '\r') {
			continue;
		}
	}
	return;
}

void strcpy(char *from, char *to, int len) {
	len--;
	while(*from != 0 && len--) {
		*to = *from;
		from++;
		to++;
	}
	*to = 0;
	return;
}


#endif
