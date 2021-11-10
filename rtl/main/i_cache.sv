/*
 * Module name: i_cache
 * Engineer: Tommy Yee
 * Description: direct mapped instruction cache
 *              line/block size: 32 byte
 *              "address" size: 9 bit (0x00010000 to 0x000101FF) 
 *                  - actual input address is 20 bits, but we only care about lower 9 bits
 *              cache data size: 2 kilobytes
 * Dependency:
 * Status: developing
 */

// [-- tag: 0 bits --] [---------- index: 9 bits ----------] [---- offset: 0 bits ----]

module i_cache(
    input  logic                clk,
    input  logic                rst_n,
	input  logic [7:0]          cur_pc,
    input  logic [19:0]         addr_in,
    input  logic [31:0]         wr_ins, // 32-bit cache line to write
    input  logic                wr_en,
    input  logic                rd_en,

    output logic [31:0]         ins,
    output logic                miss,
	output logic                atomic,
	output logic                i_cache_seg_fault // assert when trying to access out of range
);
    logic [31:0]                mem[0:511]; // 16kB cache, 4 byte line
    logic [8:0]                 index;
	logic                       seg_f_en;
	
/* 	assign tag = addr_in[19:17];
	assign index = addr_in[16:5];
	assign offset = addr_in[4:0]; */
	
	assign index = addr_in[8:0];
	
    always_comb begin
		// default outputs
		seg_f_en = 0;
		
		
        unique case(addr_in) inside
			// valid range
			[20'h10000:20'h101FF]: begin
				// TODO
			end
			// else outside accessible range: seg fault
			default: begin
				seg_f_en = 1;
			end
		endcase
	end
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			i_cache_seg_fault <= 0;
		else if(seg_f_en)
			i_cache_seg_fault <= 1;
		// else if(???)
			// TODO

 endmodule