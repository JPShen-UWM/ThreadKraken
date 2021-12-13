/*
 * Module name: pc_sel
 * Engineer: Jianping Shen
 * Description: pc selector and incrementor
 * Dependency:
 * Status: developing
**/

`include "header.svh"

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