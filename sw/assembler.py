# Assembler for ThreadKraken assembly code.
# converts assembly code to binary code
#
#
import sys
import collections
import re

#arithmetic extension s to n bit
# s = 0b xxx
def a_ext(s, n):
  s = s[2:]
  if len(s) < n:
    return s[0]*(n-len(s)) + s
  else:
    return s
#logic extension s to n bit
def l_ext(s, n):
  s = s[2:]
  if len(s) < n:
    return '0'*(n-len(s)) + s
  else:
    return s

class Assembler:

    # add
    # ADD rd, ra, rb | rd = ra + rb
    def _add(cmd):
      OPCODE = '1101111'

      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' or rb[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra,rb = bin(int(rd[1:])),bin(int(ra[1:])),bin(int(rb[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + l_ext(rb,5) + '0'*9 + OPCODE + '0'

    # not
    # NOT rd, ra    |    rd = !ra
    def _not(cmd):
      OPCODE = '0001111'

      args = re.split(',| ', cmd)
      [_, rd, ra] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + '0'* 14 + OPCODE + '0'

    # addi
    # ADDI rd, ra, imm rd = ra + imm
    # signed immediate  
    # def _addi(cmd):

    

    cmd_table = ['add', 'not', 'and', 'or', 'xor', 'addi', 'andi', 'ori', 'xori',
    'shlt', 'shrt', 'lbi', 'slbi','st', 'ld', 'jal', 'jalr', 'beq', 'bneq', 'blt']

    func_map = {
      'add': _add, 
      'not': _not,
      # 'and': _and, 
      # 'or': _or,
      # 'xor': _xor, 
      # 'addi': _addi, 
      # 'andi': _andi, 
      # 'ori': _ori, 
      # 'xori': _xori,
      # 'shlt': _shlt, 
      # 'shrt': _shrt, 
      # 'lbi': _lbi, 
      # 'slbi': _slbi,
      # 'st': _st, 
      # 'ld': _ld, 
      # 'jal': _jal, 
      # 'jalr': _jalr, 
      # 'beq': _beq, 
      # 'bneq': _bneq, 
      # 'blt': _blt
    }
    
    def __init__(self):
        print("start translation:")

        # default starting addr pointing to program section in virtual addr
        self.ADDR_OFFSET = 0x00011000
        self.labels = collections.defaultdict(int)
        self.pc = 0
        self.programStack = []
        self.manRead = False

    def setOffset(self, addr):
        self.ADDR_OFFSET = addr

    def setReadableOutput(self, bool):
        self.manRead = bool

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
            if not self.manRead:
              outfile.write(binaryCmd + '\n')
            else:
              outfile.write('line %d, cmd: %s, binary: %s \n' %(line[0], line[1], binaryCmd))
    
    def processCmd(self, cmd):
        opcode = re.split(',| ', cmd[1])[0].lower()
        retStr = ''
        atomic = '0'

        # print('pc %d -> cmd %s' %(cmd[0], opcode))
        try:
          if opcode[-1] == 'a' and opcode[:-1] in Assembler.cmd_table:
            retStr = Assembler.func_map[opcode[:-1]](cmd[1].lower())
            atomic = '1'
          else:
            retStr = Assembler.func_map[opcode](cmd[1].lower())
            
        except Exception as e:
          print(e)
          exit()
          
        retStr = retStr[:-1] + atomic
        return retStr



if __name__ == "__main__":
    asm = Assembler()
    if '-h' in sys.argv:
      asm.setReadableOutput(True)
    asm.compile(sys.argv[1])
