lbi r21 50
lbi r22 1
slbi r22 0x400
st r22 r21 0

ld r30 r22 0
addi r30 r30 5
addi r30 r0 5
st r22 r30 1

ld r31 r22 1
addi r31 r31 5
addi r31 r0 1
kill r1
