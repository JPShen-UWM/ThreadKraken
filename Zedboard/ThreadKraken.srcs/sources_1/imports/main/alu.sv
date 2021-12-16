/*
 * Module name: alu
 * Engineer: Jianping Shen
 * Description: alu module for exe stage
 * Dependency:
 * Status: testing
 */
//`include "header.svh"
module alu(
    input  logic [31:0] Ain,
    input  logic [31:0] Bin,
    input  logic [15:0] imm,        // Three type of immediate
    input  logic [2:0]  alu_op,
    input  logic        i_type,     // 1 for using immediate as Bin
    output logic [31:0] alu_out,
    output logic        eq,         // 1 for Ain == Bin
    output logic        lt,         // 1 for Ain < Bin
    output logic        overflow    // high when overflow happen
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
    /*
        alu_op:
        110: a + b
        000: !a
        111: a & b
        101: a | b
        011: a ^ b
        001: a << imm
        010: a >>> imm
        100: a >> imm arithmetic
        001, i_type = 1: rd[15:0]=imm
        010, i_type = 1: rd<<16|imm
    */

    // Internal logic
    logic [31:0] imm_ext;
    logic [31:0] imm_sel;
    logic sign_ext;
    logic [31:0] b_sel;
    logic [31:0] sum;
    logic [31:0] or_r;
    logic [31:0] and_r;
    logic [31:0] xor_r;
    logic [31:0] cal_out;
    logic [31:0] dif;

    assign alu_out = cal_out;

    // Input select
    assign sign_ext = alu_op == 3'b110;
    assign imm_ext = sign_ext? {{20{imm[11]}},imm[11:0]} : {20'b0,imm[11:0]};
    assign imm_sel = (alu_op == 3'b001 | alu_op == 3'b010)? {16'b0,imm[15:0]} : imm_ext;
    assign b_sel = i_type? imm_sel: Bin;
    

    // Calculation
    assign sum = Ain + b_sel;
    assign or_r = Ain | b_sel;
    assign and_r = Ain & b_sel;
    assign xor_r = Ain ^ b_sel;

    // Shift
    logic [31:0] shlt0, shlt1, shlt2, shlt3, shlt4;
    logic [31:0] shrt0, shrt1, shrt2, shrt3, shrt4;
    logic [31:0] shar0, shar1, shar2, shar3, shar4;

    // Shift left
    assign shlt0 = imm[0]? {Ain[30:0], 1'b0}: Ain;
    assign shlt1 = imm[1]? {shlt0[29:0], 2'b0}: shlt0;
    assign shlt2 = imm[2]? {shlt1[27:0], 4'b0}: shlt1;
    assign shlt3 = imm[3]? {shlt2[23:0], 8'b0}: shlt2;
    assign shlt4 = imm[4]? {shlt3[15:0],16'b0}: shlt3;

    // Shift right unsigned
    assign shrt0 = imm[0]? { 1'b0, Ain[31: 1]}: Ain;
    assign shrt1 = imm[1]? { 2'b0, shrt0[31: 2]}: shrt0;
    assign shrt2 = imm[2]? { 4'b0, shrt1[31: 4]}: shrt1;
    assign shrt3 = imm[3]? { 8'b0, shrt2[31: 8]}: shrt2;
    assign shrt4 = imm[4]? {16'b0, shrt3[31:16]}: shrt3;

    // Shift right arithmetic
    assign shar0 = imm[0]? {{ 1{Ain[31]}}, Ain[31: 1]}: Ain;
    assign shar1 = imm[1]? {{ 2{shar0[31]}}, shar0[31: 2]}: shar0;
    assign shar2 = imm[2]? {{ 4{shar1[31]}}, shar1[31: 4]}: shar1;
    assign shar3 = imm[3]? {{ 8{shar2[31]}}, shar2[31: 8]}: shar2;
    assign shar4 = imm[4]? {{16{shar3[31]}}, shar3[31:16]}: shar3;  

    assign cal_out = (alu_op == ADD)? sum:
                     (alu_op == AND)? and_r:
                     (alu_op == OR)? or_r:
                     (alu_op == XOR)? xor_r:
                     (alu_op == NOT)? ~Ain:
                     (alu_op == SHLT)? (i_type? {16'b0, imm}: shlt4):
                     (alu_op == SHRT)? (i_type? {Bin[15:0], imm}: shrt4):
                     (alu_op == SHAR)? shar4: 32'h0;

    assign dif = Ain - b_sel;
    assign eq = ~(|dif);
    assign lt = dif[31];

    always_comb begin
        overflow = 1'b0;
        if(alu_op == ADD) begin
            if(sum[31] != Ain[31]&b_sel[31]) overflow = 1'b1;
        end
        if(Ain[31] != b_sel[31]) overflow = 1'b0;
    end
endmodule