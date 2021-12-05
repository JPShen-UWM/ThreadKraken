import copy


def findSlot(pool):
  for i,slot in enumerate(pool):
    if slot == 0 or slot.state == 0:
      return i
  return None

class Simulator:
    def __init__(self):
      print("simulator starts")
      self.mem = {}
      self.threads = [0]*8
      self.instr = []


    def load_instr(self,file_name):
      with open(file_name) as lines:
        for line in lines:
          self.instr.append(line)
      return

    def execute_program(self):
      print(self.instr)
      return

    def run(self, file_name):
      self.load_instr(file_name)
      self.threads[0] = Thread() #root thread
      self.execute_program()
      return 




class Thread:
    def __init__(self, id = 0, pc=0, stack=[], regs = [0]*32, parent = None):
      self.id = id
      self.stack = copy.deepcopy(stack)
      self.pc = copy.deepcopy(pc)
      self.regs = copy.deepcopy(regs)
      self.parent = parent
      self.children = []
      self.state = 1

    def create(self, id):
      self.children.append(Thread(id=id, pc=self.pc+1, stack=self.stack, regs=self.regs,
        parent=self))
      return self.children[-1]

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
  s.run('./test_input.txt')
  


