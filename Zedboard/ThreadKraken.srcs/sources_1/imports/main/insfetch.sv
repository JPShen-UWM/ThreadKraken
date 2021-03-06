/*
 * Module name: insfetch
 * Engineer: Jianping Shen
 * Description: Instruction fetch stage
 * Dependency: thread_csr, thread_ctrl, pc_sel
 * Status: developing
**/

//`include "header.svh"

module insfetch
(
    input                   clk         ,
    input                   rst_n       ,

    input       [2:0]       jmp_trd     ,
    input       [31:0]      jmp_pc      ,
    input                   jmp         ,

    input                   d_miss      ,
    input       [31:0]      d_miss_pc   ,
    input       [2:0]       d_miss_trd  ,
    input       [31:0]      i_data      ,
    input                   i_miss      ,
    input                   i_segfault  ,
    input                   kill        ,
    input                   slp         ,
    input                   wake        ,
    input                   init_trd    ,
    input       [2:0]       act_trd     ,
    input       [2:0]       obj_trd     ,
    input       [31:0]      init_pc     ,
    input                   stall       ,
    input                   jmp_exp     ,
    input                   return_op   ,
    input                   flushIF     ,

    output  logic   [31:0]  pc_dec      ,
    output  logic   [2:0]   new_trd     ,
    output  logic   [2:0]   trd_if      ,
    output  logic   [2:0]   trd_dec     ,   // Thread at decoder stage
    output  logic           trd_of      ,
    output  logic           trd_full    ,
    output  logic   [7:0]   run_trd     ,
    output  logic   [7:0]   valid_trd   ,
    output  logic   [31:0]  i_addr      ,
    output  logic           i_rd        ,
    output  logic   [7:0]   child_0     ,
    output  logic   [7:0]   child_1     ,
    output  logic   [7:0]   child_2     ,
    output  logic   [7:0]   child_3     ,
    output  logic   [7:0]   child_4     ,
    output  logic   [7:0]   child_5     ,
    output  logic   [7:0]   child_6     ,
    output  logic   [7:0]   child_7      
);

    logic thread_ctrl_error;
    logic [31:0] pc_if;
    logic invalid_op;
    logic miss;
    logic [7:0] pc_wr;
    logic [7:0] trd_miss;
    logic [2:0] cur_trd;
    logic exp_mode;
    logic [2:0] nxt_trd;

    assign trd_if = cur_trd;
    // Thread miss
    always_comb begin
        trd_miss = 0;
        trd_miss[trd_dec] = i_miss;
        trd_miss[d_miss_trd] = d_miss | i_miss & trd_dec == d_miss_trd;
        miss = i_miss | d_miss;
    end

    assign i_addr = pc_if;
    assign i_rd = run_trd[cur_trd] & !flushIF;
    assign atomic = i_data[0] | exp_mode;

    // Exception mode
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            exp_mode <= 0;
        end
        else if(jmp_exp) begin
            exp_mode <= 1;
        end
        else if(return_op) begin
            exp_mode <= 0;
        end
    end

    logic [31:0] nxt_pc_0;
    logic [31:0] nxt_pc_1;
    logic [31:0] nxt_pc_2;
    logic [31:0] nxt_pc_3;
    logic [31:0] nxt_pc_4;
    logic [31:0] nxt_pc_5;
    logic [31:0] nxt_pc_6;
    logic [31:0] nxt_pc_7;
    // Thread control
    thread_ctrl THREAD_CTRL(
        .clk            (clk),
        .rst_n          (rst_n),

        .atomic         (atomic),   // Do not increment thread pointer
        .kill           (kill),   // Kill determined thread
        .slp            (slp),   // Sleep the objective thread
        .wake           (wake),   // wake up the objective thread
        .init_trd       (init_trd),   // Init a new thread
        .act_trd        (act_trd),   // Act thread that sending the commend
        .obj_trd_in     (obj_trd),   // Objective thread that being kill, sleep, or wake
        .stall          (stall),   // Stall any action
        .trd_miss       (trd_miss),   // Thread encounter a cache miss
        .miss           (miss),   // Cache miss
        .init_pc        (init_pc),   // Initial pc for a new thread
        .pc_wr          (pc_wr),
        .nxt_pc_0       (nxt_pc_0),
        .nxt_pc_1       (nxt_pc_1),
        .nxt_pc_2       (nxt_pc_2),
        .nxt_pc_3       (nxt_pc_3),
        .nxt_pc_4       (nxt_pc_4),
        .nxt_pc_5       (nxt_pc_5),
        .nxt_pc_6       (nxt_pc_6),
        .nxt_pc_7       (nxt_pc_7),

        .cur_trd        (cur_trd),   // Current thread pointing to
        .nxt_trd        (nxt_trd),   // Next thread
        .new_trd        (new_trd),   // New thread that just been create
        .valid_trd      (valid_trd),   // Threads that is valid
        .run_trd        (run_trd),   // Threads that is not sleeping
        .trd_full       (trd_full),   // All threads are valid
        .trd_of         (trd_of),   // Thread overflow: trying the create a new thread when all threads are used
        .invalid_op     (invalid_op),   // Trying to kill or sleep a thread that is not its child or itself
        .error          (thread_ctrl_error),   // Other unrecoverable error
        .cur_pc         (pc_if),   // Current pc
        .child_0        (child_0),   // Children thread of thread 0
        .child_1        (child_1),   // Children thread of thread 1
        .child_2        (child_2),   // Children thread of thread 2
        .child_3        (child_3),   // Children thread of thread 3
        .child_4        (child_4),   // Children thread of thread 4
        .child_5        (child_5),   // Children thread of thread 5
        .child_6        (child_6),   // Children thread of thread 6
        .child_7        (child_7)    // Children thread of thread 7
    );

    pc_sel PC_SEL
    (
        .clk            (clk        ),
        .rst_n          (rst_n      ),
        .cur_trd        (cur_trd    ),
        .cur_pc         (pc_if      ),
        .jmp_trd        (jmp_trd    ),
        .jmp_pc         (jmp_pc     ),
        .jmp            (jmp        ),
        .i_miss_trd     (trd_dec    ),
        .i_miss_pc      (pc_dec     ),
        .i_miss         (i_miss     ),
        .d_miss_trd     (d_miss_trd ),
        .d_miss_pc      (d_miss_pc  ),
        .d_miss         (d_miss     ),
        .jmp_exp        (jmp_exp    ),
        .exp_mode       (exp_mode   ),
        .return_op      (return_op  ),
        .stall          (stall      ),
        .i_rd           (i_rd       ),

        .nxt_pc_0       (nxt_pc_0   ),
        .nxt_pc_1       (nxt_pc_1   ),
        .nxt_pc_2       (nxt_pc_2   ),
        .nxt_pc_3       (nxt_pc_3   ),
        .nxt_pc_4       (nxt_pc_4   ),
        .nxt_pc_5       (nxt_pc_5   ),
        .nxt_pc_6       (nxt_pc_6   ),
        .nxt_pc_7       (nxt_pc_7   ),
        .pc_wr          (pc_wr      )
    );

    // Pipeline
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            trd_dec <= 3'b0;
            pc_dec <= 0;
        end
        else if(!stall) begin
            trd_dec <= cur_trd;
            pc_dec <= i_addr;
        end
    end

endmodule