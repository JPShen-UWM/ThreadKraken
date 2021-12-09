/*
 * Module name: MMU
 * Engineer: Tommy Yee
 * Description: memory management unit. Handles: virtual address translation, cache hierarchy to 
 *              host memory interface
 * Dependency: cache_ctrl, ram
 * Status: developing
 */
module MMU(
    input                   clk         ,
    input                   rst_n       ,
    
    // core interface
    input   logic   [31:0]  i_addr      ,
    input   logic           i_rd        ,       // read request from core
    input   logic   [2:0]   i_trd       ,
    output          [31:0]  i_rd_data   ,
    output                  i_miss      ,
    output  logic           i_segfault  ,
    input   logic   [31:0]  d_addr      ,
    input   logic   [31:0]  d_wr_data   ,
    input   logic           d_rd        ,
    input   logic           d_wr        ,
    input   logic   [2:0]   d_trd       ,
    output          [31:0]  d_rd_data   ,
    output                  d_miss      ,
    output  logic           d_segfault  ,

    // memory controller interface
    input   logic           tx_done     ,       // host done with read/write
    input   logic           ready       ,       // host ready for read/write
    output  logic   [1:0]   mem_op      ,       // rd/wr op to mem_ctrl

);
    /////////////////////////////////////// internal signals ///////////////////////////////////////
    logic [7:0] csr_d_segfault, csr_i_segfault;

    UART iTCV(
        .clk(clk),
        .rst_n(rst_n),

    );
    cache_ctrl iCC();
    	
/*         IDLE = 2'b00,
		READ = 2'b01,
		WRITE = 2'b11  */

    // check read/write in accessible memory range
    always_comb begin
        i_segfault = 0;
        d_segfault = 0;

        case(i_addr) inside
            [32'h00010000:32'h000101FF]: begin
                if(i_rd)
                    i_segfault = 0;
            end
            default: begin
                if(i_rd)
                    i_segfault = 1;
            end
        endcase

        case(d_addr) inside
            [32'h00010200:32'h000102FF]: begin
                if(d_rd|d_wr)
                    d_segfault = 0;
            end
            default: begin
                if(d_rd|d_wr)
                    d_segfault = 1;
            end
        endcase
    end

    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            
        end

    // TODO: CSR interface
endmodule