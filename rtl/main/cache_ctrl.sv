/*
 * Module name: cache_ctrl
 * Engineer: Tommy Yee
 * Description: cache control fsm
 * Dependency:
 * Status: developing
 */
module cache_ctrl(
    input                   clk         ,
    input                   rst_n       ,
    
    input   logic   [31:0]  i_addr      ,
    input   logic           i_rd        ,       // read request from core
//    input   logic   [2:0]   i_trd       ,
    
    output          [31:0]  i_rd_data   ,
    output                  i_miss      ,
    output                  i_segfault  ,
    
    input   logic   [31:0]  d_addr      ,
    input   logic   [31:0]  d_wr_data   ,
    input   logic           d_rd        ,
    input   logic           d_wr        ,
//    input   logic   [2:0]   d_trd       ,
    
    output          [31:0]  d_rd_data   ,
    output                  d_miss      ,
    output                  d_segfault  ,
);
    /////////////////////////////////////// internal signals ///////////////////////////////////////
    
    
    ////////////////////////////////////////// sm signals //////////////////////////////////////////
    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;
    state_t state, nxt_state;

    /////////////////////////////////////////// datapath ///////////////////////////////////////////

endmodule