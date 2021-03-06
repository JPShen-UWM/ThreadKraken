/*
 * Module name: decode
 * Engineer: Jianping Shen
 * Description: Decoder
 * Dependency:
 * Status: developing
**/
//`include "header.svh"
module decode
(
    input           [31:0]  ins         ,

    output  logic   [4:0]   reg_rd_a    ,
    output  logic   [4:0]   reg_rd_b    ,
    output  logic   [4:0]   reg_wr      ,
    output  logic   [15:0]  imm         ,

    output  logic           wr_en       ,
    output  logic   [2:0]   alu_op      ,
    output  logic   [1:0]   mem_ctrl    ,
    output  logic   [2:0]   trd_ctrl    ,
    output  logic           wb_sel      ,
    output  logic           init        ,
    output  logic           exp_jmp     ,
    output  logic           exp_return  ,
    output  logic   [3:0]   jmp_con     ,
    output  logic           invalid     ,
    output  logic           i_type 
);

    // Operation code
parameter CAL       =   4'b1111;
parameter CALI      =   4'b1110;
parameter SHIFT     =   4'b1100;
parameter LOADI     =   4'b1001;
parameter MEMOP     =   4'b1000;
parameter BRANCH    =   4'b1010;
parameter EXC       =   4'b0000;
parameter MULTI     =   4'b0110;

// Function code
parameter ADD       =   3'b110;
parameter NOT       =   3'b000;
parameter AND       =   3'b111;
parameter OR        =   3'b101;
parameter XOR       =   3'b011;
parameter SHLT      =   3'b001;
parameter SHRT      =   3'b010;
parameter SHAR      =   3'b100;
parameter LBI       =   3'b001;
parameter SLB       =   3'b010;

// PC Address
parameter START_PC  =   32'h0001_0100;
parameter HANDLER   =   32'h0001_0000;

// Init and end stack for each thread
parameter TRD0_INIT_ESP = 32'h0001_0FFF;
parameter TRD1_INIT_ESP = 32'h0001_0DFF;
parameter TRD2_INIT_ESP = 32'h0001_0CFF;
parameter TRD3_INIT_ESP = 32'h0001_0BFF;
parameter TRD4_INIT_ESP = 32'h0001_0AFF;
parameter TRD5_INIT_ESP = 32'h0001_09FF;
parameter TRD6_INIT_ESP = 32'h0001_08FF;
parameter TRD7_INIT_ESP = 32'h0001_07FF;

parameter TRD0_END_ESP = 32'h0001_0E00;
parameter TRD1_END_ESP = 32'h0001_0D00;
parameter TRD2_END_ESP = 32'h0001_0C00;
parameter TRD3_END_ESP = 32'h0001_0B00;
parameter TRD4_END_ESP = 32'h0001_0A00;
parameter TRD5_END_ESP = 32'h0001_0900;
parameter TRD6_END_ESP = 32'h0001_0800;
parameter TRD7_END_ESP = 32'h0001_0700;
    // wb_sel:
    // 0: write back from exe output
    // 1: write back from mem read
    
    // mem_ctrl:
    // 01: read
    // 10: write

    // trd_ctrl:
    // 001: sleep
    // 010: wake
    // 011: kill
    // 111: init_trd

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
    assign reg_rd_b = (ins[4:1]==BRANCH | ins[4:1]==MEMOP | ins[4:1]==LOADI)? ins[31:27] : ins[21:17];
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
        wb_sel = 0;
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
                    wb_sel = 1;
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
            end
            MULTI: begin
                if(funct == 3'b111) begin
                    wr_en = 1;
                    init = 1;
                    trd_ctrl = 7;
                end
                else if(funct == 3'b101) trd_ctrl = 1;
                else if(funct == 3'b010) trd_ctrl = 2;
                else if(funct == 3'b000) trd_ctrl = 3;
                else invalid = 1;
            end
        endcase
    end
endmodule