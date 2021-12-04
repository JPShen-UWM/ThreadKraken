/*
 * Module name: decode
 * Engineer: Jianping Shen
 * Description: Decoder
 * Dependency:
 * Status: developing
**/
`include "header.svh"
module decode
(
    input           [31:0]  ins         ,

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

    // mem_ctrl:
    // 01: read
    // 10: write

    // trd_ctrl:
    // 01: sleep
    // 10: wake
    // 11: kill

    // i_type:
    // 0: data_b as Bin
    // 1: imm as Bin

    // invalid: invalid operation

    // init: init a new thread

    // jmp_con: jmp condition
    // 0001: equal
    // 0010: little
    // 0100: not equal
    // 0111: reference unconditional jump
    // 1111: non-reference unconditional jump

    logic [2:0] funct;
    assign funct = ins[7:5];

    assign imm = ins[25:10];
    assign reg_rd_a = ins[26:22];
    assign reg_rd_b = (ins[4:1]==BRANCH | ins[4:1]==MEMOP)? ins[31:27] : ins[21:17];
    assign reg_wr = ins[31:27];
    assign alu_op = ins[7:5];

    always_comb begin
        wr_en = 0;
        mem_ctrl = 0;
        trd_ctrl = 0;
        jmp_con = 0;
        init = 0;
        exp_jmp = 0;
        exp_return = 0;
        invalid = 0;
        i_type = 0;
        case(ins[4:1])
            CAL: begin
                wr_en = 1;
                i_type = 0;
            end
            CALI: begin
                wr_en = 1;
                i_type =  1;
            end
            SHIFT: begin
                wr_en = 1;
                i_type = 0;
            end
            LOADI: begin
                i_type = 1;
                wr_en = 1;
            end
            MEMOP: begin
                i_type = 1;
                if(ins[8]) begin
                    mem_ctrl = 1;
                    wr_en = 1;
                end
                else begin
                    mem_ctrl = 2;
                end
            end
            BRANCH: begin
                if(funct == 3'b000) begin 
                    jmp_con = 4'b0111;
                    wr_en = 1;
                end
                else if(funct == 3'b010) begin
                    jmp_con = 4'b1111;
                    wr_en = 1;
                end
                else if(funct == 3'b001) jmp_con = 4'b0001;
                else if(funct == 3'b011) jmp_con = 4'b0100;
                else if(funct == 3'b111) jmp_con = 4'b0010;
                else invalid = 1;
            end
            EXC: begin
                if(ins[5]) exp_jmp = 1;
                else if(ins[6]) exp_return = 1;
                else invalid = 1;
            end
            MULTI: begin
                if(funct == 3'b111) begin
                    wr_en = 1;
                    init = 1;
                end
                else if(funct == 3'b101) trd_ctrl = 1;
                else if(funct == 3'b010) trd_ctrl = 2;
                else if(funct == 3'b000) trd_ctrl = 3;
                else invalid = 1;
            end
        endcase
    end
endmodule