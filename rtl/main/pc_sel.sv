/*
 * Module name: pc_sel
 * Engineer: Jianping Shen
 * Description: pc selector and incrementor
 * Dependency:
 * Status: developing
**/

//`include "header.svh"

module pc_sel
(
    input                   clk         ,
    input                   rst_n       ,
    input       [2:0]       cur_trd     ,
    input       [31:0]      cur_pc      ,
    input       [2:0]       jmp_trd     ,
    input       [31:0]      jmp_pc      ,
    input                   jmp         ,
    input       [2:0]       i_miss_trd  ,
    input       [31:0]      i_miss_pc   ,
    input                   i_miss      ,
    input       [2:0]       d_miss_trd  ,
    input       [31:0]      d_miss_pc   ,
    input                   d_miss      ,
    input                   jmp_exp     ,
    input                   exp_mode    ,
    input                   return_op   ,
    input                   stall       ,
    input                   i_rd        ,

    output  logic   [31:0]  nxt_pc_0    ,
    output  logic   [31:0]  nxt_pc_1    ,
    output  logic   [31:0]  nxt_pc_2    ,
    output  logic   [31:0]  nxt_pc_3    ,
    output  logic   [31:0]  nxt_pc_4    ,
    output  logic   [31:0]  nxt_pc_5    ,
    output  logic   [31:0]  nxt_pc_6    ,
    output  logic   [31:0]  nxt_pc_7    ,
    output  logic   [7:0]   pc_wr   
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
    logic[31:0] epc; // Return PC from exception
    always_comb begin
        nxt_pc_0 = HANDLER;
        nxt_pc_1 = HANDLER;
        nxt_pc_2 = HANDLER;
        nxt_pc_3 = HANDLER;
        nxt_pc_4 = HANDLER;
        nxt_pc_5 = HANDLER;
        nxt_pc_6 = HANDLER;
        nxt_pc_7 = HANDLER;
        pc_wr = 0;

        // Thread 0
        if(d_miss_trd == 0 & d_miss) begin
            nxt_pc_0 = d_miss_pc;
            pc_wr[0] = 1;
        end
        else if(i_miss_trd == 0 & i_miss) begin
            nxt_pc_0 = i_miss_pc;
            pc_wr[0] = 1;
        end
        else if(jmp_trd == 0 & jmp & !stall) begin
            nxt_pc_0 = jmp_pc;
            pc_wr[0] = 1;
        end
        else if(cur_trd == 0 & !stall) begin
            nxt_pc_0 = cur_pc + 1;
            pc_wr[0] = i_rd;
        end

        // Thread 1
        if(d_miss_trd == 1 & d_miss) begin
            nxt_pc_1 = d_miss_pc;
            pc_wr[1] = 1;
        end
        else if(i_miss_trd == 1 & i_miss) begin
            nxt_pc_1 = i_miss_pc;
            pc_wr[1] = 1;
        end
        else if(jmp_trd == 1 & jmp & !stall) begin
            nxt_pc_1 = jmp_pc;
            pc_wr[1] = 1;
        end
        else if(cur_trd == 1 & !stall) begin
            nxt_pc_1 = cur_pc + 1;
            pc_wr[1] = i_rd;
        end

        // Thread 2
        if(d_miss_trd == 2 & d_miss) begin
            nxt_pc_2 = d_miss_pc;
            pc_wr[2] = 1;
        end
        else if(i_miss_trd == 2 & i_miss) begin
            nxt_pc_2 = i_miss_pc;
            pc_wr[2] = 1;
        end
        else if(jmp_trd == 2 & jmp & !stall) begin
            nxt_pc_2 = jmp_pc;
            pc_wr[2] = 1;
        end
        else if(cur_trd == 2 & !stall) begin
            nxt_pc_2 = cur_pc + 1;
            pc_wr[2] = i_rd;
        end

        // Thread 3
        if(d_miss_trd == 3 & d_miss) begin
            nxt_pc_3 = d_miss_pc;
            pc_wr[3] = 1;
        end
        else if(i_miss_trd == 3 & i_miss) begin
            nxt_pc_3 = i_miss_pc;
            pc_wr[3] = 1;
        end
        else if(jmp_trd == 3 & jmp & !stall) begin
            nxt_pc_3 = jmp_pc;
            pc_wr[3] = 1;
        end
        else if(cur_trd == 3 & !stall) begin
            nxt_pc_3 = cur_pc + 1;
            pc_wr[3] = i_rd;
        end

        // Thread 4
        if(d_miss_trd == 4 & d_miss) begin
            nxt_pc_4 = d_miss_pc;
            pc_wr[4] = 1;
        end
        else if(i_miss_trd == 4 & i_miss) begin
            nxt_pc_4 = i_miss_pc;
            pc_wr[4] = 1;
        end
        else if(jmp_trd == 4 & jmp & !stall) begin
            nxt_pc_4 = jmp_pc;
            pc_wr[4] = 1;
        end
        else if(cur_trd == 4 & !stall) begin
            nxt_pc_4 = cur_pc + 1;
            pc_wr[4] = i_rd;
        end

        // Thread 5
        if(d_miss_trd == 5 & d_miss) begin
            nxt_pc_5 = d_miss_pc;
            pc_wr[5] = 1;
        end
        else if(i_miss_trd == 5 & i_miss) begin
            nxt_pc_5 = i_miss_pc;
            pc_wr[5] = 1;
        end
        else if(jmp_trd == 5 & jmp & !stall) begin
            nxt_pc_5 = jmp_pc;
            pc_wr[5] = 1;
        end
        else if(cur_trd == 5 & !stall) begin
            nxt_pc_5 = cur_pc + 1;
            pc_wr[5] = i_rd;
        end

        // Thread 6
        if(d_miss_trd == 6 & d_miss) begin
            nxt_pc_6 = d_miss_pc;
            pc_wr[6] = 1;
        end
        else if(i_miss_trd == 6 & i_miss) begin
            nxt_pc_6 = i_miss_pc;
            pc_wr[6] = 1;
        end
        else if(jmp_trd == 6 & jmp & !stall) begin
            nxt_pc_6 = jmp_pc;
            pc_wr[6] = 1;
        end
        else if(cur_trd == 6 & !stall) begin
            nxt_pc_6 = cur_pc + 1;
            pc_wr[6] = i_rd;
        end

        // Thread 7
        if(d_miss_trd == 7 & d_miss) begin
            nxt_pc_7 = d_miss_pc;
            pc_wr[7] = 1;
        end
        else if(i_miss_trd == 7 & i_miss) begin
            nxt_pc_7 = i_miss_pc;
            pc_wr[7] = 1;
        end
        else if(jmp_trd == 7 & jmp & !stall) begin
            nxt_pc_7 = jmp_pc;
            pc_wr[7] = 1;
        end
        else if(cur_trd == 7 & !stall) begin
            nxt_pc_7 = cur_pc + 1;
            pc_wr[7] = i_rd;
        end
        
        if(jmp_exp & !exp_mode) begin
            case(cur_pc)
                0: begin
                    nxt_pc_0 = HANDLER;
                    pc_wr[0] = 1;
                end
                1: begin
                    nxt_pc_1 = HANDLER;
                    pc_wr[1] = 1;
                end
                2: begin
                    nxt_pc_2 = HANDLER;
                    pc_wr[2] = 1;
                end
                3: begin
                    nxt_pc_3 = HANDLER;
                    pc_wr[3] = 1;
                end
                4: begin
                    nxt_pc_4 = HANDLER;
                    pc_wr[4] = 1;
                end
                5: begin
                    nxt_pc_5 = HANDLER;
                    pc_wr[5] = 1;
                end
                6: begin
                    nxt_pc_6 = HANDLER;
                    pc_wr[6] = 1;
                end
                7: begin
                    nxt_pc_7 = HANDLER;
                    pc_wr[7] = 1;
                end
            endcase
        end
        else if(return_op) begin
            case(cur_pc)
                0: begin
                    nxt_pc_0 = epc;
                    pc_wr[0] = 1;
                end
                1: begin
                    nxt_pc_1 = epc;
                    pc_wr[1] = 1;
                end
                2: begin
                    nxt_pc_2 = epc;
                    pc_wr[2] = 1;
                end
                3: begin
                    nxt_pc_3 = epc;
                    pc_wr[3] = 1;
                end
                4: begin
                    nxt_pc_4 = epc;
                    pc_wr[4] = 1;
                end
                5: begin
                    nxt_pc_5 = epc;
                    pc_wr[5] = 1;
                end
                6: begin
                    nxt_pc_6 = epc;
                    pc_wr[6] = 1;
                end
                7: begin
                    nxt_pc_7 = epc;
                    pc_wr[7] = 1;
                end
            endcase
        end
    end

    
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) epc <= START_PC;
        else if(jmp_exp & !exp_mode)  epc <= cur_pc;
    end

endmodule