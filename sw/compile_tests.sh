#!/usr/bin/bash
DIRS=./test_cases
for file in $DIRS/*.asm:
	python3 ./assembler.py $file -o $DIR/$file.o
	python3 ./assembler.py $file -o $DIR/$file.ref -h