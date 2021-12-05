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
    input                   clk             ,
    input                   rst_n           ,

    input           [31:0]  ins_dec         ,
    input           [2:0]   new_trd_id      ,
    input           [2:0]   trd_dec         ,
    input           [31:0]  pc_dec          ,
    input                   flushID         ,

    input           [2:0]   wr_trd_wb       ,
    input           [31:0]  data_wb         ,
    input           [4:0]   wr_reg_wb       ,
    input                   wr_en_wb        ,

    // Register 
    output  logic   [31:0]  data_a_exe      ,
    output  logic   [31:0]  data_b_exe      ,
    output  logic   [31:0]  pc_exe          ,
    output  logic   [31:0]  ins_exe         ,
    output  logic   [2:0]   trd_exe         ,
    output  logic           init_trd_dec    ,

    // Decode
    output  logic   [4:0]   reg_rd_a_exe    ,
    output  logic   [4:0]   reg_rd_b_exe    ,
    output  logic   [4:0]   reg_wr_exe      ,
    output  logic   [15:0]  imm_exe         ,
    output  logic           wr_en_exe       ,
    output  logic           wb_sel_exe      ,
    output  logic   [2:0]   alu_op_exe      ,
    output  logic   [1:0]   mem_ctrl_exe    ,
    output  logic   [1:0]   trd_ctrl_exe    ,
    output  logic           exp_jmp_dec     ,
    output  logic           exp_return_dec  ,
    output  logic   [3:0]   jmp_con_exe     ,
    output  logic           invalid_op      ,
    output  logic           i_type_exe      ,
    output  logic           init_trd_exe    ,
    output  logic   [2:0]   new_trd_exe  
);

    logic   [4:0]   reg_rd_a    ;
    logic   [4:0]   reg_rd_b    ;
    logic   [4:0]   reg_wr      ;
    logic   [15:0]  imm         ;
    logic           wr_en       ;
    logic   [2:0]   alu_op      ;
    logic   [1:0]   mem_ctrl    ;
    logic   [1:0]   trd_ctrl    ;
    logic           init        ;
    logic   [3:0]   jmp_con     ;
    logic           invalid     ;
    logic           i_type      ;
    logic           wb_sel      ;

    // Decode
    decode DECODE
    (
        .ins         (ins_dec       ),
        .reg_rd_a    (reg_rd_a      ),
        .reg_rd_b    (reg_rd_b      ),
        .reg_wr      (reg_wr        ),
        .imm         (imm           ),
        .wr_en       (wr_en         ),
        .alu_op      (alu_op        ),
        .mem_ctrl    (mem_ctrl      ),
        .trd_ctrl    (trd_ctrl      ),
        .wb_sel      (wb_sel        ),
        .init        (init_trd_dec  ),
        .exp_jmp     (exp_jmp_dec   ),
        .exp_return  (exp_return_dec),
        .jmp_con     (jmp_con       ),
        .invalid     (invalid_op    ),
        .i_type      (i_type        )
    );

    regfile_set REGFILE_SET
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),
        .trd_dec     (trd_dec     ),
        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .wr_trd      (wr_trd_wb   ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_data     (data_wb     ),
        .init        (init_trd_dec),
        .init_trd    (new_trd_id  ),
        .rd_data_a   (data_a_exe  ),
        .rd_data_b   (data_b_exe  ) 
    );

    // dec/exe pipeline
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n | flushID) begin
            pc_exe          <= 0;
            ins_exe         <= 0;
            reg_rd_a_exe    <= 0;
            reg_rd_b_exe    <= 0;
            reg_wr_exe      <= 0;
            imm_exe         <= 0;
            wr_en_exe       <= 0;
            alu_op_exe      <= 0;
            mem_ctrl_exe    <= 0;
            trd_ctrl_exe    <= 0;
            jmp_con_exe     <= 0;
            wb_sel_exe      <= 0;
            i_type_exe      <= 0;
            init_trd_exe    <= 0;
            new_trd_exe     <= 0;
        end
        else begin
            pc_exe          <= pc_dec;
            ins_exe         <= ins_dec;
            reg_rd_a_exe    <= reg_rd_a;
            reg_rd_b_exe    <= reg_rd_b;
            reg_wr_exe      <= reg_wr;
            imm_exe         <= imm;
            wr_en_exe       <= wr_en;
            alu_op_exe      <= alu_op;
            mem_ctrl_exe    <= mem_ctrl;
            trd_ctrl_exe    <= trd_ctrl;
            jmp_con_exe     <= jmp_con;
            i_type_exe      <= i_type;
            wb_sel_exe      <= wb_sel;
            init_trd_exe    <= init_trd_dec;
            new_trd_exe     <= new_trd_id;
        end
    end
endmodule