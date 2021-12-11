/*
 * Module name: mmu
 * Engineer: Jianping Shen
 * Description: Memory management unit.  
 * Dependency:i_cache.sv, d_cache.sv
 * Status: Developing
**/
module mmu
(
	input                   clk             ,
	input                   rst_n           ,

    // MMU interface
    input           [31:0]  i_addr          ,
    input                   i_rd            ,
    input           [2:0]   i_trd           ,
    output  logic   [31:0]  i_rd_data       ,
    output  logic           i_miss          ,
    output  logic           i_segfault      ,
    input           [31:0]  d_addr          ,
    input           [31:0]  d_wr_data       ,
    input                   d_rd            ,
    input                   d_wr            ,
    input           [2:0]   d_trd           ,
    output  logic   [31:0]  d_rd_data       ,
    output  logic           d_miss          ,
    output  logic           d_segfault      ,

    // CSR interface
    input           [7:0]   child_0         ,
    input           [7:0]   child_1         ,
    input           [7:0]   child_2         ,
    input           [7:0]   child_3         ,
    input           [7:0]   child_4         ,
    input           [7:0]   child_5         ,
    input           [7:0]   child_6         ,
    input           [7:0]   child_7         ,
    input                   alu_exp         ,
    input           [2:0]   alu_trd         ,
    input                   inv_op          ,
    input           [2:0]   inv_op_trd      ,
    input           [2:0]   insfetch_trd    ,
    input                   breakpoint      ,
    input           [2:0]   bp_trd          ,
    input           [7:0]   valid_trd       ,
    input           [7:0]   run_trd         ,
    input                   running         ,
    input                   trd_of          ,
    input                   trd_full

	input                   host_init       ,
	input                   host_rd_ready   ,
	input                   host_wr_ready   ,


	input           [31:0]  common_data_bus_read_in, 
	output  logic   [31:0]  common_data_bus_write_out, 

	input           [511:0] host_data_bus_read_in,
	output  logic   [511:0] host_data_bus_write_out,

    output  logic   [63:0]  cpu_addr        ,
	output  logic           host_re         ,
	output  logic           host_we         ,
	output  logic           host_rgo        ,
	output  logic           host_wgo
);

    logic [31:0] i_addr, d_addr, i_miss_addr, d_miss_addr;
    logic i_rd_req, d_rd_req;
    logic [511:0] host_rd_data;
    logic [31:0] host_rd_addr;


    assign host_rd_data = host_data_bus_read_in;

    logic [15:0] cycle_count;
    logic counting;
    logic not_miss, just_rd;
    logic finish;
    assign not_miss = just_rd & !i_miss;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            just_rd <= 0;
            cycle_count <= 0;
            counting <= 0;
            finish <= 0;
        end
        else if(!counting & not_miss) begin
            counting <= 1;
        end
        else if(running & counting) begin
            cycle_count <= cycle_count + 1;
        end
        else if(!runing & counting) begin
            finish <= 1;
        end
    end

    typedef enum logic[1:0]
	{
		STARTUP,
		READY,
		IREAD,
        DREAD
	} sm_state;
    sm_state state, nxt_state;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) state <= STARTUP;
        else state <= nxt_state;
    end

    always_comb begin
        nxt_state = state;
		host_re = 1'b0;
		host_we = 1'b0;
		host_rgo = 1'b0;
		host_wgo = 1'b0;
        cpu_addr = 64'b0;
        case(state)
            STARTUP: begin
                if(host_init) nxt_state = READY;
            end
            READY: begin
                if(i_rd_req) begin
                    nxt_state = IREAD;
                end
                else if(d_rd_req) begin
                    nxt_state = DREAD;
                end
            end
            IREAD: begin
                cpu_addr = {30'b0, i_miss_addr, 2'b00};
                
            end
    end

    i_cache I_CACHE
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),
        .i_addr             (i_addr         ),
        .i_rd               (i_rd           ),
        .i_miss             (i_miss         ),
        .i_rd_data          (i_rd_data      ),
        .i_segfault         (i_segfault     ),
        .host_rd_ready      (host_rd_ready  ),
        .host_rd_data       (host_rd_data   ),
        .host_rd_addr       (host_rd_addr   ),
        .i_miss_addr        (i_miss_addr    ),
        .i_rd_req           (i_rd_req       )
    );

    d_cache D_CACHE
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),
        .d_addr             (d_addr         ),
        .d_rd               (d_rd           ),
        .d_wr               (d_wr           ),
        .d_wr_data          (d_wr_data      ),
        .d_miss             (d_miss         ),
        .d_rd_data          (d_rd_data      ),
        .d_segfault         (d_segfault     ),
        .host_rd_ready      (host_rd_ready  ),
        .host_rd_data       (host_rd_data   ),
        .host_rd_addr       (host_rd_addr   ),
        .d_miss_addr        (d_miss_addr    ),
        .d_rd_req           (d_rd_req       )
    );


endmodule