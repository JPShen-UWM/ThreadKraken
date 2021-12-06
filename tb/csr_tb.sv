module csr_tb();

    // DUT inputs
    logic clk;
    logic rst_n;
    logic clr_ex;
    logic i_cache_seg_fault;
    logic d_cache_seg_fault;
    logic illegal_op;
    logic alu_op_ex;
    logic stack_overflow;
    logic breakpoint;
    logic cpu_error;

    // DUT outputs
    logic [5:0] ex_code;
    logic [7:0] thr_id;
    logic csr_stall;
    
    localparam          EX_CLR     = 6'h00;
    localparam          ALU_EX     = 6'h01;
    localparam          IL_OP      = 6'h05;
    localparam          STACK_OV   = 6'h0B;
    localparam          SEGFAULT   = 6'h12;
    localparam          BRKPT      = 6'h3F;
    
    // instantiation of DUT
    csr #(.ID(8'h01)) iDUT(.*);
    
    initial begin
        // initialize
        clk = 0;
        rst_n = 0;
        clr_ex = 0;
        i_cache_seg_fault = 0;
        d_cache_seg_fault = 0;
        illegal_op = 0;
        alu_op_ex = 0;
        stack_overflow = 0;
        breakpoint = 0;
        cpu_error = 0;
        @(posedge clk);
        @(negedge clk);
        rst_n = 1;
        
        // ===================================================================
        // TEST 1: RESET
        // ===================================================================
        if(thr_id != 8'h01)
            $display("ERROR: thr_id is %h",thr_id);
            
        if(csr_stall != 0)
            $display("ERROR: stall asserted out of reset. Code: %h",ex_code);
        
        // ===================================================================
        // TEST 2: SEGFAULT
        // ===================================================================
        // test segfault
        i_cache_seg_fault = 1;
        @(posedge clk);
        i_cache_seg_fault = 0;
        
        @(posedge clk);
        
        if(csr_stall != 1)
            $display("ERROR: segfault not asserted.");
            
        if(ex_code != SEGFAULT)
            $display("ERROR: segfault ex_code incorrect. %h",ex_code);
            
        @(posedge clk);
            
        // test clear
        clr_ex = 1;
        @(posedge clk);
        clr_ex = 0;
        
        @(posedge clk);
        
        if(csr_stall != 0)
            $display("ERROR: interrupt not cleared.");
            
        if(ex_code != 0)
            $display("ERROR: ex_code not cleared.");
            
        @(posedge clk);
        
        // ===================================================================
        // TEST 3: ALU
        // =================================================================== 
        // test alu exception
        alu_op_ex = 1;
        @(posedge clk);
        alu_op_ex = 0;
        
        @(posedge clk);
        
        if(csr_stall != 1)
            $display("ERROR: alu_ex not asserted.");
            
        if(ex_code != ALU_EX)
            $display("ERROR: alu_ex ex_code incorrect. %h",ex_code);
        
        @(posedge clk);
            
        // test clear
        clr_ex = 1;
        @(posedge clk);
        clr_ex = 0;
        
        @(posedge clk);
        
        if(csr_stall != 0)
            $display("ERROR: interrupt not cleared.");
            
        if(ex_code != 0)
            $display("ERROR: ex_code not cleared.");
            
        @(posedge clk);
        
        // ===================================================================
        // TEST 4: ILLEGAL OP
        // ===================================================================
        // test illegal op
        illegal_op = 1;
        @(posedge clk);
        illegal_op = 0;
        
        @(posedge clk);
        
        if(csr_stall != 1)
            $display("ERROR: illegal_op not asserted.");
            
        if(ex_code != IL_OP)
            $display("ERROR: illegal_op ex_code incorrect. %h",ex_code);
        
        @(posedge clk);
            
        // test clear
        clr_ex = 1;
        @(posedge clk);
        clr_ex = 0;
        
        @(posedge clk);
        
        if(csr_stall != 0)
            $display("ERROR: interrupt not cleared.");
            
        if(ex_code != 0)
            $display("ERROR: ex_code not cleared.");
            
        @(posedge clk);
        
        // ===================================================================
        // TEST 5: BREAKPOINT
        // ===================================================================
        // test illegal op
        breakpoint = 1;
        @(posedge clk);
        breakpoint = 0;
        
        @(posedge clk);
        
        if(csr_stall != 1)
            $display("ERROR: breakpoint not asserted.");
            
        if(ex_code != BRKPT)
            $display("ERROR: breakpoint ex_code incorrect. %h",ex_code);
        
        @(posedge clk);
            
        // test clear
        clr_ex = 1;
        @(posedge clk);
        clr_ex = 0;
        
        @(posedge clk);
        
        if(csr_stall != 0)
            $display("ERROR: interrupt not cleared.");
            
        if(ex_code != 0)
            $display("ERROR: ex_code not cleared.");
            
        @(posedge clk);
        
        $display("End of tests... check transcript for log.");
        $stop;
    end
    
    always #5 clk = ~clk;
    
endmodule