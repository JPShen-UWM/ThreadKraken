/*
 * Module name: thread_ctrl_tb
 * Engineer: Jianping Shen
 * Description: Testbench for thread control
 * Dependency:
 * Status: Done
 */
`include "../main/header.svh"
module thread_ctrl_tb();



    logic        clk         ;
    logic        rst_n       ;
    logic        atomic      ;
    logic        kill        ;
    logic        slp         ;
    logic        wake        ;
    logic        init_trd    ;
    logic [2:0]  act_trd     ;
    logic [2:0]  obj_trd_in  ;
    logic        stall       ;
    logic [31:0] init_pc     ;
    logic [2:0]  cur_trd     ;
    logic [2:0]  nxt_trd     ;
    logic [2:0]  new_trd     ;
    logic [7:0]  valid_trd   ;
    logic [7:0]  run_trd     ;
    logic        trd_full    ;
    logic        trd_of      ;
    logic        invalid_op  ;
    logic        error       ;
    logic        cur_pc      ;
    logic [7:0]  child_0     ;
    logic [7:0]  child_1     ;
    logic [7:0]  child_2     ;
    logic [7:0]  child_3     ;
    logic [7:0]  child_4     ;
    logic [7:0]  child_5     ;
    logic [7:0]  child_6     ;
    logic [7:0]  child_7     ;
    logic [7:0]  pc_wr       ;
    logic [31:0] nxt_pc_0    ;
    logic [31:0] nxt_pc_1    ;
    logic [31:0] nxt_pc_2    ;
    logic [31:0] nxt_pc_3    ;
    logic [31:0] nxt_pc_4    ;
    logic [31:0] nxt_pc_5    ;
    logic [31:0] nxt_pc_6    ;
    logic [31:0] nxt_pc_7    ;
    logic        miss        ;



thread_ctrl iDUT(
    .clk       (clk       )  ,
    .rst_n     (rst_n     )  ,

    .atomic    (atomic    )  ,   // Do not increment thread pointer
    .kill      (kill      )  ,   // Kill determined thread
    .slp       (slp       )  ,   // Sleep the objective thread
    .wake      (wake      )  ,   // wake up the objective thread
    .init_trd  (init_trd  )  ,   // Init a new thread
    .act_trd   (act_trd   )  ,   // Act thread that sending the commend
    .obj_trd_in(obj_trd_in)  ,   // Objective thread that being kill, sleep, or wake
    .stall     (stall     )  ,   // Stall any action
    .miss      (miss      )  ,
    .init_pc   (init_pc   )  ,   // Initial pc for a new thread
    .pc_wr     (pc_wr     )  ,
    .nxt_pc_0  (nxt_pc_0  )  ,
    .nxt_pc_1  (nxt_pc_1  )  ,
    .nxt_pc_2  (nxt_pc_2  )  ,
    .nxt_pc_3  (nxt_pc_3  )  ,
    .nxt_pc_4  (nxt_pc_4  )  ,
    .nxt_pc_5  (nxt_pc_5  )  ,
    .nxt_pc_6  (nxt_pc_6  )  ,
    .nxt_pc_7  (nxt_pc_7  )  ,

    .cur_trd   (cur_trd   )  ,   // Current thread pointing to
    .nxt_trd   (nxt_trd   )  ,   // Next thread
    .new_trd   (new_trd   )  ,   // New thread that just been create
    .valid_trd (valid_trd )  ,   // Threads that is valid
    .run_trd   (run_trd   )  ,   // Threads that is not sleeping
    .trd_full  (trd_full  )  ,   // All threads are valid
    .trd_of    (trd_of    )  ,   // Thread overflow: trying the create a new thread when all threads are used
    .invalid_op(invalid_op)  ,   // Trying to kill or sleep a thread that is not its child or itself
    .error     (error     )  ,   // Other unrecoverable error
    .cur_pc    (cur_pc    )  ,   // Current pc
    .child_0   (child_0   )  ,
    .child_1   (child_1   )  ,
    .child_2   (child_2   )  ,
    .child_3   (child_3   )  ,
    .child_4   (child_4   )  ,
    .child_5   (child_5   )  ,
    .child_6   (child_6   )  ,
    .child_7   (child_7   )  
);

    always #5 clk = ~clk;
    parameter MAX_CYCLE = 100;

    function void init();
        clk = 0;
        rst_n = 0;
        atomic = 0;
        kill = 0;
        slp = 0;
        init_trd = 0;
        act_trd = 0;
        obj_trd_in = 0;
        stall = 0;
        init_pc = START_PC;
        wake = 0;
        pc_wr = 0;
        nxt_pc_0  = 0;
        nxt_pc_1  = 0;
        nxt_pc_2  = 0;
        nxt_pc_3  = 0;
        nxt_pc_4  = 0;
        nxt_pc_5  = 0;
        nxt_pc_6  = 0;
        nxt_pc_7  = 0;
        miss = 0;
    endfunction: init

    initial begin
        init();
        @(negedge clk);
        @(negedge clk) rst_n = 1;
        init_trd = 1;
        @(posedge clk) init_trd = 0;
        @(posedge clk) init_trd = 1;
        @(posedge clk) init_trd = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        slp = 1;
        obj_trd_in = 1;
        act_trd = 0;
        @(posedge clk);
        slp = 0;
        @(posedge clk);
        wake = 1;
        obj_trd_in = 1;
        act_trd = 0;
        @(posedge clk);
        wake = 0;
        @(posedge clk);
        kill = 1;
        obj_trd_in = 1;
        act_trd = 0;
        @(posedge clk);
        kill = 0;
        @(posedge clk);
        @(posedge clk);
        kill = 1;
        obj_trd_in = 0;
        act_trd = 2;
        @(posedge clk);
        kill = 0;
        @(posedge clk);
    end

    initial begin
        integer cycle_count;
        for(cycle_count = 0; cycle_count <= MAX_CYCLE; cycle_count++) begin
            @(posedge clk);
        end
        $stop;
    end
endmodule