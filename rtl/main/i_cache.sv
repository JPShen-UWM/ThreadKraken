/*
 * Module name: i_cache
 * Engineer: Tommy Yee
 * Description: 16kB direct mapped instruction cache - large enough to not need an eviction policy
 *              line/block size: 32 byte
 *              "address" size: 9 bit (0x00010000 to 0x000101FF) 
 *                  - actual input address is 20 bits, but we only care about lower 9 bits
 *              cache data size: 2 kilobytes
 * Dependency:
 * Status: developing
 */

// [-- tag: 0 bits --] [---------- index: 9 bits ----------] [---- offset: 0 bits ----]

module i_cache(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] cur_pc,
    input  logic [31:0] rd_ins[0:15],            // 32-bit cache line to read from memory
    input  logic        wr_en,
    input  logic        rd_en,
    // input  logic       INT,             // from interrupt handler, int enable

    output logic [31:0] ins,
    output logic [31:0] i_addr,
    output logic        i_miss,
    output logic        atomic,
    output logic        i_cache_seg_fault  // assert when trying to access out of range
);
    logic [32:0]        mem[0:511];        // {valid,ins[31:0]}
    logic [8:0]         index;
    logic               seg_f_en;
    // logic [511:0]               hit;      // this is probably stupid
    
	// cache is large enough for everything in memory so only index bits
    // assign index = cur_pc[8:0];

    // cache read/write
    always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) begin
			ins <= 32'h0;
			for(index = 0; index < 512; index = index + 1)
				mem[index] <= 33'h0;
		end
		else if(rd_en && ~seg_f_en) begin
			ins <= mem[cur_pc[8:0]][31:0];
		end
		else if(wr_en && ~seg_f_en) begin
			for(int i = 0; i < 16; i = i+1)
				mem[index+i] <= {1'b1,wr_ins[i]};
		end
    
	// read/write must be in range of valid addresses
    always_comb begin
        // default outputs
        seg_f_en = 0;
        
        unique case(cur_pc) inside
            // instr memory in range x0001_0000 to x0001_01FF
            [32'h10000:32'h101FF]: begin
                seg_f_en = 0;
            end
            // else outside accessible range: seg fault
            default: begin
                seg_f_en = 1;
            end
        endcase
    end
    
    // seg. fault is unrecoverable
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            i_cache_seg_fault <= 0;
        else if(seg_f_en)
            i_cache_seg_fault <= 1;

    // cache miss
	assign miss = (rd_en && mem[cur_pc[8:0]][32]);
	
	// atomic ins.
	assign atomic = ins[0];

endmodule