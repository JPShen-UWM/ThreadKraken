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

    // Register
    output  logic   [31:0]  data_a_exe  ,
    output  logic   [31:0]  data_b_exe  ,
    output  logic   [31:0]  pc_exe      ,
    output  logic   [31:0]  ins_exe     ,

    // Decode
    output  logic   [4:0]   reg_rd_a    ,
    output  logic   [4:0]   reg_rd_b    ,
    output  logic   [4:0]   reg_wr      ,
    output  logic   [15:0]  imm         ,
    output  logic           wr_en       ,
    output  logic           alu_op      ,
    output  logic   [1:0]   mem_ctrl    ,
    output  logic   [1:0]   trd_ctrl    ,
    output  logic           init        ,
    output  logic           exp_jmp     ,
    output  logic           exp_return  ,
    output  logic   [3:0]   jmp_con     ,
    output  logic           invalid     ,
    output  logic           i_type 
);

<<<<<<< Updated upstream
// Test

    // Decode
    decode DECODE
    (
        .ins         (ins_dec     ),
        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .imm         (imm         ),
        .wr_en       (wr_en       ),
        .alu_op      (alu_op      ),
        .mem_ctrl    (mem_ctrl    ),
        .trd_ctrl    (trd_ctrl    ),
        .init        (init        ),
        .exp_jmp     (exp_jmp     ),
        .exp_return  (exp_return  ),
        .jmp_con     (jmp_con     ),
        .invalid     (invalid     ),
        .i_type      (i_type )
    );
=======
>>>>>>> Stashed changes
// Test