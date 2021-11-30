/*
 * Module name: insdec
 * Engineer: Jianping Shen
 * Description: Instruction Decode/register stage
 * Dependency: decode, regfile_set, regfile
 * Status: developing
**/
`include "header.svh"
module insdec
(
    input                   clk         ,
    input                   rst_n       ,

    input           [31:0]  ins_dec     ,
    input           [2:0]   new_trd     ,
    input           [2:0]   trd_dec     ,
    input           [31:0]  pc_dec      ,
    input                   flushID     ,


);
