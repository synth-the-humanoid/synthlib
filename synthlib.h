#ifndef synthlib
#define synthlib

//FILE struct def from glibc
typedef struct 
{
 short level ;
 short token ;
 short bsize ;
 char fd ;
 unsigned flags ;
 unsigned char hold ;
 unsigned char *buffer ;
 unsigned char * curp ;
 unsigned istemp; 
}FILE ;






//functions declared in lib.asm

extern void print(char *);
extern int strcmp(char *, char *);
extern void putchar(char);
extern void println(char *);
extern int strlen(char *);
extern char getchar();
extern void sleep(int);
extern long exp(int, int);
extern void strcpy(char *, char *, int);
extern void putc(char, FILE *);
extern char getc(FILE *);
extern void inputb(char *, int);
extern void finputb(char *, int, FILE *);


//functions declared in C
signed long atoi(char *); // ascii to unsigned int, -1 on error
signed int itoa(unsigned int, char *, unsigned int); // int to ascii, -1 on error


//functions


signed long atoi(char *string) {
	char *vstring = string;
	while(*vstring != 0) {
		if(*vstring > '9' || *vstring < '0') {
			return -1;
		}
		vstring++;
	}
	vstring = string;
	signed long retval = 0;
	while(*vstring != 0) {
		retval *= 10;
		retval += (*vstring - '0');
		vstring++;
	}
	if(retval < 0) {
		return -1;
	}
	return retval;
}


signed int itoa(unsigned int value, char *buffer, unsigned int buffersize) {
	if(!value) {
		buffer[0] = '0';
		buffer[1] = 0;
		return 0;
	}
	int i = 0;
	int lval = value;
	while(lval) {
		i++;
		lval/=10;
	}
	i++;
	if(i > buffersize) {
		return -1;
	}
	i = buffersize;
	buffer[--i] = 0;
	lval = value;
	while(i+1) {
		buffer[i--] = '0' + lval%10;
		lval /= 10;
	}

	i = 0;
	
	while(buffer[i] == '0') {
		if(buffer[i] == 0) {
			strcpy("0", buffer, buffersize);
			return 0;
		}
		i++;
	}
	int i2 = 0;
	while(buffer[i] != 0) {
		buffer[i2++] = buffer[i++];
	}
	buffer[i2] = 0;
	return 0;	
}

#endif
