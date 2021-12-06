/*
 * Module name: threadkraken_top
 * Engineer: Jianping Shen
 * Description: top level of ThreadKraken processor
 * Dependency: alu.sv, decode.sv, exe.sv, insdec.sv, insfetch.sv, mem.sv, pc_cal.sv
 * pc_sel.sv, regfile_set.sv, regfile.sv, thread_csr.sv, thread_ctrl.sv, wb.sv
 * Status: developing
**/
`include "header.svh"
module threadkraken_top(
    input                   clk         ,
    input                   rst_n       ,

    // MMU interface
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

    // CSR interface
    output  logic   [7:0]   child_0     ,
    output  logic   [7:0]   child_1     ,
    output  logic   [7:0]   child_2     ,
    output  logic   [7:0]   child_3     ,
    output  logic   [7:0]   child_4     ,
    output  logic   [7:0]   child_5     ,
    output  logic   [7:0]   child_6     ,
    output  logic   [7:0]   child_7     ,
    output  logic           alu_exp     ,
    output  logic   [2:0]   alu_trd     ,
    output  logic           inv_op      ,
    output  logic   [2:0]   inv_op_trd  ,
    output  logic   [2:0]   insfetch_trd,
    output  logic           breakpoint  ,
    output  logic   [2:0]   bp_trd      ,
    output  logic   [7:0]   valid_trd   ,
    output  logic   [7:0]   run_trd     ,
    output  logic           running     ,
    output  logic           trd_of      ,
    output  logic           trd_full    
);

    // Jump comand   
    logic [31:0] jmp_pc;
    logic jmp_en;
    // Thread for each stage
    logic [2:0] trd_if, trd_dec, trd_exe, trd_mem, trd_wb;
    // PC for each stage
    logic [31:0] pc_dec, pc_exe, pc_mem, pc_wb;
    // ins for each stage
    logic [31:0] ins_exe, ins_mem, ins_wb;
    // Thread op
    logic kill, sleep, wake, init_trd_dec, init_trd_exe;
    logic [2:0] obj_trd_mem, obj_trd_wb;
    // New thread
    logic [2:0] new_trd_id, new_trd_exe;
    // Flush
    logic flushID, flushEX, flushMEM;
    // Register read and write
    logic [31:0] data_a_exe, data_b_exe;
    logic [4:0] reg_rd_a_exe, reg_rd_b_exe;
    logic [4:0] reg_wr_exe, reg_wr_mem, reg_wr_wb;
    logic wr_en_exe, wr_en_mem, wr_en_wb;
    // Data at each stage
    logic [31:0] exe_data_mem, exe_data_wb;
    logic [31:0] wb_data_wb;
    // Immediate
    logic [15:0] imm_exe;
    // Write back select
    logic wb_sel_exe, wb_sel_mem, wb_sel_wb;
    // ALU operation
    logic [2:0] alu_op_exe;
    // Memory control
    logic [1:0] mem_ctrl_exe, mem_ctrl_mem;
    // Thread operation control
    logic [1:0] trd_ctrl_exe, trd_ctrl_mem, trd_ctrl_wb;
    // Exception jump
    logic exp_jmp_dec, exp_return_dec;
    // Branch jump control
    logic [3:0] jmp_con_exe;
    // immediate type control
    logic i_type_exe;
    // stall for data hazard
    logic stall, stall_req;

    assign i_trd = trd_if;
    assign d_trd = trd_mem;
    assign running = valid_trd[0];
    assign alu_trd = trd_exe;
    assign inv_op_trd = trd_dec;
    assign breakpoint = exp_jmp_dec;
    assign insfetch_trd = trd_if;
    assign bp_trd = trd_dec;

    insfetch INSFETCH
    (   
        .clk                (clk            ),
        .rst_n              (rst_n          ),

        .jmp_trd            (trd_exe        ),
        .jmp_pc             (jmp_pc         ),
        .jmp                (jmp_en         ),
        .d_miss             (d_miss         ),
        .d_miss_pc          (pc_mem         ),
        .d_miss_trd         (trd_mem        ),
        .i_data             (i_rd_data      ),
        .i_miss             (i_miss         ),
        .i_segfault         (i_segfault     ),
        .kill               (kill           ),
        .slp                (sleep          ),
        .wake               (wake           ),
        .init_trd           (init_trd_dec   ),
        .act_trd            (trd_wb         ),
        .obj_trd            (obj_trd_wb     ),
        .init_pc            (data_a_exe     ),
        .stall              (stall          ),
        .jmp_exp            (exp_jmp_dec    ),
        .return_op          (exp_return_dec ),

        .pc_dec             (pc_dec         ),
        .new_trd            (new_trd_id     ),
        .trd_if             (trd_if         ),
        .trd_dec            (trd_dec        ),
        .flushIF            (flushIF        ),
        .trd_of             (trd_of         ),
        .trd_full           (trd_full       ),
        .run_trd            (run_trd        ),
        .valid_trd          (valid_trd      ),
        .i_addr             (i_addr         ),
        .i_rd               (i_rd           ),
        .child_0            (child_0        ),
        .child_1            (child_1        ),
        .child_2            (child_2        ),
        .child_3            (child_3        ),
        .child_4            (child_4        ),
        .child_5            (child_5        ),
        .child_6            (child_6        ),
        .child_7            (child_7        )  
    );

    flush_stall FLUSH_STALL(
        .jmp        (jmp_en     ),
        .kill       (kill       ),
        .sleep      (sleep      ),
        .stall_req  (stall_req  ),
        .trd_if     (trd_if     ),
        .trd_dec    (trd_dec    ),
        .trd_exe    (trd_exe    ),
        .trd_mem    (trd_mem    ),
        .trd_wb     (trd_wb     ),
        .d_miss     (d_miss     ),
        .flushEX    (flushEX    ),
        .flushID    (flushID    ),
        .flushMEM   (flushMEM   ),
        .flushIF    (flushIF    ),
        .stall      (stall      )
    );


    insdec INSDEC
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),

        .ins_dec            (i_rd_data      ),
        .new_trd_id         (new_trd_id     ),
        .trd_dec            (trd_dec        ),
        .pc_dec             (pc_dec         ),
        .flushID            (flushID        ),
        .stall              (stall          ),

        .wr_trd_wb          (trd_wb         ),
        .data_wb            (wb_data_wb     ),
        .wr_reg_wb          (reg_wr_wb      ),
        .wr_en_wb           (wr_en_wb       ),

        // Register         
        .data_a_exe         (data_a_exe     ),
        .data_b_exe         (data_b_exe     ),
        .pc_exe             (pc_exe         ),
        .ins_exe            (ins_exe        ),
        .trd_exe            (trd_exe        ),
        .init_trd_dec       (init_trd_dec   ),

        // Decode       
        .reg_rd_a_exe       (reg_rd_a_exe   ),
        .reg_rd_b_exe       (reg_rd_b_exe   ),
        .reg_wr_exe         (reg_wr_exe     ),
        .imm_exe            (imm_exe        ),
        .wr_en_exe          (wr_en_exe      ),
        .wb_sel_exe         (wb_sel_exe     ),
        .alu_op_exe         (alu_op_exe     ),
        .mem_ctrl_exe       (mem_ctrl_exe   ),
        .trd_ctrl_exe       (trd_ctrl_exe   ),
        .exp_jmp_dec        (exp_jmp_dec    ),
        .exp_return_dec     (exp_return_dec ),
        .jmp_con_exe        (jmp_con_exe    ),
        .invalid_op         (inv_op         ),
        .i_type_exe         (i_type_exe     ),
        .init_trd_exe       (init_trd_exe   ),
        .new_trd_exe        (new_trd_exe    )
    );

    exe EXE
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),

        .ins_exe            (ins_exe        ),
        .data_a_exe         (data_a_exe     ),
        .data_b_exe         (data_b_exe     ),
        .imm_exe            (imm_exe        ),
        .alu_op_exe         (alu_op_exe     ),
        .i_type_exe         (i_type_exe     ),
        .reg_rd_a_exe       (reg_rd_a_exe   ),
        .reg_rd_b_exe       (reg_rd_b_exe   ),
        .jmp_con_exe        (jmp_con_exe    ),
        .pc_exe             (pc_exe         ),
        .trd_exe            (trd_exe        ),
        .wb_sel_exe         (wb_sel_exe     ),
        .flushEX            (flushEX        ),
        .stall              (stall          ),
        .trd_wb             (trd_wb         ),
        .reg_wr_wb          (reg_wr_wb      ),
        .wb_data_wb         (wb_data_wb     ),
        .wr_en_wb           (wr_en_wb       ),
        .new_trd_exe        (new_trd_exe    ),
        .init_trd_exe       (init_trd_exe   ),
        .mem_ctrl_exe       (mem_ctrl_exe   ),
        .trd_ctrl_exe       (trd_ctrl_exe   ),
        .wr_en_exe          (wr_en_exe      ),
        .reg_wr_exe         (reg_wr_exe     ),

        .addr_mem           (d_addr         ),
        .ins_mem            (ins_mem        ),
        .pc_mem             (pc_mem         ),
        .exe_data_mem       (exe_data_mem   ),
        .trd_mem            (trd_mem        ),
        .reg_wr_mem         (reg_wr_mem     ),
        .wr_en_mem          (wr_en_mem      ),
        .wb_sel_mem         (wb_sel_mem     ),
        .mem_ctrl_mem       (mem_ctrl_mem   ),
        .trd_ctrl_mem       (trd_ctrl_mem   ),
        .obj_trd_mem        (obj_trd_mem    ),
        .jmp_pc_exe         (jmp_pc         ),
        .jmp_en_exe         (jmp_en         ),
        .stall_exe          (stall_req      ), 
        .of_exe             (alu_exp        )
    );

    mem MEM
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),
        .d_addr_mem         (d_addr         ),
        .ins_mem            (ins_mem        ),
        .pc_mem             (pc_mem         ),
        .exe_data_mem       (exe_data_mem   ),
        .trd_mem            (trd_mem        ),
        .reg_wr_mem         (reg_wr_mem     ),
        .wr_en_mem          (wr_en_mem      ),
        .wb_sel_mem         (wb_sel_mem     ),
        .mem_ctrl_mem       (mem_ctrl_mem   ),
        .trd_ctrl_mem       (trd_ctrl_mem   ),
        .obj_trd_mem        (obj_trd_mem    ),
        .flushMEM           (flushMEM       ),
        .d_miss             (d_miss         ),

        .ins_wb             (ins_wb         ),
        .pc_wb              (pc_wb          ),
        .exe_data_wb        (exe_data_wb    ),
        .trd_wb             (trd_wb         ),
        .reg_wr_wb          (reg_wr_wb      ),
        .wr_en_wb           (wr_en_wb       ),
        .trd_ctrl_wb        (trd_ctrl_wb    ),
        .obj_trd_wb         (obj_trd_wb     ),
        .wb_sel_wb          (wb_sel_wb      ),

        .d_rd               (d_rd           ),
        .d_wr               (d_wr           ),
        .d_wr_data          (d_wr_data      )
    );

    wb WB(
        .exe_data_wb        (exe_data_wb    ),
        .trd_ctrl_wb        (trd_ctrl_wb    ),
        .wb_sel_wb          (wb_sel_wb      ),
        .d_rd_data          (d_rd_data      ),

        .wb_data_wb         (wb_data_wb     ),
        .kill               (kill           ),
        .sleep              (sleep          ),
        .wake               (wake           )
    );

endmodule