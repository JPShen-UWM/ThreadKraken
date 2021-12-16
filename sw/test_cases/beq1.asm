# r21 != r22, should not jump
lbi r21 50
lbi r22 20
beq r21 r22 2
addi r21 r0 0xFE
addi r22 r0 0X01

#should not jump to here
kill r0