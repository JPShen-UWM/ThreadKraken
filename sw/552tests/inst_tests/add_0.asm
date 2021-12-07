// Original test: ./ziliang/hw4/problem6/add_0.asm
// Author: ziliang
// Test source code follows


//This mainly tests the forwarding problems that can happen
//if people messed up passing values between their pipelines.

lbi r22, 100	//load 100 into r22
lbi r23, 99	//load 99 into r23
add r24, r22, r23	//expected r24 = 199 or x00c7
add r23, r24, r22	//expected r23 = 299 or x012b
add r25, r22, r23	//expected r25 = 399 or x018f
add r26, r23, r22	//expected r26 = 399 or x018f
add r27, r22, r25	//expected r27 = 499 or x01f3
add r25, r27, r22	//expected r25 = 599 or x0257

kill r1
