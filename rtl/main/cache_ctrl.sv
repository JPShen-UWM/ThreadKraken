/*
 * Module name: cache_ctrl
 * Engineer: Tommy Yee
 * Description: cache control fsm. arbitrates dma reads/writes.
 * Dependency:
 * Status: developing
 */
module cache_ctrl(
    input                   clk         ,
    input                   rst_n       ,
    
    input   logic   [31:0]  i_addr      ,
    input   logic           i_rd        ,
    input   logic   [2:0]   i_trd       , // 
    
    output          [31:0]  i_rd_data   ,
    output                  i_miss      ,
    output                  i_segfault  ,
    
    input   logic   [31:0]  d_addr      ,
    input   logic   [31:0]  d_wr_data   ,
    input   logic           d_rd        ,
    input   logic           d_wr        ,
    input   logic   [2:0]   d_trd       ,
    
    output          [31:0]  d_rd_data   ,
    output                  d_miss      ,
    output                  d_segfault  ,
);
    //////////////////////////////////////// internal signals ////////////////////////////////////////

                  
/*
    // CORE
    output  logic   [31:0]  i_addr      ,
    output  logic           i_rd        ,
    output  logic   [2:0]   i_trd       ,
    input           [31:0]  i_rd_data   ,
    input                   i_miss      ,
    input                   i_segfault  ,
    
    output  logic   [31:0]  d_addr      ,
    output  logic   [31:0]  d_wr_data   ,
    output  logic           d_rd        ,
    output  logic           d_wr        ,
    output  logic   [2:0]   d_trd       ,
    
    input           [31:0]  d_rd_data   ,
    input                   d_miss      ,
    input                   d_segfault  ,
*/

endmodule