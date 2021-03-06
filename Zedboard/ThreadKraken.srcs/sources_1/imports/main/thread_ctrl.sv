/*
 * Module name: thread_ctrl
 * Engineer: Jianping Shen
 * Description: Main thread controler in IF. Store the status of each thread, determine next thread, create, kill or sleep a thread.
 * Dependency: thread_csr
 * Status: Done
 */

//`include "header.svh"

module thread_ctrl(
    input               clk         ,
    input               rst_n       ,

    input               atomic      ,   // Do not increment thread pointer
    input               kill        ,   // Kill determined thread
    input               slp         ,   // Sleep the objective thread
    input               wake        ,   // wake up the objective thread
    input               init_trd    ,   // Init a new thread
    input [2:0]         act_trd     ,   // Act thread that sending the commend
    input [2:0]         obj_trd_in  ,   // Objective thread that being kill, sleep, or wake
    input               stall       ,   // Stall any action
    input [7:0]         trd_miss    ,   // Thread encounter a cache miss
    input               miss        ,   // Cache miss
    input [31:0]        init_pc     ,   // Initial pc for a new thread
    input [7:0]         pc_wr       ,
    input [31:0]        nxt_pc_0    ,
    input [31:0]        nxt_pc_1    ,
    input [31:0]        nxt_pc_2    ,
    input [31:0]        nxt_pc_3    ,
    input [31:0]        nxt_pc_4    ,
    input [31:0]        nxt_pc_5    ,
    input [31:0]        nxt_pc_6    ,
    input [31:0]        nxt_pc_7    ,

    output logic [2:0]  cur_trd     ,   // Current thread pointing to
    output logic [2:0]  nxt_trd     ,   // Next thread
    output logic [2:0]  new_trd     ,   // New thread that just been create
    output logic [7:0]  valid_trd   ,   // Threads that is valid
    output logic [7:0]  run_trd     ,   // Threads that is not sleeping
    output logic        trd_full    ,   // All threads are valid
    output logic        trd_of      ,   // Thread overflow: trying the create a new thread when all threads are used
    output logic        invalid_op  ,   // Trying to kill or sleep a thread that is not its child or itself
    output logic        error       ,   // Other unrecoverable error
    output logic [31:0] cur_pc      ,   // Current pc
    output logic [7:0]  child_0     ,   // Children thread of thread 0
    output logic [7:0]  child_1     ,   // Children thread of thread 1
    output logic [7:0]  child_2     ,   // Children thread of thread 2
    output logic [7:0]  child_3     ,   // Children thread of thread 3
    output logic [7:0]  child_4     ,   // Children thread of thread 4
    output logic [7:0]  child_5     ,   // Children thread of thread 5
    output logic [7:0]  child_6     ,   // Children thread of thread 6
    output logic [7:0]  child_7         // Children thread of thread 7
);
// Operation code
parameter CAL       =   4'b1111;
parameter CALI      =   4'b1110;
parameter SHIFT     =   4'b1100;
parameter LOADI     =   4'b1001;
parameter MEMOP     =   4'b1000;
parameter BRANCH    =   4'b1010;
parameter EXC       =   4'b0000;
parameter MULTI     =   4'b0110;

// Function code
parameter ADD       =   3'b110;
parameter NOT       =   3'b000;
parameter AND       =   3'b111;
parameter OR        =   3'b101;
parameter XOR       =   3'b011;
parameter SHLT      =   3'b001;
parameter SHRT      =   3'b010;
parameter SHAR      =   3'b100;
parameter LBI       =   3'b001;
parameter SLB       =   3'b010;

// PC Address
parameter START_PC  =   32'h0001_0100;
parameter HANDLER   =   32'h0001_0000;

// Init and end stack for each thread
parameter TRD0_INIT_ESP = 32'h0001_0FFF;
parameter TRD1_INIT_ESP = 32'h0001_0DFF;
parameter TRD2_INIT_ESP = 32'h0001_0CFF;
parameter TRD3_INIT_ESP = 32'h0001_0BFF;
parameter TRD4_INIT_ESP = 32'h0001_0AFF;
parameter TRD5_INIT_ESP = 32'h0001_09FF;
parameter TRD6_INIT_ESP = 32'h0001_08FF;
parameter TRD7_INIT_ESP = 32'h0001_07FF;

