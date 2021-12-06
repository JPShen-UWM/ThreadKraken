# r21 != r22, should not jump
lbi r21 50
lbi r22 20
beq r21 r22 2
add r21 r0 r0
add r22 r0 r0

#should not jump to here
kill r0