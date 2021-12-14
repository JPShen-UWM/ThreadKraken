// check atomic 
bneq r1 r0 .child //will not jump
lbi r19 1
slbi r19 0x0100  // r19 is at start pc
lbi r21 1 
slbi r21 0x0400  // r21 is pointing to heap
addi r25 r21 2   // r25 = 0x10402

addi r7 r0 10
st r25 r7 0      // i: mem[0x10402] = 10

lbi r12 1
slbi r12 0xFF


.loop
ld r10 r25 0      //r10 = i  
addi r10 r10 1    //r10 += 1
st r25 r10 0      //i = r10

blt r10 r12 .loop  // jump if  i < 0x100FF 

shrt r10 r10 8        //r10 = 1

not r10 r10
shra r10 r10 8
st r0 r10 0       //0x0 : 0xFFFFFFFE
and r11 r10 r21   //r11 = heap start
ld r11 r11 2
st r0 r11 1       //0x1: i= 0x100ff


jal r8 0    //skip kill and jmp to next
beq r8 r0 -1
st r0 r8 2        //get current pc

.child
kill r1  // return