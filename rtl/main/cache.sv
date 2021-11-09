/*
 * Module name: cache.v
 * Engineer: Tommy Yee
 * Description: 2-way set associative cache with write-through. LRU replacement policy.
 *              block size: 32 byte
 *              address size: 20 bit (0x00000000 to 0x0001FFFF)
 *              cache data size: 256 kilobytes
 * Dependency:
 * Status: developing
 */

// [-- tag: 3 bits --] [---------- index: 12 bits ----------] [---- offset: 5 bits ----]
module cache(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [19:0] addr_in,
    input  logic [2:0]  tag_in,
    input  logic [31:0] wr_data, // 32-bit cache line to write
    input  logic        wr_en,
    input  logic        rd_en,

    output logic [31:0] rd_data,
    output logic [2:0]  tag_out,
    output logic        miss,
    output logic [2:0]  tag_out
);

 endmodule