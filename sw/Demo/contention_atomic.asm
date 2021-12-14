// check atomic 
bneq r1 r0 .child
lbi r19 1
slbi r19 0x0100  // r19 is at start pc
lbi r21 1 
slbi r21 0x0400  // r21 is pointing to heap
addi r25 r21 2   // r25 = 0x10402
st r25 r0 0      // i: mem[0x10402] = 0
addi r20 r21 1
nt r26 r19 r21
nt r26 r19 r20
slp r0
addi r0 r0 0
ld r22 r21 0
addi r0 r0 0
beq r22 r0 -4
ld r23 r20 0
addi r0 r0 0
beq r23 r0 -7
st r0  r22 0
st r0  r23 1
kill r1

.child
lbi r25 1
slbi r25 0x0402
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
addi r6 r6 1024  //16 * 1024 = 2**14 = 0x400
addi r26 r0 0

.loop
adda r26 r26 r1 

lda r10 r25 0
adda r10 r10 r1 
sta r25 r10 0

addi r6 r6 -1 // Increment r6 by 1
bneq r6 r0 .loop
st r4 r26 0
wk r0
kill r1  // return