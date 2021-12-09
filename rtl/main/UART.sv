/*
 * Module name: UART
 * Engineer: Tommy Yee
 * Description: "UART" (actually just mmio, but interfaces with core/host like a UART)
 *              addr: function
 *              0x00: rd data
 *              0x01: rd valid (clear when data taken by core)
 *              0x02: wr data
 *              0x03: wr to host (clear when host is done with write)
 * Dependency: MMU
 * Status: developing
 */
module UART(
    input                   clk         ,
    input                   rst_n       ,

    input   logic           tx_done     ,       // host done with read/write
    input   logic           ready       ,       // host ready for read/write

    input   logic           clr_rd_rdy  ,       // clear 0x01 upon reading data
    input   logic           clr_wr_rdy  ,       // clear 0x03 upon successful write

    input   logic   [31:0]  rd_data     ,
    input   logic   [31:0]  host_to_common_rd_data     ,
    output  logic   [31:0]  common_to_host_wr_data     ,

    output  logic   [1:0]   mem_op
);
    /////////////////////////////////////// internal signals ///////////////////////////////////////
    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam WRITE = 2'b11;

    logic [31:0] uart_mem[0:3];

    ////////////////////////////////////////// sm signals //////////////////////////////////////////
    typedef enum logic [1:0] { WAIT_RDY, RDY, TX } state_t;
    state_t state, nxt_state;

    /////////////////////////////////////////// datapath ///////////////////////////////////////////
    // the "UART"
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n) begin
            for(int i=0; i<4; i=i+1)
                uart_mem[i] <= '0;
        end
        else if(clr_rd_rdy) begin
            uart_mem[1] <= '0;
        end
        else if(clr_wr_rdy) begin
            uart_mem[3] <= '0;
        end
        else begin
            uart_mem[0] <= host_to_common_rd_data;
            uart_mem[2] <= common_to_host_wr_data;
        end


    // state register
    always_ff @(posedge clk, negedge rst_n)
        if(!rst_n)
            state <= WAIT_RDY;
        else
            state <= nxt_state;
    
    // state transition and output logic
    always_comb begin
        nxt_state = state;
        mem_op = IDLE;

        case(state)
            // WAIT_RDY
            default: begin 
                if(ready)
                    nxt_state = RDY;
            end

            RDY: begin
                if(uart_mem[1] || uart_mem[4])
                    nxt_state = TX;
            end
            
            TX: begin
                if(uart_mem[1]) begin
                    
                end
                else if(uart_mem[3]) begin
                
                end
            end

        endcase

    end

endmodule