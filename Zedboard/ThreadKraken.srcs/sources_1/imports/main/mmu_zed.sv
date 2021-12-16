/*
 * Module name: mmu_zed
 * Engineer: Jianping Shen
 * Description: Memory management unit for zedboard
 * Dependency:
 * Status: Done
 */
module mmu_zed
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
    input                   trd_full        ,

    // Host interface
    input           [31:0]  rd_data_0       ,
    input           [31:0]  rd_data_1       ,
    input           [31:0]  rd_data_2       ,
    input           [31:0]  rd_data_3       ,
    input           [31:0]  rd_data_4       ,
    input           [31:0]  rd_data_5       ,
    input           [31:0]  rd_data_6       ,
    input           [31:0]  rd_data_7       ,
    output  logic   [31:0]  host_rd_addr    ,
    input           [1:0]   host_sig        ,
    output  logic   [31:0]  uart_0          ,
    output  logic   [31:0]  uart_1          ,
    output  logic   [31:0]  uart_2          ,
    output  logic   [31:0]  uart_3          ,
    output  logic   [31:0]  cycle_count     ,
    output  logic           finish
);

    logic [31:0] i_miss_addr;
    logic i_rd_req;

    logic counting;
    logic not_miss, just_rd;
    logic req_get, data_valid;
    logic host_rd_valid;
    logic done;

    assign not_miss = just_rd & !i_miss;
    assign req_get = host_sig[0];
    assign data_valid = host_sig[1];
    assign finish = done|i_segfault|trd_of|inv_op;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cycle_count <= 0;
            counting <= 0;
            done <= 0;
        end
        else if(!counting & not_miss) begin
            counting <= 1;
        end
        else if(running & counting) begin
            cycle_count <= cycle_count + 1;
        end
        else if(!running & counting) begin
            done <= 1;
            counting <= 0;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) just_rd <= 0;
        else just_rd <= i_rd;
    end

    typedef enum logic[1:0]
	{
		IDLE,
		READ,
		WAIT,
        DONE
	} state_t;
    state_t state, nxt_state;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) state <= IDLE;
        else state <= nxt_state;
    end

    always_comb begin
        nxt_state = state;
        host_rd_addr = 0;
        host_rd_valid = 0;
        case(state)
            IDLE: begin
                if(i_rd_req) nxt_state = READ;
            end
            READ: begin
                host_rd_addr = i_miss_addr;
                if(req_get) nxt_state = WAIT;
            end
            WAIT: begin
                if(data_valid) nxt_state = DONE;
            end
            DONE: begin
                host_rd_valid = 1;
                nxt_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            uart_0 <= 0;
            uart_1 <= 0;
            uart_2 <= 0;
            uart_3 <= 0;
        end
        else if(d_addr == 0 & d_wr) uart_0 <= d_wr_data;
        else if(d_addr == 1 & d_wr) uart_1 <= d_wr_data;
        else if(d_addr == 2 & d_wr) uart_2 <= d_wr_data;
        else if(d_addr == 3 & d_wr) uart_3 <= d_wr_data;
    end

    i_cache_zed I_CACHE
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),
        .i_addr             (i_addr         ),
        .i_rd               (i_rd           ),
        .i_miss             (i_miss         ),
        .i_rd_data          (i_rd_data      ),
        .i_segfault         (i_segfault     ),
        .host_rd_valid      (host_rd_valid  ) ,
        .rd_data_0          (rd_data_0      ) ,
        .rd_data_1          (rd_data_1      ) ,
        .rd_data_2          (rd_data_2      ) ,
        .rd_data_3          (rd_data_3      ) ,
        .rd_data_4          (rd_data_4      ) ,
        .rd_data_5          (rd_data_5      ) ,
        .rd_data_6          (rd_data_6      ) ,
        .rd_data_7          (rd_data_7      ) ,
        .host_rd_addr       (i_miss_addr    ) ,
        .i_miss_addr        (i_miss_addr    ) ,
        .i_rd_req           (i_rd_req       )
    );

    d_cache_zed D_CACHE
    (
        .clk                (clk            ),
        .rst_n              (rst_n          ),
        .d_addr             (d_addr         ),
        .d_rd               (d_rd           ),
        .d_wr               (d_wr           ),
        .d_wr_data          (d_wr_data      ),
        .d_miss             (d_miss         ),
        .d_rd_data          (d_rd_data      ),
        .d_segfault         (d_segfault     )
    );

endmodule