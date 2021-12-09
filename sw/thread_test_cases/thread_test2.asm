lbi r19 1   // create 5 new thread and run function 1
slbi r19 0x0100 // r19 is at start pc
addi r19 r19 26 // r19 is pointing to function 1
lbi r21 1
slbi r21 0x0400 // r21 is pointing to heap
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
slp r1 //-------------------loop
ld r22 r21 0
beq r22 r0 -3
ld r22 r21 -1
beq r22 r0 -5
ld r22 r21 -2
beq r22 r0 -7
ld r22 r21 -3
beq r22 r0 -9
ld r22 r21 -4
beq r22 r0 -11
kill r1 // exist // function 1 do add five ten times and store thread id to return memory ------------------
addi r6 r0 0 // load r0 its thread id
addi r26 r0 0
addi r26 r26 16 // add 16 to r26
addi r6 r6 1 // Increment r6 by 1
bneq r6 r1 -3
st r4 r26 0
wk r0
kill r1  // return