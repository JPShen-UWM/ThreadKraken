bneq r1 r0 13
lbi r19 1
slbi r19 0x0100 // r19 is at start pc
lbi r21 1
slbi r21 0x0400 // r21 is pointing to heap
nt r26 r19 r21
addi r21 r21 1 // r21 = r21 + 1
nt r26 r19 r21
slp r0
ld r22 r21 0
ld r23 r21 -1
st r0  r22 0
st r0  r23 1
kill r1
addi r6 r0 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r6 r6 1024
addi r26 r0 0
add r26 r26 r1 // loop
addi r6 r6 -1 // Increment r6 by 1
st r4 r26 0
bneq r6 r0 -4
wk r0
kill r1  // return