parameter TRD0_END_ESP = 32'h0001_0E00;
parameter TRD1_END_ESP = 32'h0001_0D00;
parameter TRD2_END_ESP = 32'h0001_0C00;
parameter TRD3_END_ESP = 32'h0001_0B00;
parameter TRD4_END_ESP = 32'h0001_0A00;
parameter TRD5_END_ESP = 32'h0001_0900;
parameter TRD6_END_ESP = 32'h0001_0800;
parameter TRD7_END_ESP = 32'h0001_0700;
    logic [31:0] cur_pc_0, cur_pc_1, cur_pc_2, cur_pc_3,
                 cur_pc_4, cur_pc_5, cur_pc_6, cur_pc_7;
    // logic [31:0] nxt_pc_0, nxt_pc_1, nxt_pc_2, nxt_pc_3,
    //              nxt_pc_4, nxt_pc_5, nxt_pc_6, nxt_pc_7;
    logic [7:0] csr_error;
    logic [2:0] obj_trd;
    logic init;     // Init a new thread
    logic [2:0] par_trd_0, par_trd_1, par_trd_2, par_trd_3, 
                par_trd_4, par_trd_5, par_trd_6, par_trd_7;
    //logic [7:0] child_0, child_1, child_2, child_3,
    //            child_4, child_5, child_6, child_7;
    logic [2:0] nxt_new_trd;

    assign trd_full = &valid_trd;
    assign trd_of = trd_full;
    // Child determine
    assign child_0[0] = valid_trd[0] & (par_trd_0 == 0);
    assign child_0[1] = valid_trd[1] & (par_trd_1 == 0);
    assign child_0[2] = valid_trd[2] & (par_trd_2 == 0);
    assign child_0[3] = valid_trd[3] & (par_trd_3 == 0);
    assign child_0[4] = valid_trd[4] & (par_trd_4 == 0);
    assign child_0[5] = valid_trd[5] & (par_trd_5 == 0);
    assign child_0[6] = valid_trd[6] & (par_trd_6 == 0);
    assign child_0[7] = valid_trd[7] & (par_trd_7 == 0);
    
    assign child_1[0] = valid_trd[0] & (par_trd_0 == 1);
    assign child_1[1] = valid_trd[1] & (par_trd_1 == 1);
    assign child_1[2] = valid_trd[2] & (par_trd_2 == 1);
    assign child_1[3] = valid_trd[3] & (par_trd_3 == 1);
    assign child_1[4] = valid_trd[4] & (par_trd_4 == 1);
    assign child_1[5] = valid_trd[5] & (par_trd_5 == 1);
    assign child_1[6] = valid_trd[6] & (par_trd_6 == 1);
    assign child_1[7] = valid_trd[7] & (par_trd_7 == 1);

    assign child_2[0] = valid_trd[0] & (par_trd_0 == 2);
    assign child_2[1] = valid_trd[1] & (par_trd_1 == 2);
    assign child_2[2] = valid_trd[2] & (par_trd_2 == 2);
    assign child_2[3] = valid_trd[3] & (par_trd_3 == 2);
    assign child_2[4] = valid_trd[4] & (par_trd_4 == 2);
    assign child_2[5] = valid_trd[5] & (par_trd_5 == 2);
    assign child_2[6] = valid_trd[6] & (par_trd_6 == 2);
    assign child_2[7] = valid_trd[7] & (par_trd_7 == 2);

    assign child_3[0] = valid_trd[0] & (par_trd_0 == 3);
    assign child_3[1] = valid_trd[1] & (par_trd_1 == 3);
    assign child_3[2] = valid_trd[2] & (par_trd_2 == 3);
    assign child_3[3] = valid_trd[3] & (par_trd_3 == 3);
    assign child_3[4] = valid_trd[4] & (par_trd_4 == 3);
    assign child_3[5] = valid_trd[5] & (par_trd_5 == 3);
    assign child_3[6] = valid_trd[6] & (par_trd_6 == 3);
    assign child_3[7] = valid_trd[7] & (par_trd_7 == 3);

    assign child_4[0] = valid_trd[0] & (par_trd_0 == 4);
    assign child_4[1] = valid_trd[1] & (par_trd_1 == 4);
    assign child_4[2] = valid_trd[2] & (par_trd_2 == 4);
    assign child_4[3] = valid_trd[3] & (par_trd_3 == 4);
    assign child_4[4] = valid_trd[4] & (par_trd_4 == 4);
    assign child_4[5] = valid_trd[5] & (par_trd_5 == 4);
    assign child_4[6] = valid_trd[6] & (par_trd_6 == 4);
    assign child_4[7] = valid_trd[7] & (par_trd_7 == 4);

    assign child_5[0] = valid_trd[0] & (par_trd_0 == 5);
    assign child_5[1] = valid_trd[1] & (par_trd_1 == 5);
    assign child_5[2] = valid_trd[2] & (par_trd_2 == 5);
    assign child_5[3] = valid_trd[3] & (par_trd_3 == 5);
    assign child_5[4] = valid_trd[4] & (par_trd_4 == 5);
    assign child_5[5] = valid_trd[5] & (par_trd_5 == 5);
    assign child_5[6] = valid_trd[6] & (par_trd_6 == 5);
    assign child_5[7] = valid_trd[7] & (par_trd_7 == 5);
    
    assign child_6[0] = valid_trd[0] & (par_trd_0 == 6);
    assign child_6[1] = valid_trd[1] & (par_trd_1 == 6);
    assign child_6[2] = valid_trd[2] & (par_trd_2 == 6);
    assign child_6[3] = valid_trd[3] & (par_trd_3 == 6);
    assign child_6[4] = valid_trd[4] & (par_trd_4 == 6);
    assign child_6[5] = valid_trd[5] & (par_trd_5 == 6);
    assign child_6[6] = valid_trd[6] & (par_trd_6 == 6);
    assign child_6[7] = valid_trd[7] & (par_trd_7 == 6);

    assign child_7[0] = valid_trd[0] & (par_trd_0 == 7);
    assign child_7[1] = valid_trd[1] & (par_trd_1 == 7);
    assign child_7[2] = valid_trd[2] & (par_trd_2 == 7);
    assign child_7[3] = valid_trd[3] & (par_trd_3 == 7);
    assign child_7[4] = valid_trd[4] & (par_trd_4 == 7);
    assign child_7[5] = valid_trd[5] & (par_trd_5 == 7);
    assign child_7[6] = valid_trd[6] & (par_trd_6 == 7);
    assign child_7[7] = valid_trd[7] & (par_trd_7 == 7);
    /*
    always_comb begin
        case(act_trd)
            3'b000: child_trd = child_0;
            3'b001: child_trd = child_1;
            3'b010: child_trd = child_2;
            3'b011: child_trd = child_3;
            3'b100: child_trd = child_4;
            3'b101: child_trd = child_5;
            3'b110: child_trd = child_6;
            3'b111: child_trd = child_7;
        endcase
    end
    */
    // Cache miss control
    logic [5:0] delay_count;
    logic [7:0] wait_trd;
    logic [7:0] on_trd;
    assign run_trd = on_trd & ~wait_trd & ~trd_miss;
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            delay_count <= 0;
            wait_trd <= 8'b0;
        end
        else begin
            delay_count <= delay_count + 1;
            if(delay_count == 0) wait_trd <= 8'b0;
            else if(miss) begin
                wait_trd <= wait_trd | trd_miss;
            end
        end
    end

    logic [2:0] last_trd, cur_trd_tmp;

    // Thread pointer
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            last_trd <= 0;
            cur_trd_tmp <= 0;
        end
        else begin
            last_trd <= cur_trd;
            cur_trd_tmp <= nxt_trd;
        end
    end

    // Initial init
    logic rst_init;
    always_ff @(posedge clk) begin
        rst_init <= !rst_n;
    end
    assign cur_trd = (atomic|stall)? last_trd: cur_trd_tmp;
    always_comb begin
        nxt_trd = 0;
        case(cur_trd)
            3'b000: begin
                if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else nxt_trd = 0;
            end
            3'b001: begin
                if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else nxt_trd = 1;
            end
            3'b010: begin
                if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else nxt_trd = 2;
            end
            3'b011: begin
                if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else nxt_trd = 3;
            end
            3'b100: begin
                if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else nxt_trd = 4; 
            end
            3'b101: begin
                if(run_trd[6]) nxt_trd = 6;
                else if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else nxt_trd = 5; 
            end
            3'b110: begin
                if(run_trd[7]) nxt_trd = 7;
                else if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else nxt_trd = 6; 
            end
            3'b111: begin
                if(run_trd[0]) nxt_trd = 0;
                else if(run_trd[1]) nxt_trd = 1;
                else if(run_trd[2]) nxt_trd = 2;
                else if(run_trd[3]) nxt_trd = 3;
                else if(run_trd[4]) nxt_trd = 4;
                else if(run_trd[5]) nxt_trd = 5;
                else if(run_trd[6]) nxt_trd = 6;
                else nxt_trd = 7; 
            end
        endcase
        //if(stall | atomic) nxt_trd = cur_trd;
    end


    // New Thread pointer
    assign new_trd = nxt_new_trd;

    always_comb begin
        nxt_new_trd = 0;
        if(!valid_trd[0]) nxt_new_trd = 0;
        else if(!valid_trd[1]) nxt_new_trd = 1;
        else if(!valid_trd[2]) nxt_new_trd = 2;
        else if(!valid_trd[3]) nxt_new_trd = 3;
        else if(!valid_trd[4]) nxt_new_trd = 4;
        else if(!valid_trd[5]) nxt_new_trd = 5;
        else if(!valid_trd[6]) nxt_new_trd = 6;
        else if(!valid_trd[7]) nxt_new_trd = 7;
    end

    assign init = init_trd | rst_init;
    assign obj_trd = init? nxt_new_trd: obj_trd_in;
    
    logic [31:0] last_pc;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) last_pc <= 0;
        else last_pc <= cur_pc;
    end
    // Current pc
    always_comb begin
        cur_pc = HANDLER;
        case(cur_trd)
            3'b000: cur_pc = cur_pc_0;
            3'b001: cur_pc = cur_pc_1;
            3'b010: cur_pc = cur_pc_2;
            3'b011: cur_pc = cur_pc_3;
            3'b100: cur_pc = cur_pc_4;
            3'b101: cur_pc = cur_pc_5;
            3'b110: cur_pc = cur_pc_6;
            3'b111: cur_pc = cur_pc_7;
        endcase
        if(stall) cur_pc = last_pc;
    end
    // 8 thread csr
    thread_csr_0
    CSR_0
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (START_PC),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_0), 
        .pc_wr      (pc_wr[0]),  
        .cur_pc     (cur_pc_0), 
        .par_trd    (par_trd_0),
        .valid      (valid_trd[0]),  
        .running    (on_trd[0]),      
        .error      (csr_error[0])
    );

    thread_csr_1
    CSR_1
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_1), 
        .pc_wr      (pc_wr[1]),  
        .cur_pc     (cur_pc_1), 
        .par_trd    (par_trd_1),
        .valid      (valid_trd[1]),  
        .running    (on_trd[1]),      
        .error      (csr_error[1])
    );

    thread_csr_2
    CSR_2
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_2), 
        .pc_wr      (pc_wr[2]),  
        .cur_pc     (cur_pc_2), 
        .par_trd    (par_trd_2),
        .valid      (valid_trd[2]),  
        .running    (on_trd[2]),      
        .error      (csr_error[2])
    );

    thread_csr_3
    CSR_3
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_3), 
        .pc_wr      (pc_wr[3]),  
        .cur_pc     (cur_pc_3), 
        .par_trd    (par_trd_3),
        .valid      (valid_trd[3]),  
        .running    (on_trd[3]),      
        .error      (csr_error[3])
    );

    thread_csr_4
    CSR_4
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_4), 
        .pc_wr      (pc_wr[4]),  
        .cur_pc     (cur_pc_4), 
        .par_trd    (par_trd_4),
        .valid      (valid_trd[4]),  
        .running    (on_trd[4]),      
        .error      (csr_error[4])
    );

    thread_csr_5
    CSR_5
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_5), 
        .pc_wr      (pc_wr[5]),  
        .cur_pc     (cur_pc_5), 
        .par_trd    (par_trd_5),
        .valid      (valid_trd[5]),  
        .running    (on_trd[5]),      
        .error      (csr_error[5])
    );

    thread_csr_6
    CSR_6
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_6), 
        .pc_wr      (pc_wr[6]),  
        .cur_pc     (cur_pc_6), 
        .par_trd    (par_trd_6),
        .valid      (valid_trd[6]),  
        .running    (on_trd[6]),      
        .error      (csr_error[6])
    );

    thread_csr_7
    CSR_7
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .init       (init),   
        .init_pc    (init_pc),
        .slp        (slp),    
        .kill       (kill),   
        .wake       (wake),   
        .obj_trd    (obj_trd),
        .act_trd    (act_trd),
        .nxt_pc     (nxt_pc_7), 
        .pc_wr      (pc_wr[7]),  
        .cur_pc     (cur_pc_7), 
        .par_trd    (par_trd_7),
        .valid      (valid_trd[7]),  
        .running    (on_trd[7]),      
        .error      (csr_error[7])
    );
    assign error = trd_full & init;
    assign invalid_op = |csr_error;
endmodule