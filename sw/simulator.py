import copy


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


class Simulator:
    instr_map = {}

    def __init__(self):
      print("simulator starts")
      self.mem = {}
      self.threads = [0]*8
      self.instr = []
      self.labels = {}
      self.last_exe_thrd_idx = -1

    def run(self, file_name):
      self.load_instr(file_name)
      self.threads[0] = Thread() #root thread
      self.threads[1] = Thread(1) #root thread
      self.threads[2] = Thread(2) #root thread
      self.execute_program()
      return 

    def load_instr(self,file_name):
      with open(file_name) as lines:
        for line in lines:
          self.processLabels(line.strip())
      print('instructions loaded')
      print(self.instr)
      return
    
    def processLabels(self, cmd):
      if not cmd or cmd[0] == '#' or cmd[0] == '/' or cmd[0] == '/': return
      if cmd[0] == ".":
          self.labels[cmd] = self.pc

      else:
          if cmd.find('/') != -1:
            self.instr.append(cmd[:cmd.find('/')].strip())
          else:
            self.instr.append(cmd)
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
        
        
        print(self.last_exe_thrd_idx)
      return

    def execute_on_thread(self, thrd):
      cmd = self.instr[thrd.pc]


      thrd.pc += 1
      if thrd.pc >= len(self.instr):
        thrd.die()
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
  s.run('./test_cases/add1.asm')
  


