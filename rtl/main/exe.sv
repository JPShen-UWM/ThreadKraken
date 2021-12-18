/*
 * Module name: exe
 * Engineer: Jianping Shen
 * Description: Execution stage of pipeline
 * Dependency: alu, pc_cal
 * Status: developing
**/
//`include "header.svh"
module exe(
    input                   clk         ,
    input                   rst_n       ,

    input           [31:0]  ins_exe     ,
    input           [31:0]  data_a_exe  ,
    input           [31:0]  data_b_exe  ,
    input           [15:0]  imm_exe     ,
    input           [2:0]   alu_op_exe  ,
    input                   i_type_exe  ,
    input           [4:0]   reg_rd_a_exe,
    input           [4:0]   reg_rd_b_exe,
    input           [3:0]   jmp_con_exe ,
    input           [31:0]  pc_exe      ,
    input           [2:0]   trd_exe     ,
    input                   wb_sel_exe  ,
    input                   flushEX     ,
    input                   stall       ,
    input           [2:0]   trd_wb      ,
    input           [4:0]   reg_wr_wb   ,
    input           [31:0]  wb_data_wb  ,
    input                   wr_en_wb    ,
    input           [1:0]   mem_ctrl_exe,
    input           [2:0]   trd_ctrl_exe,
    input                   wr_en_exe   ,
    input           [4:0]   reg_wr_exe  ,

    output  logic   [31:0]  addr_mem    ,
    output  logic   [31:0]  ins_mem     ,
    output  logic   [31:0]  pc_mem      ,
    output  logic   [31:0]  exe_data_mem,
    output  logic   [2:0]   trd_mem     ,
    output  logic   [4:0]   reg_wr_mem  ,
    output  logic           wr_en_mem   ,
    output  logic           wb_sel_mem  ,
    output  logic   [1:0]   mem_ctrl_mem,
    output  logic   [2:0]   trd_ctrl_mem,
    output  logic   [2:0]   obj_trd_mem ,
    output  logic   [31:0]  new_pc_mem  ,
    output  logic   [31:0]  new_data_mem,

    output  logic   [31:0]  jmp_pc_exe  ,
    output  logic           jmp_en_exe  ,
    output  logic           stall_exe   ,   // Stall because data hazard
    
    output  logic           of_exe      
);

    logic [31:0] exe_data_exe;
    logic [31:0] data_a_for, data_b_for;
    logic [31:0] alu_out_exe;

    assign exe_data_exe = &jmp_con_exe[2:0]? pc_exe:
                          mem_ctrl_exe[1]? data_b_for:
                          alu_out_exe;


    // Forward control
    always_comb begin
        data_a_for = data_a_exe;
        data_b_for = data_b_exe;
        stall_exe = 0;
        // Forwarding a
        if(trd_mem == trd_exe & wr_en_mem & reg_rd_a_exe == reg_wr_mem) begin
            if(wb_sel_mem) begin
                stall_exe = 1;
            end
            else begin
                if(reg_rd_a_exe == reg_wr_mem & |reg_wr_mem) data_a_for = exe_data_mem;
            end
        end
        else if(trd_exe == trd_wb & wr_en_wb) begin
            if(reg_rd_a_exe == reg_wr_wb & |reg_wr_wb) data_a_for = wb_data_wb;
        end

        // Forwarding b
        if(trd_mem == trd_exe & wr_en_mem & reg_rd_b_exe == reg_wr_mem) begin
            if(wb_sel_mem) begin
                stall_exe = 1;
            end
            else begin
                if(reg_rd_b_exe == reg_wr_mem & |reg_wr_mem) data_b_for = exe_data_mem;
            end
        end
        else if(trd_exe == trd_wb & wr_en_wb) begin
            if(reg_rd_b_exe == reg_wr_wb & |reg_wr_wb) data_b_for = wb_data_wb;
        end
    end



    alu ALU(
        .Ain        (data_a_for ),
        .Bin        (data_b_for ),
        .imm        (imm_exe    ),        
        .alu_op     (alu_op_exe ),
        .i_type     (i_type_exe ),     
        .alu_out    (alu_out_exe),
        .eq         (eq         ),         
        .lt         (lt         ),         
        .overflow   (of_exe     ) 
    );

    pc_cal PC_CAL(
        .cur_pc  (pc_exe        ),
        .imm     (imm_exe[11:0] ),
        .data_a  (data_a_for    ),
        .jmp_con (jmp_con_exe   ),
        .eq      (eq            ),
        .lt      (lt            ),
        .jmp_pc  (jmp_pc_exe    ),
        .jmp_en  (jmp_en_exe    )
    );

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            addr_mem    <= 0;
            ins_mem     <= 0;
            pc_mem      <= 0;
            exe_data_mem<= 0;
            trd_mem     <= 0;
            reg_wr_mem  <= 0;
            wr_en_mem   <= 0;
            wb_sel_mem  <= 0;
            mem_ctrl_mem<= 0;
            trd_ctrl_mem<= 0;
            obj_trd_mem <= 0;
            new_pc_mem  <= 0;
            new_data_mem<= 0;
        end
		  else if(flushEX) begin
            addr_mem    <= 0;
            ins_mem     <= 0;
            pc_mem      <= 0;
            exe_data_mem<= 0;
            trd_mem     <= 0;
            reg_wr_mem  <= 0;
            wr_en_mem   <= 0;
            wb_sel_mem  <= 0;
            mem_ctrl_mem<= 0;
            trd_ctrl_mem<= 0;
            obj_trd_mem <= 0;
            new_pc_mem  <= 0;
            new_data_mem<= 0;
        end
		  else if(stall) begin
            addr_mem    <= 0;
            ins_mem     <= 0;
            pc_mem      <= 0;
            exe_data_mem<= 0;
            trd_mem     <= 0;
            reg_wr_mem  <= 0;
            wr_en_mem   <= 0;
            wb_sel_mem  <= 0;
            mem_ctrl_mem<= 0;
            trd_ctrl_mem<= 0;
            obj_trd_mem <= 0;
            new_pc_mem  <= 0;
            new_data_mem<= 0;
        end
        else begin
            addr_mem    <= alu_out_exe;
            ins_mem     <= ins_exe;
            pc_mem      <= pc_exe;
            exe_data_mem<= exe_data_exe;
            trd_mem     <= trd_exe;
            reg_wr_mem  <= reg_wr_exe;
            wr_en_mem   <= wr_en_exe;
            wb_sel_mem  <= wb_sel_exe;
            mem_ctrl_mem<= mem_ctrl_exe;
            trd_ctrl_mem<= trd_ctrl_exe;
            obj_trd_mem <= data_a_for[2:0];
            new_pc_mem  <= data_a_for;
            new_data_mem<= data_b_for;
        end
    end
endmodule

