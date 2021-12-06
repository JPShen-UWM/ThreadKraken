# compiles test_cases in batch
# author: zhengzhi chen
# usage: 
#   to compile:   python3 make.py 
#   to clean:     python3 make.py clean
#

from assembler import Assembler
import os
import sys

if __name__ == '__main__':
	cur_path = os.getcwd()
	files = os.listdir(cur_path + '/test_cases')
	
	if 'clean' in sys.argv:
		for file in files:
			if '.asm' not in file:
				os.remove('./test_cases/'+file)
	else:
		for file in files:
			if '.asm' in file:
				asm = Assembler()
				asm.compile('./test_cases/'+file, './test_cases/'+file[:-4]+'.o')
				asm = Assembler()
				asm.setBinaryFormat(True)
				asm.setReadableOutput(True)
				asm.compile('./test_cases/'+file, './test_cases/'+file[:-4]+'.ref')

	