addi r6 r0 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r6 r6 1024 // load r0 its thread id
addi r26 r0 0
add r26 r26 r1 // loop
addi r6 r6 -1 // Increment r6 by 1
bneq r6 r0 -3
kill r1