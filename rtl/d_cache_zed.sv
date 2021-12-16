/*
 * Module name: tk_top_zed
 * Engineer: Jianping Shen
 * Description: D-cache for zedboard
 * Dependency:
 * Status: Done
 */
module d_cache_zed(
    input                   clk             ,
    input                   rst_n           ,

    input           [31:0]  d_addr          ,
    input                   d_rd            ,
    input                   d_wr            ,
    input           [31:0]  d_wr_data       ,
    output  logic           d_miss          ,
    output  logic   [31:0]  d_rd_data       ,
    output  logic           d_segfault      
);

    logic [31:0] mem [511:0];
    logic [8:0] d_phy_addr;
    logic segfault;

    assign d_phy_addr = d_addr[8:0];

    always_comb begin
        segfault = 0;
        if(d_rd | d_wr) begin
            if(d_addr[31:12] != 20'h00010 | d_addr[11:9] == 0) segfault = 1;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            d_segfault <= 0;
            d_miss <= 0;
            d_rd_data <= 0;
        end
        else begin
            if(d_rd) begin
                if(segfault) d_segfault <= 1;
                else d_rd_data <= mem[d_phy_addr];
            end
            else if(d_wr) begin
                d_rd_data <= 0;
                if(segfault) d_segfault <= 1;
            end
            else begin
                d_segfault <= 0;
                d_miss <= 0;
                d_rd_data <= 0;
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            for(int i = 0; i<512;i++) begin
                mem[i] = 0;
            end
        end
        else if(d_wr & |d_addr[31:2]) begin
            mem[d_phy_addr] <= d_wr_data;
        end
    end
endmodule