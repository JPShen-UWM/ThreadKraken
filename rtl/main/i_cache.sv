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
    input  logic [31:0] wr_ins[0:15],      // 32-bit cache line to read from memory
    input  logic        wr_en,
    input  logic        rd_en,

    output logic [31:0] ins,
    output logic        i_miss,
    output logic        vld,
    output logic [8:0]  index
);
    logic [32:0]        mem[0:511];        // {valid,ins[31:0]}
    logic [32:0]        line;
    logic               seg_f_en;
    
    // cache is large enough for everything in memory so only index bits
    assign index = cur_pc[8:0];

    // cache write
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            for(int i = 0; i < 512; i = i + 1)
                mem[i] <= 33'h0;
        end
        else if(wr_en) begin
            for(int i = 0; i < 16; i = i + 1)
                mem[index+i] <= {1'b1,wr_ins[i]};
        end
    
    // return line of data
    assign line = mem[index];
    assign vld = line[32];
    assign ins = line[31:0];

endmodule