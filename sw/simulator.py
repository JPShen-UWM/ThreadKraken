import copy
import re
from assembler import imm_to_bin, bindigits

IDLE = 0
RUNNABLE = 1
SLEEP = 2

def findSlot(pool):
  for i,slot in enumerate(pool):
    if slot == 0 or slot.state == IDLE:
      return i
  return -1

def find_next_thrd(last, pool):
  for i in range(last+1,8):
    if pool[i] and pool[i].state == RUNNABLE:
      return (pool[i],i)
  for i in range(0,last+1):
    if pool[i] and pool[i].state == RUNNABLE:
      return (pool[i],i)
  return None

def str_to_int(str):
  if '0x' in str:
    return int(str,16)
  return int(str)

def invert(str):
  ret = ''
  for c in str:
    if c == '0':
      ret += '1'
    else:
      ret += '0'
  return ret

def full_adder(str1, str2):
  str1, str2 = str(str1), str(str2)
  c = 0
  ret = ''
  
  for i in range(31,-1,-1):
    tmp = ''
    if str1[i] == str2[i] and str1[i] == '1':
      tmp = '1' if c != 0 else '0'
      c = 1
    elif str1[i] != str2[i]:
      tmp = '0' if c != 0 else '1'
      c = 1 if c == 1 else 0
    else:
      tmp = str(c)
      c = 0
    ret = tmp + ret
  return ret


# def twos_comp(val, bits):
#     """compute the 2's complement of int value val"""
#     if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
#         val = val - (1 << bits)        # compute negative value
#     return val                         # return positive value as is


