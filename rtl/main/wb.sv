/*
 * Module name: wb
 * Engineer: Jianping Shen
 * Description: Write back stage
 * Dependency:
 * Status: developing
**/
`include "header.svh"
module wb(
    input           [31:0]  exe_data_wb ,
    input           [1:0]   trd_ctrl_wb ,
    input                   wb_sel_wb   ,
    input           [31:0]  d_rd_data   ,

    output  logic   [31:0]  wb_data_wb  ,
    output  logic           kill        ,
    output  logic           sleep       ,
    output  logic           wake        
);
    // trd_ctrl:
    // 01: sleep
    // 10: wake
    // 11: kill
    assign sleep = trd_ctrl_wb == 2'b01;
    assign wake = trd_ctrl_wb == 2'b10;
    assign kill = trd_ctrl_wb == 2'b11;
    assign wb_data_wb = wb_sel_wb? d_rd_data: exe_data_wb;
endmodule

