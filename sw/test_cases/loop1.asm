//simple test

lbi r21 0xFF  //
lbi r22 0x1
lbi r2 0
lbi r3 5

.start
add r23 r21 r22
addi r2 r2 1
bneq r2 r3 .start
st r0 r2 0
st r0 r23 1


# halt
kill r1
