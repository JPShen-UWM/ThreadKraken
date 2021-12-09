.gg
add r1, r2, r3
addi r3, r2, 0xFF
addi r1, r2, -1
not r5, r10
and r2, r1, r3
or r4,r2,r1
xor r5, r3 ,r1
addi r1, r1, 5
// addi r31, r10, -1000
// addi r3, r10, -0x7FF
// addi r3, r10, 0x13
// andi r5,r6, 0x0FF
ORI r0, r0, 1
// xORI r7, r8, 0x26F
shlt r0,r0, 0xF
addi r31, r31, 0xFF
shra r31,r31, 0x04
lbi r10, 0xFF
slbi r10, 0x01
// sta r1,r31, 0x0FF
lbi r1, 15
//jalr r0, r1, 1
jal r0, 0
lbi r2, 15
beq r1, r2 1

andi r1, r1, 0
andi r2, r2, 0
lbi r2, 0x77
st r1,r2, 0x10E00
ld r2,r1, 0x10E00
.why
addi r31, r31, 0xFF
// jalr r31, r1, 0x234
// 
// .why
// beq r1,r4, 45
// 
// JAL r1, .why
// beq r0,r1, .gg
addi r31, r31, 0xFF
// slp r3
andi r1, r1, 0
lbi r1, 29
nt r0 r1 r2
andi r1, r1, 0
andi r1, r1, 0
andi r1, r1, 0


