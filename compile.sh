#!/bin/bash
if [ -f $1 ]
then
nasm -f elf lib.s
gcc -m32 -g -Wno-builtin-declaration-mismatch $1 lib.o
else
echo "Invalid file"
fi
