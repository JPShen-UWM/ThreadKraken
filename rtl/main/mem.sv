/*
 * Module name: mem
 * Engineer: Jianping Shen
 * Description: Memory access stage
 * Dependency:
 * Status: developing
**/
`include "header.svh"
module mem(
    input                   clk         ,
    input                   rst_n       ,

    input           [31:0]  d_addr_mem  ,
    input           [31:0]  ins_mem     ,
    input           [31:0]  pc_mem      ,
    input           [31:0]  exe_data_mem,
    input           [2:0]   trd_mem     ,
    input           [4:0]   reg_wr_mem  ,
    input                   wr_en_mem   ,
    input                   wb_sel_mem  ,
    input           [1:0]   mem_ctrl_mem,
    input           [1:0]   trd_ctrl_mem,
    input           [2:0]   obj_trd_mem ,
    input                   flushMEM    ,
    input                   d_miss      ,

    output  logic   [31:0]  ins_wb      ,
    output  logic   [31:0]  pc_wb       ,
    output  logic   [31:0]  exe_data_wb ,
    output  logic   [2:0]   trd_wb      ,
    output  logic   [4:0]   reg_wr_wb   ,
    output  logic           wr_en_wb    ,
    output  logic   [1:0]   trd_ctrl_wb ,
    output  logic   [2:0]   obj_trd_wb  ,
    output  logic           wb_sel_wb   ,

    output  logic           d_rd        ,
    output  logic           d_wr        ,
    output  logic   [31:0]  d_wr_data   
);

    // mem_ctrl:
    // 01: read
    // 10: write

    assign d_rd = mem_ctrl_mem[0];
    assign d_wr = mem_ctrl_mem[1];
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n | flushMEM) begin
            ins_wb      <= 0;
            pc_wb       <= 0;
            exe_data_wb <= 0;
            trd_wb      <= 0;
            reg_wr_wb   <= 0;
            wr_en_wb    <= 0;
            trd_ctrl_wb <= 0;
            obj_trd_wb  <= 0;
            wb_sel_wb   <= 0;
        end
        else begin
            ins_wb      <= ins_mem;
            pc_wb       <= pc_mem;
            exe_data_wb <= exe_data_mem;
            trd_wb      <= trd_mem;
            reg_wr_wb   <= reg_wr_mem;
            wr_en_wb    <= wr_en_mem;
            trd_ctrl_wb <= trd_ctrl_mem;
            obj_trd_wb  <= obj_trd_mem;
            wb_sel_wb   <= wb_sel_mem;
        end
    end

endmodule