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
    input  logic        clk,
    input  logic        rst_n,
	input  logic [31:0] d_addr_in,
	input  logic [31:0] d_data_in[0:15],
    input  logic [31:0] wr_data, // 32-bit cache line to write
    input  logic        wr_en,
    input  logic        rd_en,

	output logic [31:0] d_data_out,
	output logic [31:0] d_addr_out,
    output logic        vld,
    output logic        dirty,
    output logic [8:0]  index
);
    // internal signals
    logic [33:0]        line;
    
	// memory declaration
    logic [33:0]        mem[0:511]; // {vld, dirty, data[31:0]}
	
	assign index = d_addr_in[8:0];
    
    // cache write
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            for(int i = 0; i < 512; i = i + 1)
                mem[i] <= 33'h0;
        end
        else if(wr_en) begin
            for(int i = 0; i < 16; i = i + 1)
                mem[index+i] <= {1'b1,1'b1,d_data_in[i]};
        end
        
    // return line of data
    assign line = mem[index];
    assign vld = line[33];
    assign dirty = line[32];
    assign d_data_out = line[31:0];
endmodule