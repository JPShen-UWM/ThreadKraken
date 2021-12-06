addi r21 r0 0xFF
# jump to halt 
jal r20 2 
addi r22 r0 0x1
add r23 r21 r22
# halt
kill r0