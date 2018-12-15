# synthlib
Assembly language library written for practice. NASM syntax for 8086 processors, compile with -m elf_i386 or use built-in compile.sh script


current functions


print <string in eax>

println <string in eax>

putchar <character in eax

sleep <seconds in eax>

strlen  <string in eax> <returns int to eax>

strcmp  <string in eax> <string in ebx> <returns int to eax, 1 if equal, 0 if not equal>

inputb  <pointer in eax>

strcpy  <string in eax> <string in ebx>

memcpy  <pointer in eax, src>   <pointer in ebx, dest>  <int buffersize in ecx>

memzero <pointer in eax>  <int in ebx, bytes to zero>

strcat  <string in eax, base> <string in ebx, addition>

exit  <int in eax, exit code>

