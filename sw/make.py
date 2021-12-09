# compiles test_cases in batch
# author: zhengzhi chen
# usage: 
#   to compile:   python3 make.py 
#   to clean:     python3 make.py clean
#

from assembler import Assembler
import os
import sys

def compile(files, folder_name):
	for file in files:
			if '.asm' in file:
				asm = Assembler()
				asm.compile(folder_name + file, folder_name + file[:-4]+'.o')
				asm = Assembler()
				asm.setBinaryFormat(True)
				asm.setReadableOutput(True)
				asm.compile(folder_name + file, folder_name + file[:-4]+'.ref')

if __name__ == '__main__':
	cur_path = os.getcwd()
	simple_cases = os.listdir(cur_path + '/test_cases')
	thread_cases = os.listdir(cur_path + '/thread_test_cases')
	
	if 'clean' in sys.argv:
		for file in simple_cases:
			if '.asm' not in file:
				os.remove('./test_cases/'+file)
		for file in thread_cases:
			if '.asm' not in file:
				os.remove('./thread_test_cases/'+file)
	else:
		compile(simple_cases, './test_cases/')
		compile(thread_cases, './thread_test_cases/')

	