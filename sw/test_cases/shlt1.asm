lbi r21, 0
slbi r21, 0xFFFF
shlt r22, r21, 16  //should be FFFF0000
kill r0