class Simulator:
    def _add(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      
      rd,ra,rb = int(rd[1:]),int(ra[1:]),int(rb[1:])

      thrd.regs[rd] = int(full_adder(bindigits(thrd.regs[ra],32), bindigits(thrd.regs[rb],32)),2)
      return

    def _not(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, ra] = [_ for _ in args if len(_) > 0]
      
      rd,ra = int(rd[1:]),int(ra[1:])

      # print("not: ", ~thrd.regs[ra], thrd.regs[ra])
      thrd.regs[rd] = int(invert(bindigits(thrd.regs[ra],32)),2)
      # print(thrd.regs[rd])
      return

    def _and(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      
      rd,ra,rb = int(rd[1:]),int(ra[1:]),int(rb[1:])

      # print("and: ", bindigits(thrd.regs[ra],32), bindigits(thrd.regs[rb],32))
      thrd.regs[rd] = thrd.regs[ra] & thrd.regs[rb]
      # print('result: ', bindigits(thrd.regs[rd],32))
      return

    def _or(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      
      rd,ra,rb = int(rd[1:]),int(ra[1:]),int(rb[1:])

      # print("or: ", bindigits(thrd.regs[ra],32), bindigits(thrd.regs[rb],32))
      thrd.regs[rd] = thrd.regs[ra] | thrd.regs[rb]
      # print('result: ', bindigits(thrd.regs[rd],32))
      return

    def _xor(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, ra, rb] = [_ for _ in args if len(_) > 0]
      
      rd,ra,rb = int(rd[1:]),int(ra[1:]),int(rb[1:])

      # print("xor: ", bindigits(thrd.regs[ra],32), bindigits(thrd.regs[rb],32))
      thrd.regs[rd] = thrd.regs[ra] ^ thrd.regs[rb]
      # print('result: ', bindigits(thrd.regs[rd],32))
      return

    def _addi(thrd, cmd):
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      
      rd,ra= int(rd[1:]),int(ra[1:])
      imm = str_to_int(imm)

      # print("addi: ", bindigits(thrd.regs[ra],32), bindigits(imm,32))
      thrd.regs[rd] = int(full_adder(bindigits(thrd.regs[ra],32), bindigits(imm,32)),2)
      # print('result: ', bindigits(thrd.regs[rd],32))
      return

    def _andi(thrd, cmd):
      IMM_LEN = 12

      args = re.split(',| ', cmd)
      [_, rd, ra, imm] = [_ for _ in args if len(_) > 0]
      
      rd,ra= int(rd[1:]),int(ra[1:])
      imm = str_to_int(imm)

      thrd.regs[rd] = thrd.regs[ra] & imm
      return

    def _lbi(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, imm] = [_ for _ in args if len(_) > 0]
      
      rd,imm = int(rd[1:]), str_to_int(imm)

      # print('lbi original: ', bindigits(thrd.regs[rd],32))
      original = bindigits(thrd.regs[rd],32)
      original = original[:16] + bindigits(imm,16)
      thrd.regs[rd] = int(original,2)
      # print('lbi result: ', bindigits(thrd.regs[rd],32))
      return

    def _slbi(thrd, cmd):
      args = re.split(',| ', cmd)
      [_, rd, imm] = [_ for _ in args if len(_) > 0]
      
      rd,imm = int(rd[1:]), str_to_int(imm)

      thrd.regs[rd] = (thrd.regs[rd] << 16) + imm
      print('slbi result: ', bindigits(thrd.regs[rd],32))
      return

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
      # 'ori': _ori, 
      # 'xori': _xori,
      # 'shlt': _shlt, 
      # 'shrt': _shrt, 
      # 'shra': _shra,
      'lbi': _lbi, 
      'slbi': _slbi,
      # 'st': _st, 
      # 'ld': _ld, 
      # 'jal': _jal, 
      # 'jalr': _jalr, 
      # 'beq': _beq, 
      # 'bneq': _bneq, 
      # 'blt': _blt,
      # 'slp': _slp,
      # 'wk': _wk,
      # 'kill': _kill,
      # 'nt': _nt
    }

    def __init__(self):
      print("simulator starts")
      self.counter = 0
      self.mem = {}
      self.threads = [0]*8
      self.instr = []
      self.labels = {}
      self.last_exe_thrd_idx = -1

    def run(self, file_name):
      self.load_instr(file_name)
      self.threads[0] = Thread() #root thread
      self.execute_program()
      return 

    def load_instr(self,file_name):
      with open(file_name) as lines:
        for line in lines:
          self.processLabels(line.strip())
      print('instructions loaded')
      # print(self.instr)
      return
    
    def processLabels(self, cmd):
      if not cmd or cmd[0] == '#' or cmd[0] == '/' or cmd[0] == '/': return

      if cmd[0] == ".":
          self.labels[cmd] = self.counter

      else:
          if cmd.find('/') != -1:
            self.instr.append(cmd[:cmd.find('/')].strip())
          else:
            self.instr.append(cmd)
            self.counter += 1
      return

    def execute_program(self):
      #loop until no thread exists
      while findSlot(self.threads) != -1: 
        next = find_next_thrd(self.last_exe_thrd_idx, self.threads)
        if not next: 
          break
        
        else: # it's this threads turn
          cur_thrd,indx = next
          
          self.execute_on_thread(cur_thrd)
          self.last_exe_thrd_idx = indx
        
        
        print(cur_thrd)
        # tmp = [bindigits(_,32) for _ in cur_thrd.regs]
        # print(tmp)
      return

    def execute_on_thread(self, thrd):
      cmd = self.instr[thrd.pc]

      args = re.split(',| ', cmd)
      opcode= args[0].lower()
      atomic = False
      
      
      # print('pc %d -> cmd %s' %(cmd[0], opcode))
      if opcode[-1] == 'a' and opcode[:-1] in Simulator.cmd_table:
        if opcode[:-1] in ['jal', 'jalr', 'beq', 'bneq', 'blt']: # check if labels are used
          retStr = Simulator.func_map[opcode[:-1]](thrd, cmd.lower(), self.labels)
        else: 
          retStr = Simulator.func_map[opcode[:-1]](thrd, cmd.lower())
        atomic = True
      else:
        if opcode in ['jal', 'jalr', 'beq', 'bneq', 'blt']: # check if labels are used
          retStr = Simulator.func_map[opcode](thrd, cmd.lower(), self.labels)
        else:
          retStr = Simulator.func_map[opcode](thrd, cmd.lower())


      thrd.pc += 1
      if thrd.pc >= len(self.instr):
        thrd.die()
        return
      if atomic: self.execute_on_thread(thrd)
      return 
      






class Thread:
    def __init__(self, id = 0, pc=0, stack=[], regs = [0]*32, parent = None):
      self.id = id
      self.stack = copy.deepcopy(stack)
      self.pc = copy.deepcopy(pc)
      self.regs = copy.deepcopy(regs)
      self.parent = parent
      self.children = []
      self.state = RUNNABLE

    def create(self, id):
      self.children.append(Thread(id=id, pc=self.pc+1, stack=self.stack, regs=self.regs,
        parent=self))
      return self.children[-1]

    
    def set_pc(self,num):
      self.pc = num
      return
    
    def die(self):
      self.state = IDLE
      return


    def __str__(self):
      str = '*'*40 + '\n'
      str += f'Thread ID  :   {self.id}\n'
      str += f'Current PC :   {self.pc}\n'
      str += f'parent thrd:   {self.parent}\n'
      str += f'child thrd :   {self.children}\n'
      str += f'*'*40
      return str

  

if __name__ == '__main__':
  print('Welcome to ThreadKraken Simulator')
  s = Simulator()
  s.run('./test_cases/test_input.asm')

  a = '11111111111111111111111111111111'
  print(len(a))
  # b = 7
  # print(hex(a),hex(b))
  # a = bindigits(a,32)
  # b = bindigits(b,32)
  # c = full_adder(a, b)
  
  # print('a:', a)
  # print('b:', b)
  # print('c:', c)
  # print(imm_to_bin('248', 32,1))
  # print( len(c))
  


