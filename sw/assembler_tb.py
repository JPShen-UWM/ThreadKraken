import assembler
from assembler import imm_to_bin


def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

if __name__ == '__main__':

    # print(bindigits(5, 12))