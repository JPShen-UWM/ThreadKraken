lbi r19 1 // working
slbi r19 0x0100 // r19 is at start pc
addi r19 r19 13 // r19 is pointing to function 1
lbi r21 0x0000
slbi r21 0x0040
nt r26 r19 r21
slp r1
addi r0 r0 0
st r0 r21 0
st r0 r19 1
st r0 r26 2
st r0 r21 3
kill r0
addi r4 r4 -1
bneq r0 r4 -2
wk r0
kill r1