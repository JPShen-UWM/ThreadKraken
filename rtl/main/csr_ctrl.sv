/*
 * Module name: csr_ctrl
 * Engineer: Tommy Yee
 * Description: controller for csrs. return status of each thread.
 * Dependency: 
 * Status: dev
 */
module csr_ctrl(
    input   logic   [7:0]   child_0     ,
    input   logic   [7:0]   child_1     ,
    input   logic   [7:0]   child_2     ,
    input   logic   [7:0]   child_3     ,
    input   logic   [7:0]   child_4     ,
    input   logic   [7:0]   child_5     ,
    input   logic   [7:0]   child_6     ,
    input   logic   [7:0]   child_7     ,
    input   logic           alu_exp     ,
    input   logic   [2:0]   alu_trd     ,
    input   logic           inv_op      ,
    input   logic   [2:0]   inv_op_trd  ,
    input   logic   [2:0]   insfetch_trd,
    input   logic           breakpoint  ,
    input   logic   [2:0]   bp_trd      ,
    input   logic   [7:0]   valid_trd   ,
    input   logic   [7:0]   run_trd     ,
    input   logic           running     ,
    input   logic           trd_of      ,
    input   logic           trd_full    ,
    
);
    // inst CSRs
    csr #(child_0) ch0(
        .clk(clk),
        .rst_n(rst_n),
        .clr_ex(0),
        .i_cache_seg_fault(i_segfault)
    );


endmodule