# Assembler for ThreadKraken assembly code.
# converts assembly code to binary code
# Author: zhengzhi Chen
# 
# Usage: python3 assember inputfile -h -o outfile
# -h: human read format, debug use
# -o: specify output file name, otherwise: output.o
import sys
import binascii
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

# converts int to 2's complement
def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

# convert imm to bin str of length n
# mode 0: normal mode, no -, outputs extended bit string
# mode 1: can take -
def imm_to_bin(s, n, mode=0):
  neg = 0 # mark negative for arithmetic extension
  bin_val = ''
  if s[0] == '-':
    neg = 1
    s = s[1:]
  
  dec_val = int(s[2:], base=16) if s[:2] == '0x' else int(s)
  
  mode1_lim, mode0_lim = 2**(n-1) - 1, 2**(n) - 1
  if dec_val > mode1_lim and mode == 1 :
    raise Exception('imm out of range -%d to %d...'%(mode1_lim, mode1_lim))
  elif dec_val > mode0_lim and mode == 0 :
    raise Exception('imm out of range 0 to %d...'%(mode0_lim))
  elif neg == 1 and mode == 0:
    raise Exception('negative number is not allowed.')

  if neg == 1: dec_val = dec_val * -1
  bin_val = bindigits(dec_val, n)
  return bin_val

  


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

    # and
    # AND rd, ra, rb  |   rd = ra & rb
    def _and(cmd):
      OPCODE = '1111111'

      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' or rb[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra,rb = bin(int(rd[1:])),bin(int(ra[1:])),bin(int(rb[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + l_ext(rb,5) + '0'*9 + OPCODE + '0'


    # or
    # OR rd, ra, rb   |    rd = ra | rb
    def _or(cmd):
      OPCODE = '1011111'

      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' or rb[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra,rb = bin(int(rd[1:])),bin(int(ra[1:])),bin(int(rb[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + l_ext(rb,5) + '0'*9 + OPCODE + '0'      

    # xor
    # XOR rd, ra, rb   |    rd = ra ^ rb
    def _xor(cmd):
      OPCODE = '0111111'

      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' or rb[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra,rb = bin(int(rd[1:])),bin(int(ra[1:])),bin(int(rb[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + l_ext(rb,5) + '0'*9 + OPCODE + '0'   

    # addi
    # ADDI rd, ra, imm rd = ra + imm
    # signed immediate  
    def _addi(cmd):
      OPCODE = '1101110'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN, mode= 1) # 2's complement mode
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'   

    # andi
    # ANDI rd, ra, imm    |    rd = ra & imm
    # assume imm will not contain negative sign
    def _andi(cmd):
      OPCODE = '1111110'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'  

    # ori
    # ORI rd, ra, imm   |    rd = ra | imm
    def _ori(cmd):
      OPCODE = '1011110'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'  

    # xori
    # XORI rd, ra, imm     |   rd = ra ^ imm
    def _xori(cmd):
      OPCODE = '0111110'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'  

    # shlt
    # SHLT rd, ra, imm     |    rd = ra << imm
    def _shlt(cmd):
      OPCODE = '0011100'
      IMM_LEN = 5

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + '0'*7 + imm + '0'*2 + OPCODE + '0'   

    # shrt  (arithmetic)
    # SHRT rd, ra, imm     |    rd = ra >>> imm
    def _shrt(cmd):
      OPCODE = '0101100'
      IMM_LEN = 5

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + '0'*7 + imm + '0'*2 + OPCODE + '0'     

    # shra
    # SHRA rd, ra, imm     |    rd = ra >> imm
    def _shra(cmd):
      OPCODE = '1001100'
      IMM_LEN = 5

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN)
      
      return l_ext(rd,5) + l_ext(ra,5) + '0'*7 + imm + '0'*2 + OPCODE + '0'     

    # lbi
    # LBI rd, imm    |     rd[15:0] = imm
    def _lbi(cmd):
      OPCODE = '0011001'
      IMM_LEN = 16

      args = re.split(',| ', cmd)
      [_, rd, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r':
        raise Exception('Unrecognized arguments...')

      rd = bin(int(rd[1:]))
      imm = imm_to_bin(imm, IMM_LEN) # default mode 0
      
      return l_ext(rd,5) + '0' + imm + '0'*2 + OPCODE + '0' 

    # slbi
    # sLBI rd, imm    |     rd = (rd << 16) | imm
    def _slbi(cmd):
      OPCODE = '0101001'
      IMM_LEN = 16

      args = re.split(',| ', cmd)
      [_, rd, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r':
        raise Exception('Unrecognized arguments...')

      rd = bin(int(rd[1:]))
      imm = imm_to_bin(imm, IMM_LEN) # default mode 0
      
      return l_ext(rd,5) + '0' + imm + '0'*2 + OPCODE + '0' 

    # st
    # ST ra, rb, imm     |     M[ra + imm] = rb
    def _st(cmd):
      OPCODE = '01101000'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, ra, rb, imm] = [_ for _ in args if len(_) > 0]
      if rb[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rb,ra = bin(int(rb[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN, 1) # no negative
      
      return l_ext(rb,5) + l_ext(ra,5) + imm + '0' + OPCODE + '0'   
    
    # ld
    # LD rd, ra, imm      |      rd = M[ra + imm]
    def _ld(cmd):
      OPCODE = '11101000'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      imm = imm_to_bin(imm, IMM_LEN, 1) # no negative
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0' + OPCODE + '0'   

    # jal
    # JAL rd, imm    |     PC = PC + 1 + imm; rd = PC + 1
    def _jal(cmd, labels, curPC):
      OPCODE = '0001010'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r':
        raise Exception('Unrecognized arguments...')

      rd = bin(int(rd[1:]))
      if imm in labels:
        diff = labels[imm] - curPC - 1
        # print('labels[imm]: %d - curPC: %d = %s'%(labels[imm], curPC, imm))
        imm = imm_to_bin(str(diff), IMM_LEN, mode=1)
      else:
        imm = imm_to_bin(imm, IMM_LEN, mode=1) # can be neg
      
      return l_ext(rd,5) + '0'*5 + imm + '0'*2 + OPCODE + '0' 

    # jalr
    # JALR rd, ra, imm     |    PC = ra + imm; rd = PC + 1
    def _jalr(cmd, labels, curPC):
      OPCODE = '0101010'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rd,ra = bin(int(rd[1:])),bin(int(ra[1:]))
      if imm in labels:
        diff = labels[imm] - curPC - 1
        imm = imm_to_bin(str(diff), IMM_LEN, mode=1)
      else:
        imm = imm_to_bin(imm, IMM_LEN, mode=1) # can be neg
      
      return l_ext(rd,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'   
    
    # beq 
    # BEQ ra, rb, imm      |     PC = PC +1 + imm if (ra == rb)
    def _beq(cmd, labels, curPC):
      OPCODE = '0011010'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, ra, rb, imm] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r' or rb[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rb,ra = bin(int(rb[1:])),bin(int(ra[1:]))
      if imm in labels:
        diff = labels[imm] - curPC - 1
        imm = imm_to_bin(str(diff), IMM_LEN, mode=1)
      else:
        imm = imm_to_bin(imm, IMM_LEN, mode=1) # can be neg
      
      return l_ext(rb,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0'      

    # bneq 
    # BNEQ ra, rb, imm      |     PC = PC +1 + imm if (ra != rb)
    def _bneq(cmd, labels, curPC):
      OPCODE = '0111010'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, ra, rb, imm] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r' or rb[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rb,ra = bin(int(rb[1:])),bin(int(ra[1:]))
      if imm in labels:
        diff = labels[imm] - curPC - 1
        imm = imm_to_bin(str(diff), IMM_LEN, mode=1)
      else:
        imm = imm_to_bin(imm, IMM_LEN, mode=1) # can be neg

      return l_ext(rb,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0' 

    # blt 
    # BLT ra, rb, imm      |     PC = PC +1 + imm if (ra < rb)
    def _blt(cmd, labels, curPC):
      OPCODE = '1111010'
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, ra, rb, imm] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r' or rb[0] != 'r' :
        raise Exception('Unrecognized arguments...')

      rb,ra = bin(int(rb[1:])),bin(int(ra[1:]))
      if imm in labels:
        diff = labels[imm] - curPC - 1
        imm = imm_to_bin(str(diff), IMM_LEN, mode=1)
      else:
        imm = imm_to_bin(imm, IMM_LEN, mode=1) # can be neg
      
      return l_ext(rb,5) + l_ext(ra,5) + imm + '0'*2 + OPCODE + '0' 
    
    # slp 
    # slp ra   | sleep thread
    def _slp(cmd):
      OPCODE = '1010110'

      args = re.split(',| ', cmd)
      [_, ra] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r':
        raise Exception('Unrecognized arguments...')
      
      ra = bin(int(ra[1:]))
      return '0'*5 + l_ext(ra,5)+ '0'*14 + OPCODE + '0'

    # kill
    # kill ra   | kill thread ra
    def _kill(cmd):
      OPCODE = '0000110'

      args = re.split(',| ', cmd)
      [_, ra] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r':
        raise Exception('Unrecognized arguments...')
      
      ra = bin(int(ra[1:]))
      return '0'*5 + l_ext(ra,5)+ '0'*14 + OPCODE + '0'

    # wake
    # wake ra   |wake up thread ra
    def _wk(cmd):
      OPCODE = '0100110'

      args = re.split(',| ', cmd)
      [_, ra] = [_ for _ in args if len(_) > 0]
      if ra[0] != 'r':
        raise Exception('Unrecognized arguments...')
      
      ra = bin(int(ra[1:]))
      return '0'*5 + l_ext(ra,5)+ '0'*14 + OPCODE + '0'

    # nt   -> new thread
    # nt rd,ra,rb
    def _nt(cmd):
      OPCODE = '1110110'

      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      if rd[0] != 'r' or ra[0] != 'r' or rb[0] != 'r':
        raise Exception('Unrecognized arguments...')
      rd,ra,rb = bin(int(rd[1:])),bin(int(ra[1:])),bin(int(rb[1:]))
      
      return l_ext(rd,5) + l_ext(ra,5) + l_ext(rb,5) + '0'*9 + OPCODE + '0'

    
      



    cmd_table = ['add', 'not', 'and', 'or', 'xor', 'addi', 'andi', 'ori', 'xori',
    'shlt', 'shrt', 'lbi', 'slbi','st', 'ld', 'jal', 'jalr', 'beq', 'bneq', 'blt', 'slp', 'wk', 'kill','nt']

    func_map = {
      'add': _add, 
      'not': _not,
      'and': _and, 
      'or': _or,
      'xor': _xor, 
      'addi': _addi, 
      'andi': _andi, 
      'ori': _ori, 
      'xori': _xori,
      'shlt': _shlt, 
      'shrt': _shrt, 
      'shra': _shra,
      'lbi': _lbi, 
      'slbi': _slbi,
      'st': _st, 
      'ld': _ld, 
      'jal': _jal, 
      'jalr': _jalr, 
      'beq': _beq, 
      'bneq': _bneq, 
      'blt': _blt,
      'slp': _slp,
      'wk': _wk,
      'kill': _kill,
      'nt': _nt
    }
    
    def __init__(self):
        # default starting addr pointing to program section in virtual addr
        self.ADDR_OFFSET = 0x00011000
        self.labels = {}
        self.pc = 0
        self.programStack = []
        self.manRead = False
        self.binaryFormat = False
        self.char = False

    def setOffset(self, addr):
        self.ADDR_OFFSET = addr

    def setReadableOutput(self, bool):
        self.manRead = bool
    
    def setBinaryFormat(self, bool):
        self.binaryFormat = bool

    def compile(self, inFilename, outFilename='./output.o'):
        print("compile %s" %inFilename)
        self.firstRoundProcessing(inFilename)
        if outFilename == None:
          outFilename = './output.o'
        self.processProgram(outFilename)
        print("Compile complete")


    def firstRoundProcessing(self, filename):
        with open(filename) as infile:
            for line in infile:
                self.processLabels(line.strip())
        return

    def processLabels(self, cmd):
        if not cmd or cmd[0] == '#' or cmd[0] == '/': return
        if cmd[0] == ".":
            self.labels[cmd] = self.pc

        else:
            if cmd.find('/') != -1:
              self.programStack.append([self.pc, cmd[:cmd.find('/')].strip()])
            else:
              self.programStack.append([self.pc, cmd])
            self.pc += 1
        return

    def processProgram(self, filename):

        with open(filename, 'w', encoding='utf-8') as outfile:
          for line in self.programStack:
            binaryCmd = self.processCmd(line)
            if self.char: 
              
              outfile.write(binaryCmd)
              continue
            if not self.manRead:
              outfile.write(binaryCmd + '\n')
            else:
              outfile.write('line %s cmd: %s binary/hex: %s \n' %(str(line[0]).ljust(5), line[1].ljust(29), binaryCmd))
            outfile.flush()
          outfile.close()
        return

    def processCmd(self, cmd):
        args = re.split(',| ', cmd[1])
        opcode= args[0].lower()
        retStr = ''
        atomic = '0'
        
        # print('pc %d -> cmd %s' %(cmd[0], opcode))
        try:
          if opcode[-1] == 'a' and opcode[:-1] in Assembler.cmd_table:
            if opcode[:-1] in ['jal', 'jalr', 'beq', 'bneq', 'blt']: # check if labels are used
              retStr = Assembler.func_map[opcode[:-1]](cmd[1].lower(), self.labels, cmd[0])
            else: 
              retStr = Assembler.func_map[opcode[:-1]](cmd[1].lower())
            atomic = '1'
          else:
            if opcode in ['jal', 'jalr', 'beq', 'bneq', 'blt']: # check if labels are used
              retStr = Assembler.func_map[opcode](cmd[1].lower(), self.labels, cmd[0])
            else:
              retStr = Assembler.func_map[opcode](cmd[1].lower())
            
        except Exception as e:
          print("\n!!!!!!!error!!!")
          print(e.__traceback__.tb_frame)
          print(e.__traceback__.tb_lineno)
          print("****************************")
          # exit()
          
        retStr = retStr[:-1] + atomic
        dec = int(retStr,2)
        hexStr = l_ext(hex(dec),8)
        if self.char:
          ret = ''
          for i in range(4):
            cur = retStr[(i*8):min((8+i*8),32)]
            if cur:
              ret += chr(int(cur,2))
            else: 
              ret += chr(0)

          return ret
        else:
          return hexStr if not self.binaryFormat else retStr



if __name__ == "__main__":
    asm = Assembler()
    outFilename = None
    if '-h' in sys.argv:
      asm.setReadableOutput(True)
    if '-b' in sys.argv:
      asm.setBinaryFormat(True)
    if '-o' in sys.argv:
      outFilename = sys.argv[sys.argv.index('-o') + 1]
    if '-a' in sys.argv:
      asm.char = True

    # print(chr(0))
    # s = b'\0asdf'
    # print(s)
    # print(binascii.b2a_uu(s))
    asm.compile(sys.argv[1], outFilename)
  
