/*
 * Module name: pc_cal
 * Engineer: Jianping Shen
 * Description: Calculate jump pc in branching or jump
 * Dependency:
 * Status: developing
**/
//`include "header.svh"
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
module pc_cal(
    input           [31:0]  cur_pc  ,
    input           [11:0]  imm     ,
    input           [31:0]  data_a  ,
    input           [3:0]   jmp_con ,
    input                   eq      ,
    input                   lt      ,
    
    output  logic   [31:0]  jmp_pc  ,
    output  logic           jmp_en
);

    // jmp_con: jmp condition
    // 0001: equal
    // 0010: little
    // 0100: not equal
    // 0111: reference unconditional jump
    // 1111: non-reference unconditional jump

    logic [31:0] imm_ext;
    assign imm_ext = {{20{imm[11]}}, imm};

    always_comb begin
        jmp_pc = HANDLER;
        jmp_en = 0;

        case(jmp_con)
            4'b0001: begin
                if(eq) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0010: begin
                if(lt) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0100: begin
                if(!eq) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0111: begin
                jmp_pc = cur_pc + 1 + imm_ext;
                jmp_en = 1;
            end
            4'b1111: begin
                jmp_pc = data_a + imm_ext;
                jmp_en = 1;
            end
        endcase
    end

endmodule