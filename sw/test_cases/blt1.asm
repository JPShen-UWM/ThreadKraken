# r21 > r22, should not jump
lbi r21 50
lbi r22 20
blt r21 r22 2
add r21 r0 r0
add r22 r0 r0

#now r21 == r22 should not jump
blt r21 r22 2
addi r21 r0 1
addi r22 r0 15

# now jump
blt r21 r22 1
lbi r21 0

kill r0