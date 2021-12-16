# compiles test_cases in batch
# author: zhengzhi chen
# usage: 
#   to compile:   python3 make.py 
#   to clean:     python3 make.py clean
#

from assembler import Assembler
from simulator import Simulator
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
				# asm = Assembler()
				# asm.char = True
				# asm.compile(folder_name + file, folder_name + file[:-4]+'.txt')

def simulate(folder_name):
	s = Simulator()
	s.run(folder_name + '/beq1.asm')
	print(s.threads[0].regs)
	print(s.mem)


if __name__ == '__main__':
	cur_path = os.getcwd()
	simple_cases = os.listdir(cur_path + '/test_cases')
	thread_cases = os.listdir(cur_path + '/thread_test_cases')
	demo_cases = os.listdir(cur_path + '/Demo')
	
	if 'clean' in sys.argv:
		for file in simple_cases:
			if '.asm' not in file:
				os.remove('./test_cases/'+file)
		for file in thread_cases:
			if '.asm' not in file:
				os.remove('./thread_test_cases/'+file)
		for file in demo_cases:
			if '.asm' not in file:
				os.remove('./Demo/'+file)
	else:
		compile(simple_cases, './test_cases/')
		compile(thread_cases, './thread_test_cases/')
		compile(demo_cases, './Demo/')

	# simulate('./test_cases/')

	