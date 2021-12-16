/*
 * Module name: tk_top_zed
 * Engineer: Jianping Shen
 * Description: Top level wrapper for zedboard
 * Dependency:
 * Status: Done
 */

module tk_top_zed(
    input           clk     ,
    input           rst_b   ,
    
    output  [31:0]  rd_addr ,
    input   [31:0]  data_0  ,
    input   [31:0]  data_1  ,
    input   [31:0]  data_2  ,
    input   [31:0]  data_3  ,
    input   [31:0]  data_4  ,
    input   [31:0]  data_5  ,
    input   [31:0]  data_6  ,
    input   [31:0]  data_7  ,
    input   [1:0]   host_sig,
    output          finish  ,
    output  [31:0]  cycle   ,
    output  [31:0]  uart0   ,
    output  [31:0]  uart1   ,
    output  [31:0]  uart2   ,
    output  [31:0]  uart3   ,
    output  [7:0]   run_trd
);

    wire   [31:0]  i_addr      ;
    wire           i_rd        ;
    wire   [2:0]   i_trd       ;
    wire   [31:0]  i_rd_data   ;
    wire           i_miss      ;
    wire           i_segfault  ;
    wire   [31:0]  d_addr      ;
    wire   [31:0]  d_wr_data   ;
    wire           d_rd        ;
    wire           d_wr        ;
    wire   [2:0]   d_trd       ;
    wire   [31:0]  d_rd_data   ;
    wire           d_miss      ;
    wire           d_segfault  ;
    wire   [7:0]   child_0     ;
    wire   [7:0]   child_1     ;
    wire   [7:0]   child_2     ;
    wire   [7:0]   child_3     ;
    wire   [7:0]   child_4     ;
    wire   [7:0]   child_5     ;
    wire   [7:0]   child_6     ;
    wire   [7:0]   child_7     ;
    wire           alu_exp     ;
    wire   [2:0]   alu_trd     ;
    wire           inv_op      ;
    wire   [2:0]   inv_op_trd  ;
    wire   [2:0]   insfetch_trd;
    wire           breakpoint  ;
    wire   [2:0]   bp_trd      ;
    wire   [7:0]   valid_trd   ;
    wire           running     ;
    wire           trd_of      ;
    wire           trd_full    ;
    wire           rst_n       ;
    wire   [7:0]   running_trd ;

    assign rst_n = rst_b;


    reg [15:0] counter;
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) counter <= 0;
        else counter <= counter + 1;
    end

    assign run_trd[0] = (counter[15] & valid_trd[0]) | running_trd[0];
    assign run_trd[1] = (counter[15] & valid_trd[1]) | running_trd[1];
    assign run_trd[2] = (counter[15] & valid_trd[2]) | running_trd[2];
    assign run_trd[3] = (counter[15] & valid_trd[3]) | running_trd[3];
    assign run_trd[4] = (counter[15] & valid_trd[4]) | running_trd[4];
    assign run_trd[5] = (counter[15] & valid_trd[5]) | running_trd[5];
    assign run_trd[6] = (counter[15] & valid_trd[6]) | running_trd[6];
    assign run_trd[7] = (counter[15] & valid_trd[7]) | running_trd[7];


mmu_zed MMU
(
	.clk            (clk            ),
	.rst_n          (rst_n          ),
    .i_addr         (i_addr         ),
    .i_rd           (i_rd           ),
    .i_trd          (i_trd          ),
    .i_rd_data      (i_rd_data      ),
    .i_miss         (i_miss         ),
    .i_segfault     (i_segfault     ),
    .d_addr         (d_addr         ),
    .d_wr_data      (d_wr_data      ),
    .d_rd           (d_rd           ),
    .d_wr           (d_wr           ),
    .d_trd          (d_trd          ),
    .d_rd_data      (d_rd_data      ),
    .d_miss         (d_miss         ),
    .d_segfault     (d_segfault     ),
    .child_0        (child_0        ),
    .child_1        (child_1        ),
    .child_2        (child_2        ),
    .child_3        (child_3        ),
    .child_4        (child_4        ),
    .child_5        (child_5        ),
    .child_6        (child_6        ),
    .child_7        (child_7        ),
    .alu_exp        (alu_exp        ),
    .alu_trd        (alu_trd        ),
    .inv_op         (inv_op         ),
    .inv_op_trd     (inv_op_trd     ),
    .insfetch_trd   (insfetch_trd   ),
    .breakpoint     (breakpoint     ),
    .bp_trd         (bp_trd         ),
    .valid_trd      (valid_trd      ),
    .run_trd        (running_trd    ),
    .running        (running        ),
    .trd_of         (trd_of         ),
    .trd_full       (trd_full       ),
    .rd_data_0      (data_0         ),
    .rd_data_1      (data_1         ),
    .rd_data_2      (data_2         ),
    .rd_data_3      (data_3         ),
    .rd_data_4      (data_4         ),
    .rd_data_5      (data_5         ),
    .rd_data_6      (data_6         ),
    .rd_data_7      (data_7         ),
    .host_rd_addr   (rd_addr        ),
    .host_sig       (host_sig       ),
    .uart_0         (uart0          ),
    .uart_1         (uart1          ),
    .uart_2         (uart2          ),
    .uart_3         (uart3          ),
    .cycle_count    (cycle          ),
    .finish         (finish         )
);

threadkraken_top CPU(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .i_addr         (i_addr         ),
    .i_rd           (i_rd           ),
    .i_trd          (i_trd          ),
    .i_rd_data      (i_rd_data      ),
    .i_miss         (i_miss         ),
    .i_segfault     (i_segfault     ),
    .d_addr         (d_addr         ),
    .d_wr_data      (d_wr_data      ),
    .d_rd           (d_rd           ),
    .d_wr           (d_wr           ),
    .d_trd          (d_trd          ),
    .d_rd_data      (d_rd_data      ),
    .d_miss         (d_miss         ),
    .d_segfault     (d_segfault     ),
    .child_0        (child_0        ),
    .child_1        (child_1        ),
    .child_2        (child_2        ),
    .child_3        (child_3        ),
    .child_4        (child_4        ),
    .child_5        (child_5        ),
    .child_6        (child_6        ),
    .child_7        (child_7        ),
    .alu_exp        (alu_exp        ),
    .alu_trd        (alu_trd        ),
    .inv_op         (inv_op         ),
    .inv_op_trd     (inv_op_trd     ),
    .insfetch_trd   (insfetch_trd   ),
    .breakpoint     (breakpoint     ),
    .bp_trd         (bp_trd         ),
    .valid_trd      (valid_trd      ),
    .run_trd        (running_trd    ),
    .running        (running        ),
    .trd_of         (trd_of         ),
    .trd_full       (trd_full       )
);

endmodule