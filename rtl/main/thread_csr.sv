/*
 * Module name: thread_csr
 * Engineer: Jianping Shen
 * Description: Main thread control status register for each thread and their PC
 * Dependency:
 * Status: developing
 */

`include "header.svh"

module thread_crs #( parameter TRD_ID = 0 )
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

    // Status register
    always_ff @(posedge clk, negedge rst_n) begin
        if(rst_n) begin
            valid <= 1'b0;
            running <= 1'b0;
            par_trd <= 3'b0;
        end
        else if (init & obj_trd == TRD_ID) begin
            valid <= 1'b1;
            running <= 1'b1;
            par_trd <= act_trd;
        end
        else if (slp & obj_trd == TRD_ID & act_trd == par_trd) begin
            running <= 1'b0;
        end
        else if (wake & obj_trd == TRD_ID & valid) begin
            running <= 1'b1;
        end
        else if (kill & obj_trd == TRD_ID & valid & act_trd == par_trd) begin
            valid <= 1'b0;
            running <= 1'b0;
        end
    end

    // PC register
    always_ff @(posedge clk, negedge rst_n) begin
        if(rst_n) begin 
            cur_pc <= START_PC;
        end
        else if(pc_wr) begin
            cur_pc <= nxt_pc;
        end
    end

    // Error detector
    always_comb begin
        error = 0;
        if (obj_trd == TRD_ID & act_trd != par_trd & (slp|kill)) 
            error = 1;
        if (init & obj_trd == TRD_ID & valid) 
            error = 1;
    end
endmodule