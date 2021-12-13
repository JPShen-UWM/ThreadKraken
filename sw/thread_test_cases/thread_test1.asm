// Create several new thread and kill them
lbi r19 1
slbi r19 0x0100 // r19 is at start pc
addi r19 r19 13 // r19 is pointing to function 1
lbi r21 1
slbi r21 0x0400 // r21 is pointing to heap
nt r26 r19 r21
addi r22 r21 1 // r22 = r21 + 1
nt r26 r19 r22
// loop
ld r23 r21 0
ld r24 r22 0
beq r23 r0 -3
beq r24 r0 -4
kill r1 // exist

// function 1 store thread id to return memory
st r4, r1, 0
st r1, r1, 0
kill r1
