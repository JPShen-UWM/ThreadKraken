/*
 * Module name: wb
 * Engineer: Jianping Shen
 * Description: Write back stage
 * Dependency:
 * Status: developing
**/
//`include "header.svh"
module wb(
    input           [31:0]  exe_data_wb ,
    input           [2:0]   trd_ctrl_wb ,
    input                   wb_sel_wb   ,
    input           [31:0]  d_rd_data   ,
    input                   flushWB     ,
    input                   wr_en_wb    ,
    input           [2:0]   new_trd     ,

    output  logic   [31:0]  wb_data_wb  ,
    output  logic           kill        ,
    output  logic           sleep       ,
    output  logic           wake        ,
    output  logic           wr_en_final ,
    output  logic           init_wb     
);
    // trd_ctrl:
    // 001: sleep
    // 010: wake
    // 011: kill
    // 111: init_trd

    assign wr_en_final = wr_en_wb & !flushWB;
    assign sleep = trd_ctrl_wb == 3'b001;
    assign wake = trd_ctrl_wb == 3'b010;
    assign kill = trd_ctrl_wb == 3'b011;
    assign init_wb = trd_ctrl_wb == 3'b111;
    assign wb_data_wb = init_wb?   {28'b0, new_trd}:
                        wb_sel_wb? d_rd_data:
                                   exe_data_wb;
endmodule

