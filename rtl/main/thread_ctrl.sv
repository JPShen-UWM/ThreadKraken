/*
 * Module name: thread_ctrl
 * Engineer: Jianping Shen
 * Description: Main thread controler in IF. Store the status of each thread, determine next thread, create, kill or sleep a thread.
 * Dependency: thread_csr
 * Status: developing
 */

`include "header.svh"

module thread_ctrl(
    input               clk         ,
    input               rst_n       ,

    input               atomic      ,   // Do not increment thread pointer
    input               kill        ,   // Kill determined thread
    input               slp         ,   // Sleep the objective thread
    input               wake        ,   // wake up the objective thread
    input               init_trd    ,   // Init a new thread
    input [2:0]         act_trd     ,   // Act thread that sending the commend
    input [2:0]         obj_trd     ,   // Objective thread that being kill, sleep, or wake
    input               stall       ,   // Stall any action
    input [31:0]        init_pc     ,   // Initial pc for a new thread

    output logic [2:0]  cur_trd     ,   // Current thread pointing to
    output logic [2:0]  nxt_trd     ,   // Next thread
    output logic [2:0]  new_trd     ,   // New thread that just been create
    output logic [7:0]  valid_trd   ,   // Threads that is valid
    output logic [7:0]  run_trd     ,   // Threads that is not sleeping
    output logic        trd_full    ,   // All threads are valid
    output logic        trd_of      ,   // Thread overflow: trying the create a new thread when all threads are used
    output logic        invalid_op  ,   // Trying to kill or sleep a thread that is not its child or itself
    output logic        error       ,   // Other unrecoverable error
    output logic        cur_pc      ,   // Current pc
    output logic [7:0]  child_trd       // Children thread of act_trd
);

    logic [31:0] cur_pc_0, cur_pc_1, cur_pc_2, cur_pc_3,
                 cur_pc_4, cur_pc_5, cur_pc_6, cur_pc_7;
    logic [31:0] nxt_pc_0, nxt_pc_1, nxt_pc_2, nxt_pc_3,
                 nxt_pc_4, nxt_pc_5, nxt_pc_6, nxt_pc_7;
    logic [7:0] csr_error;
    logic [7:0] pc_wr;
    logic init;     // Init a new thread
    logic [2:0] par_trd_0, par_trd_1, par_trd_2, par_trd_3, 
                par_trd_4, par_trd_5, par_trd_6, par_trd_7;
    logic [7:0] child_0, child_1, child_2, child_3,
                child_4, child_5, child_6, child_7;

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
    // Thread pointer
    always_ff @(posedge clk, negedge rst_n) begin
        if(rst_n) cur_trd <= 0;
        else cur_trd <= nxt_trd;
    end

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
        if(stall | atomic) nxt_trd = cur_trd;
    end


    // 8 thread csr
    thread_crs #( parameter TRD_ID = 0 )
    CSR_0
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
        .nxt_pc     (nxt_pc_0), 
        .pc_wr      (pc_wr[0]),  
        .cur_pc     (cur_pc_0), 
        .par_trd    (par_trd_0),
        .valid      (valid_trd[0]),  
        .running    (run_trd[0]),      
        .error      (csr_error[0])
    );

    thread_crs #( parameter TRD_ID = 1 )
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
        .running    (run_trd[1]),      
        .error      (csr_error[1])
    );

    thread_crs #( parameter TRD_ID = 2 )
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
        .running    (run_trd[2]),      
        .error      (csr_error[2])
    );

    thread_crs #( parameter TRD_ID = 3 )
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
        .running    (run_trd[3]),      
        .error      (csr_error[3])
    );

    thread_crs #( parameter TRD_ID = 4 )
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
        .running    (run_trd[4]),      
        .error      (csr_error[4])
    );

    thread_crs #( parameter TRD_ID = 5 )
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
        .nxt_pc     (nxt_pc_0), 
        .pc_wr      (pc_wr[5]),  
        .cur_pc     (cur_pc_5), 
        .par_trd    (par_trd_5),
        .valid      (valid_trd[5]),  
        .running    (run_trd[5]),      
        .error      (csr_error[5])
    );

    thread_crs #( parameter TRD_ID = 6 )
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
        .running    (run_trd[6]),      
        .error      (csr_error[6])
    );

    thread_crs #( parameter TRD_ID = 7 )
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
        .running    (run_trd[7]),      
        .error      (csr_error[7])
    );

    assign invalid_op = |csr_error;
endmodule