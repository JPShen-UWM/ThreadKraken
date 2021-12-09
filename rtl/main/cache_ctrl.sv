/*
 * Module name: cache_ctrl
 * Engineer: Tommy Yee
 * Description: cache control fsm
 * Dependency: MMU
 * Status: developing
 */
module cache_ctrl(
    input                   clk         ,
    input                   rst_n       ,
    
    input   logic   [31:0]  i_addr      ,
    input   logic           i_rd        ,       // read request from core
    output          [31:0]  i_rd_data   ,
    output                  i_miss      ,
    
    input   logic   [31:0]  d_addr      ,
    input   logic   [31:0]  d_wr_data   ,
    input   logic           d_rd        ,
    input   logic           d_wr        ,
    
    output          [31:0]  d_rd_data   ,
    output                  d_miss      ,
    
    // mem_ctrl status
    input   logic           tx_done     ,       // host done with read/write
    input   logic           ready               // host ready for read/write
);
    /////////////////////////////////////// internal signals ///////////////////////////////////////
    logic i_rd_req;
    logic i_wr_req;
    logic d_rd_req;
    logic d_wr_req;
    logic [8:0] i_idx;
    logic [8:0] d_idx;

    ////////////////////////////////////////// sm signals //////////////////////////////////////////
    logic clr_req;
    logic i_vld;
    logic d_vld;
    logic cache_rdy;

    typedef enum logic [1:0] {IDLE, COMPARE, ALLOC, WRITEBACK} state_t;
    state_t state, nxt_state;

    /////////////////////////////////////////// datapath ///////////////////////////////////////////
    i_cache iMEMC(
        .clk        (clk)           ,
        .rst_n      (rst_n)         ,
        .cur_pc     (i_addr)        ,
        .wr_ins     (i_rd_data),      // [31:0] wr_ins[0:15]
        .wr_en      (),
        .rd_en      (),

        .ins        (i_rd_data)     ,
        //.i_addr    (),
        //.i_miss     ()              ,
        .atomic     ()              ,
        .i_cache_seg_fault()      ,  // assert when trying to access out of range
        .vld        (i_vld)         ,
        .index      (i_idx)
    );
    
    d_cache dMEMC(
        
    );
    
    assign i_miss = (i_rd && ~i_vld) | (d_rd|d_wr);
    assign d_miss = (d_rd && ~d_vld);
    
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            i_rd_req <= 0;
            d_rd_req <= 0;
            d_wr_req <= 0;
        end
        else if(clr_req) begin
            i_rd_req <= 0;
            d_rd_req <= 0;
            d_wr_req <= 0;
        end
        else if(i_rd)
            i_rd_req <= 1;
        else if(d_rd)
            d_rd_req <= 1;
        else if(d_wr)
            d_wr_req <= 1;

    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            state <= IDLE;
        else
            state <= nxt_state;

    always_comb begin
        nxt_state = state;
        clr_req = 0;

        case(state)
            // wait for processor request
            IDLE: begin
                if(i_rd|d_rd|d_wr)
                    nxt_state = COMPARE;
            end

            // check cache line (segfault occurs at MMU)
            COMPARE: begin
                // check tag if match and valid
                if(i_addr[9:0] == i_idx && i_vld) begin
                    nxt_state = ALLOC;
                end
            end
            
            ALLOC: begin
                
            end
            
            WRITEBACK: begin
            
            end
    end
endmodule