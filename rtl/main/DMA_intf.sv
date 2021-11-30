/*
 * Module name: DMA_intf
 * Engineer: Tommy Yee
 * Description: Interface for cache to main memory. Implements the mem_ctrl as part of Winor's CLASS module.
 * Dependency: mem_ctrl, i_cache, d_cache, cache_ctrl
 * Status: developing/testing/done
 */
module DMA_intf
#(
	parameter WORD_SIZE = 32,
	parameter CL_SIZE_WIDTH = 512,
	parameter ADDR_BITCOUNT = 32
	
)
(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        host_init,
    input  logic                        i_miss,
    input  logic                        d_miss,
    input  logic [WORD_SIZE-1:0]        d_data_in,
    
    output logic [CL_SIZE_WIDTH-1:0]    host_data_bus_write_out,
    output logic [WORD_SIZE-1:0]        i_data_out[0:15],               // to cache
    output logic [WORD_SIZE-1:0]        d_data_out,               // to cache
);
    //////////////////////////////////////// internal signals ////////////////////////////////////////
    typedef enum logic [1:0] { IDLE = 2'b00, READ = 2'b01, WRITE = 2'b11 } opcode_t;
    opcode_t op;
    
    logic [31:0]        common_data_bus_write_out;      // from host
    // from host
    logic               ready;                          // from host, indicate ready for read/write
    logic               host_wr_ready;
    logic               host_rd_ready;
    logic
    logic [511:0]       host_data_bus_read_in;          // returns 512 bits (16 32-bit blocks)
    
    // state machine signals 
    logic               host_rgo;
    logic               host_wgo;
    logic               host_re;
    logic               host_we;
    logic               i_cache_wr;
    logic               d_cache_wr;
    
    typedef enum logic [2:0] { INIT, RDY, WAIT_RD, WAIT_WR, WB_CACHE, DONE } state_t;
    state_t state, nxt_state;
    
    ///////////////////////////////////// mem_ctrl instantiation /////////////////////////////////////
    /*
        module mem_ctrl(
            input wire clk,
            input wire rst_n,
            input wire host_init,
            input wire host_rd_ready,
            input wire host_wr_ready,

            input logic [1:0] op,

            input logic [31:0] common_data_bus_read_in, 
            output logic [31:0] common_data_bus_write_out, 

            input logic [511:0] host_data_bus_read_in,
            output logic [511:0] host_data_bus_write_out,

            output logic ready,
            output logic tx_done,
            output logic rd_valid,
            output logic host_re,
            output logic host_we,
            output logic host_rgo,
            output logic host_wgo
        );
    */
    mem_ctrl iMEMCTRL
    #(
        .WORD_SIZE(WORD_SIZE),
        .CL_SIZE_WIDTH(CL_SIZE_WIDTH),
        .ADDR_BITCOUNT(ADDR_BITCOUNT)
    )
    (
        .clk(clk),
        .rst_n(rst_n),
        .host_init(),                                           // need some input from cpu
        .host_rd_ready(host_rd_ready),                          // to host, read ready
        .host_wr_ready(host_wr_ready),                          // to host, write done

        .op(op),

        // cpu -> host
        .common_data_bus_read_in(),         
        .common_data_bus_write_out(common_data_bus_write_out), 

        // host -> cpu
        .host_data_bus_read_in(),
        .host_data_bus_write_out(),

        .ready(ready),
        .tx_done(),
        .rd_valid(),
        .host_re(host_re),
        .host_we(host_we),
        .host_rgo(host_rgo),
        .host_wgo(host_wgo)
    );
    
    // TODO: initiate DMA read in case of cache miss
            
    
    // TODO: state machine
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            state <= INIT;
        else
            state <= nxt_state;
            
    always_comb begin
        host_rgo = 0;
        host_wgo = 0;
    
    end
    
    ///////////////////////////////////// data returned from host ////////////////////////////////////
    // mem_ctrl returns data as 512 bit packed array, cache takes data as unpacked array of 16 32-bit words
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            {>>{i_data_out}} <= 512'h0;
            {>>{d_data_out}} <= 512'h0;
        end
        else if(i_cache_wr && rd_valid)
            {>>{i_data_out}} <= host_data_bus_read_in;
        else if(d_cache_wr && rd_valid)
            {>>{d_data_out}} <= host_data_bus_read_in;

endmodule