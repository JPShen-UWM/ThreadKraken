/*
 * Module name: no_miss_mem
 * Engineer: Jianping Shen
 * Description: Mimic memory with no cache miss
 * Dependency:
 * Status: Developing
**/
`include "../main/header.svh"
module no_miss_mem #( parameter test_path = "../../sw/test_cases/add1.o" )
(
    input                   clk         ,
    input                   rst_n       ,
    
    // MMU interface
    input           [31:0]  i_addr      ,
    input                   i_rd        ,
    input           [2:0]   i_trd       ,
    output  logic   [31:0]  i_rd_data   ,
    output  logic           i_miss      ,
    output  logic           i_segfault  ,
    input           [31:0]  d_addr      ,
    input           [31:0]  d_wr_data   ,
    input                   d_rd        ,
    input                   d_wr        ,
    input           [2:0]   d_trd       ,
    output  logic   [31:0]  d_rd_data   ,
    output  logic           d_miss      ,
    output  logic           d_segfault  ,

    // CSR interface
    input           [7:0]   child_0     ,
    input           [7:0]   child_1     ,
    input           [7:0]   child_2     ,
    input           [7:0]   child_3     ,
    input           [7:0]   child_4     ,
    input           [7:0]   child_5     ,
    input           [7:0]   child_6     ,
    input           [7:0]   child_7     ,
    input                   alu_exp     ,
    input           [2:0]   alu_trd     ,
    input                   inv_op      ,
    input           [2:0]   inv_op_trd  ,
    input           [2:0]   insfetch_trd,
    input                   breakpoint  ,
    input           [2:0]   bp_trd      ,
    input           [7:0]   valid_trd   ,
    input           [7:0]   run_trd     ,
    input                   running     ,
    input                   trd_of      ,
    input                   trd_full    
);

    logic [31:0] mem[4095:0];
    logic loaded;
    logic [11:0] i_phy_addr;
    logic [11:0] d_phy_addr;

    assign i_phy_addr = i_addr[11:0];
    assign d_phy_addr = d_addr[11:0];
    

    initial begin
        loaded = 0;
        for (int i = 0; i< 4096; i=i+1) begin
            mem[i] = 0;
        end
    end

    logic [31:0] d_rd_sel;
    logic d_seg_sel;
    always_comb begin
        d_rd_sel = 0;
        d_seg_sel = 0;
        if(|d_addr[31:16] & (d_rd | d_wr)) begin
            case(d_trd)
                0: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'hE| d_phy_addr[11:8] == 4'hF) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                1: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'hD) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                2: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'hC) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                3: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'hB) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                4: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'hA) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                5: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'h9) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                6: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'h8) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
                7: begin
                    if(d_phy_addr[11:8] <=5 | d_phy_addr[11:8] == 4'h7) begin
                        d_rd_sel = mem[d_phy_addr];
                    end
                    else d_seg_sel = 1;
                end
            endcase
        end
    end


    always @(posedge clk) begin
        if(!rst_n) begin
            i_rd_data   <= 0;
            i_miss      <= 0;
            i_segfault  <= 0;
            d_rd_data   <= 0;
            d_miss      <= 0;
            d_segfault  <= 0;
            if(!loaded) begin
                $readmemh(test_path, mem, 12'h100);
                loaded = 1;
                $display("Loaded memory. Load: %s", test_path);
            end
        end
        else begin
            if(i_rd) i_rd_data <= mem[i_phy_addr];
            else i_rd_data <= 0;
            if(d_rd) begin 
                d_rd_data <= mem[d_phy_addr];
                d_segfault <= d_seg_sel;
            end
            else if(d_wr) begin
                if(d_seg_sel) d_segfault <= d_seg_sel;
                else begin
                    $display("Mem write. Thread: %d, addr: %h, data: %h", d_trd, d_addr, d_wr_data);
                    mem[d_phy_addr] <= d_wr_data;
                end
                d_rd_data <= 0;
            end
        end
    end
endmodule