/*
 * Module name: d_cache
 * Engineer: Tommy Yee
 * Description: direct mapped data cache
 *              line/block size: 32 byte
 *              "address" size: 9 bit (0x00010200 to 0x000102FF) 
 *                  - actual input address is 20 bits, but we only care about lower 9 bits
 *              cache data size: 2 kilobytes
 * Dependency:
 * Status: developing
 */

// [-- tag: 0 bits --] [---------- index: 9 bits ----------] [---- offset: 0 bits ----]

module d_cache(
    input  logic                clk,
    input  logic                rst_n,
    input  logic [31:0]         addr_in,
	input  logic [31:0]         dma_addr_in,
	input  logic [31:0]         dma_data[0:15],
    input  logic [31:0]         wr_data, // 32-bit cache line to write
    input  logic                wr_en,
    input  logic                rd_en,
    input  logic [2:0]          cur_trd,

	output logic [31:0]         dma_wr_data,
	output logic [31:0]         dma_addr,
	output logic [1:0]          dma_mode, // 01 read, 10 write
    output logic [31:0]         wb_data,
    output logic                d_miss,
	output logic                d_cache_seg_fault // assert when trying to access out of range
);
	// memory declaration
    logic [33:0]                mem[0:511]; // {vld, dirty, data[31:0]}
	
	// internal signals
    logic [8:0]                 index;
	logic                       seg_f_en;
	
	assign index = addr_in[8:0];
	
    always_comb begin
        unique case(addr_in) inside
			// valid range
			[20'h10200:20'h102FF]: begin
				seg_f_en = 0;
			end
			// else outside accessible range: seg fault
			default: begin
				seg_f_en = 1;
			end
		endcase
	end
	
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            d_cache_seg_fault <= 0;
        else if(seg_f_en)
            d_cache_seg_fault <= 1;
		// else if(???) // what knocks down seg fault in case we recover?
			// TODO

    // TODO: check for miss
    
	// TODO: data array
endmodule