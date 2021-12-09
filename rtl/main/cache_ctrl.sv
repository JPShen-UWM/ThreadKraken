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

    typedef enum logic [2:0] {IDLE, D_COMPARE, D_ALLOC, D_WRITEBACK, I_COMPARE, I_ALLOC, I_WRITEBACK} state_t;
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
        .atomic     ()              ,
        //.i_cache_seg_fault()      ,  // assert when trying to access out of range
        .vld        (i_vld)         ,
        .index      (i_idx)
    );
    
    d_cache dMEMC(
        
    );
    
    assign i_miss = (i_rd && ~i_vld) | (i_rd && (d_rd|d_wr));
    assign d_miss = (d_rd && ~d_vld);

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
            default: begin
                if(d_rd|d_wr)
                    nxt_state = D_COMPARE;
                else if(i_rd)
                    nxt_state = I_COMPARE;
            end

            // check cache line (segfault occurs at MMU)
            I_COMPARE: begin
                // check tag if match and valid
                if(i_addr[8:0] == i_idx && i_vld) begin
                    nxt_state = I_ALLOC;
                end
                else 
            end
            
            I_ALLOC: begin
                
            end
            
            I_WRITEBACK: begin
            
            end
            
            // check cache line (segfault occurs at MMU)
            D_COMPARE: begin
                if(d_addr[8:0] == d_idx && d_vld) begin
                    
                end
                
            end
    end
endmodule