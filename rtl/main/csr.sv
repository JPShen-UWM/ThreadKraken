/*
 * Module name: csr
 * Engineer: Tommy Yee
 * Description: memory-mapped control status register
 * Dependency: 
 * Status: done
 */
 module csr
 #(
    parameter thr_id = 8'h00
 )
 (
    input  logic        clk,                // global clock
    input  logic        rst_n,              // global async active low reset
    input  logic        clr_ex,             // clear exception code and interrupt
    input  logic        i_cache_seg_fault,  // instr cache segfault
    input  logic        d_cache_seg_fault,  // data cache segfault
    input  logic        illegal_op,
    input  logic        alu_op_ex,          // from alu control
    input  logic        stack_overflow,
    input  logic        breakpoint,         // user breakpoint
    input  logic        cpu_error,          // some other unrecoverable error

    output logic [5:0]  ex_cause,           // 6 bit code for exception cause
    output logic [7:0]  cause_thr,
    output logic        csr_stall
);
    localparam          RESERVED   = 16'h0000;
    localparam          EX_CLR     = 6'h00;
    localparam          ALU_EX     = 6'h01;
    localparam          IL_OP      = 6'h05;
    localparam          STACK_OV   = 6'h0B;
    localparam          SEGFAULT   = 6'h12;
    localparam          BRKPT      = 6'h3F;

/*
 *  [    31     | 30 -------------------- 14 | 13 ---------- 6 | 5 -------- 0 ]
 *  [ csr_stall |          reserved          |    thread id    |    ex code   ]
 */
    logic [31:0]        ctrl_reg;           // 32-bit csr
    logic [5:0]         ex_code;
    
    // set csr with code or clear
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            ctrl_reg <= '0;
        else if(clr_ex)
            ctrl_reg <= {1'b0,RESERVED,thr_id,EX_CLR};
        else if(illegal_op || error)
            ctrl_reg <= {1'b1,RESERVED,thr_id,IL_OP};
        else if(stack_overflow)
            ctrl_reg <= {1'b1,RESERVED,thr_id,STACK_OV};
        else if(i_cache_seg_fault || d_cache_seg_fault)
            ctrl_reg <= {1'b1,RESERVED,thr_id,SEGFAULT};
        else if(breakpoint)
            ctrl_reg <= {1'b1,RESERVED,thr_id,BRKPT};

    // output thread status and id
    assign csr_stall = ctrl_reg[31];
    assign cause_thr = ctrl_reg[13:0];
    assign ex_cause = ctrl_reg[5:0];

endmodule