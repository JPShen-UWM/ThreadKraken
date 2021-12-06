from assembler import Assembler
import os


if __name__ == '__main__':
	cur_path = os.getcwd()
	files = os.listdir(cur_path + '/test_cases')
	
	for file in files:
		asm = Assembler()
		if '.asm' in file:
			print('name: '+file)
			asm.compile('./test_cases/'+file, './test_cases/'+file[:-4]+'.o')
			asm = Assembler()
			asm.setBinaryFormat(True)
			asm.setReadableOutput(True)
			asm.compile('./test_cases/'+file, './test_cases/'+file[:-4]+'.ref')

	