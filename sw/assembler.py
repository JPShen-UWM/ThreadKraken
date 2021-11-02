# Assembler for ThreadKraken assembly code.
# converts assembly code to binary code
#
#
import sys
import collections
import re

class Assembler:
    def __init__(self):
        print("start translation:")

        # default starting addr pointing to program section in virtual addr
        self.ADDR_OFFSET = 0x00011000
        self.labels = collections.defaultdict(int)
        self.pc = 0
        self.programStack = []

    def setOffset(self, addr):
        self.ADDR_OFFSET = addr

    def compile(self, inFilename, outFilename='./output.o'):
        print("compile %s" %inFilename)
        self.firstRoundProcessing(inFilename)

        self.processProgram(outFilename)
        print("Compile complete")


    def firstRoundProcessing(self, filename):
        with open(filename) as infile:
            for line in infile:
                self.processLabels(line.strip())

    def processLabels(self, cmd):
        if cmd[0] == ".":
            self.labels[cmd[1:]] = hex(self.ADDR_OFFSET + self.pc)

        else:
            self.programStack.append([self.pc, cmd])
            self.pc += 1

    def processProgram(self, filename):
        with open(filename, 'w') as outfile:
          for line in self.programStack:
            binaryCmd = self.processCmd(line)
            outfile.write(binaryCmd)
    
    def processCmd(self, cmd):
        opcode = re.split(',| ', cmd[1])[0]
        print('pc %d -> cmd %s' %(cmd[0], opcode))
        return cmd[1]

      


if __name__ == "__main__":
    asm = Assembler()
    asm.compile(sys.argv[1])
