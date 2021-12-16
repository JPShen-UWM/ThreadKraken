/*
 * Module name: thread_csr
 * Engineer: Jianping Shen
 * Description: Main thread control status register for each thread and their PC
 * Dependency:
 * Status: developing
 */

//`include "header.svh"

module thread_csr_6
(
    input               clk,
    input               rst_n,

    input               init,       // Initialize this thread
    input [31:0]        init_pc,    // Start pc
    input               slp,        // Sleep this thread
    input               kill,       // Kill this thread
    input               wake,       // Wake up this thread
    input [2:0]         obj_trd,    // Global objective thread
    input [2:0]         act_trd,    // Global action thread
    input [31:0]        nxt_pc,     // Next PC
    input               pc_wr,      // Write next PC

    output logic [31:0] cur_pc,     // Current PC of this thread
    output logic [2:0]  par_trd,    // Parent thread
    output logic        valid,      // This thread is valid
    output logic        running,    // This thread is running        
    output logic        error
);
logic [2:0] TRD_ID;
assign TRD_ID = 3'h6;
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
    // Status register
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            valid <= 1'b0;
            running <= 1'b0;
            par_trd <= 3'b0;
        end
        else if (init & obj_trd == TRD_ID) begin
            valid <= 1'b1;
            running <= 1'b1;
            par_trd <= act_trd;
        end
        else if (slp & obj_trd == TRD_ID & (act_trd == par_trd | act_trd == TRD_ID)) begin
            running <= 1'b0;
        end
        else if (wake & obj_trd == TRD_ID & valid) begin
            running <= 1'b1;
        end
        else if (kill & obj_trd == TRD_ID & valid & (act_trd == par_trd | act_trd == TRD_ID)) begin
            valid <= 1'b0;
            running <= 1'b0;
        end
    end

    // PC register
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin 
            cur_pc <= START_PC;
        end
        else if(init & obj_trd == TRD_ID) begin
            cur_pc <= init_pc;
        end
        else if(pc_wr) begin
            cur_pc <= nxt_pc;
        end
    end

    // Error detector
    always_comb begin
        error = 0;
        if (obj_trd == TRD_ID & (act_trd != par_trd & act_trd != TRD_ID) & (slp|kill)) 
            error = 1;
        if (init & obj_trd == TRD_ID & valid) 
            error = 1;
    end
endmodule