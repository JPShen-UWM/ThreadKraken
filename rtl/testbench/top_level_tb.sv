/*
 * Module name: top_level_tb
 * Engineer: Jianping Shen
 * Description: Testbench for thread kraken processor
 * Dependency: threadkraken_top.sv, no_miss_mem.sv, miss_mem.sv
 * Status: Done
**/
`include "../main/header.svh"
module top_level_tb();
    parameter mem_miss = 1; // 1 to simulate cache miss
    //parameter test_path = "../sw/test_cases/add1.o";
    parameter MAX_CYCLE = 200;


    logic           clk         ;
    logic           rst_n       ;
    logic   [31:0]  i_addr      ;
    logic           i_rd        ;
    logic   [2:0]   i_trd       ;
    logic   [31:0]  i_rd_data   ;
    logic           i_miss      ;
    logic           i_segfault  ;
    logic   [31:0]  d_addr      ;
    logic   [31:0]  d_wr_data   ;
    logic           d_rd        ;
    logic           d_wr        ;
    logic   [2:0]   d_trd       ;
    logic   [31:0]  d_rd_data   ;
    logic           d_miss      ;
    logic           d_segfault  ;
    logic   [7:0]   child_0     ;
    logic   [7:0]   child_1     ;
    logic   [7:0]   child_2     ;
    logic   [7:0]   child_3     ;
    logic   [7:0]   child_4     ;
    logic   [7:0]   child_5     ;
    logic   [7:0]   child_6     ;
    logic   [7:0]   child_7     ;
    logic           alu_exp     ;
    logic   [2:0]   alu_trd     ;
    logic           inv_op      ;
    logic   [2:0]   inv_op_trd  ;
    logic   [2:0]   insfetch_trd;
    logic           breakpoint  ;
    logic   [2:0]   bp_trd      ;
    logic   [7:0]   valid_trd   ;
    logic   [7:0]   run_trd     ;
    logic           running     ;
    logic           trd_of      ;
    logic           trd_full    ;

    integer cycle_count;

    logic [4:0] reg_wr;
    logic reg_wr_en;
    logic [2:0] trd_wr;
    logic [31:0] data_wr;
    logic [2:0] new_trd;
    logic kill, sleep, wake, init;
    logic [2:0] obj_trd, act_trd, par_trd;

    assign reg_wr = DUT.reg_wr_wb;
    assign reg_wr_en = DUT.wr_en_final;
    assign data_wr = DUT.wb_data_wb;
    assign trd_wr = DUT. trd_wb;
    assign kill = DUT.kill;
    assign sleep = DUT.sleep;
    assign wake = DUT.wake;
    assign init = DUT.INSFETCH.THREAD_CTRL.init;
    assign new_trd = DUT.new_trd_id;
    assign obj_trd = DUT.obj_trd_wb;
    assign act_trd = DUT.trd_wb;
    assign par_trd = DUT.trd_dec;

    initial begin
        cycle_count = 0;
        rst_n = 0;
        clk = 0;
        @(negedge clk);    
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);  
        for(cycle_count = 0; cycle_count < MAX_CYCLE; cycle_count++) begin
            @(posedge clk);
            if(rst_n & !running) begin
                $display("Processor stop running at cycle: %d.", cycle_count);
                $stop;
            end
        end
        $display("Stop for time out.");
        $stop;
    end

    always @(posedge clk) begin
        if(rst_n) begin
            if(reg_wr_en) begin
                $display("Reg write. Thread: %d, reg: %d, data:%h", trd_wr, reg_wr, data_wr);
            end
            if(init) begin
                $display("Init. Thread: %d, init new trd: %d", par_trd, new_trd);
            end
            if(kill) begin
                $display("Thread: %d kill thread %d.", act_trd, obj_trd);
            end
            if(sleep) begin
                $display("Thread: %d sleep thread %d.", act_trd, obj_trd);
            end
            if(wake) begin
                $display("Thread: %d wake thread %d.", act_trd, obj_trd);
            end
        end
    end

    always #5 clk = ~clk;

    generate
        if(!mem_miss) begin
            no_miss_mem #("../sw/test_cases/jal1.o") NO_MISS_MEM 
            (
                .clk            (clk         ),
                .rst_n          (rst_n       ),
                .i_addr         (i_addr      ),
                .i_rd           (i_rd        ),
                .i_trd          (i_trd       ),
                .i_rd_data      (i_rd_data   ),
                .i_miss         (i_miss      ),
                .i_segfault     (i_segfault  ),
                .d_addr         (d_addr      ),
                .d_wr_data      (d_wr_data   ),
                .d_rd           (d_rd        ),
                .d_wr           (d_wr        ),
                .d_trd          (d_trd       ),
                .d_rd_data      (d_rd_data   ),
                .d_miss         (d_miss      ),
                .d_segfault     (d_segfault  ),
                .child_0        (child_0     ),
                .child_1        (child_1     ),
                .child_2        (child_2     ),
                .child_3        (child_3     ),
                .child_4        (child_4     ),
                .child_5        (child_5     ),
                .child_6        (child_6     ),
                .child_7        (child_7     ),
                .alu_exp        (alu_exp     ),
                .alu_trd        (alu_trd     ),
                .inv_op         (inv_op      ),
                .inv_op_trd     (inv_op_trd  ),
                .insfetch_trd   (insfetch_trd),
                .breakpoint     (breakpoint  ),
                .bp_trd         (bp_trd      ),
                .valid_trd      (valid_trd   ),
                .run_trd        (run_trd     ),
                .running        (running     ),
                .trd_of         (trd_of      ),
                .trd_full       (trd_full    )
            );
        end
        else begin
            miss_mem #("../sw/test_cases/beq2.o") MISS_MEM 
            (
                .clk            (clk         ),
                .rst_n          (rst_n       ),
                .i_addr         (i_addr      ),
                .i_rd           (i_rd        ),
                .i_trd          (i_trd       ),
                .i_rd_data      (i_rd_data   ),
                .i_miss         (i_miss      ),
                .i_segfault     (i_segfault  ),
                .d_addr         (d_addr      ),
                .d_wr_data      (d_wr_data   ),
                .d_rd           (d_rd        ),
                .d_wr           (d_wr        ),
                .d_trd          (d_trd       ),
                .d_rd_data      (d_rd_data   ),
                .d_miss         (d_miss      ),
                .d_segfault     (d_segfault  ),
                .child_0        (child_0     ),
                .child_1        (child_1     ),
                .child_2        (child_2     ),
                .child_3        (child_3     ),
                .child_4        (child_4     ),
                .child_5        (child_5     ),
                .child_6        (child_6     ),
                .child_7        (child_7     ),
                .alu_exp        (alu_exp     ),
                .alu_trd        (alu_trd     ),
                .inv_op         (inv_op      ),
                .inv_op_trd     (inv_op_trd  ),
                .insfetch_trd   (insfetch_trd),
                .breakpoint     (breakpoint  ),
                .bp_trd         (bp_trd      ),
                .valid_trd      (valid_trd   ),
                .run_trd        (run_trd     ),
                .running        (running     ),
                .trd_of         (trd_of      ),
                .trd_full       (trd_full    )
            );
        end
    endgenerate

    threadkraken_top DUT
    (
        .clk            (clk         ),
        .rst_n          (rst_n       ),
        .i_addr         (i_addr      ),
        .i_rd           (i_rd        ),
        .i_trd          (i_trd       ),
        .i_rd_data      (i_rd_data   ),
        .i_miss         (i_miss      ),
        .i_segfault     (i_segfault  ),
        .d_addr         (d_addr      ),
        .d_wr_data      (d_wr_data   ),
        .d_rd           (d_rd        ),
        .d_wr           (d_wr        ),
        .d_trd          (d_trd       ),
        .d_rd_data      (d_rd_data   ),
        .d_miss         (d_miss      ),
        .d_segfault     (d_segfault  ),
        .child_0        (child_0     ),
        .child_1        (child_1     ),
        .child_2        (child_2     ),
        .child_3        (child_3     ),
        .child_4        (child_4     ),
        .child_5        (child_5     ),
        .child_6        (child_6     ),
        .child_7        (child_7     ),
        .alu_exp        (alu_exp     ),
        .alu_trd        (alu_trd     ),
        .inv_op         (inv_op      ),
        .inv_op_trd     (inv_op_trd  ),
        .insfetch_trd   (insfetch_trd),
        .breakpoint     (breakpoint  ),
        .bp_trd         (bp_trd      ),
        .valid_trd      (valid_trd   ),
        .run_trd        (run_trd     ),
        .running        (running     ),
        .trd_of         (trd_of      ),
        .trd_full       (trd_full    )
    );


endmodule