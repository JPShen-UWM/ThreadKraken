lbi r19 1   // Heavy test of thread_test2
slbi r19 0x0100 // r19 is at start pc
addi r19 r19 15 // r19 is pointing to function 1
lbi r21 1
slbi r21 0x0400 // r21 is pointing to heap
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
ld r22 r21 0
beq r22 r0 -2
ld r23 r21 -1
beq r23 r0 -2
st r0  r22 0
st r0  r23 1
kill r1 // exist // 
addi r6 r0 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r26 r0 0
add r26 r26 r1 // loop
addi r6 r6 -1 // Increment r6 by 1
bneq r6 r0 -3
st r4 r26 0
kill r1  // return