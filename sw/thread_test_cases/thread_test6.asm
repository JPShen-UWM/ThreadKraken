addi r6 r0 256 // load r0 its thread id
addi r6 r6 256 // load r0 its thread id
addi r6 r6 256 // load r0 its thread id
addi r6 r6 256 // load r0 its thread id
addi r6 r6 256 // load r0 its thread id
lbi r5 1
slbi r5 0x400
ld r26 r5 0
addi r26 r26 1 // loop
addi r6 r6 -1 // Increment r6 by 1
st r5 r26 0
bneq r6 r0 -5
kill r1