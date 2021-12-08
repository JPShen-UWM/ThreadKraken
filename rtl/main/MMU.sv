module MMU(
    output  logic   [1:0] opcode
);

/*    // MMU interface
    output  logic   [31:0]  i_addr      ,
    output  logic           i_rd        ,
    output  logic   [2:0]   i_trd       ,
    input           [31:0]  i_rd_data   ,
    input                   i_miss      ,
    input                   i_segfault  ,
    output  logic   [31:0]  d_addr      ,
    output  logic   [31:0]  d_wr_data   ,
    output  logic           d_rd        ,
    output  logic           d_wr        ,
    output  logic   [2:0]   d_trd       ,
    input           [31:0]  d_rd_data   ,
    input                   d_miss      ,
    input                   d_segfault  ,
*/
    cache_ctrl iCC();
    memory_map iMAP();
    	
/*         IDLE = 2'b00,
		READ = 2'b01,
		WRITE = 2'b11  */


endmodule