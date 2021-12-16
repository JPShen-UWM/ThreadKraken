/*
 * Module name: tk_top_zed
 * Engineer: Jianping Shen
 * Description: Icache for zedboard
 * Dependency:
 * Status: Done
 */

module i_cache_zed(
    input                   clk             ,
    input                   rst_n           ,

    input           [31:0]  i_addr          ,
    input                   i_rd            ,
    output  logic           i_miss          ,
    output  logic   [31:0]  i_rd_data       ,
    output  logic           i_segfault      ,

    input                   host_rd_valid   ,
    input           [31:0]  rd_data_0       ,
    input           [31:0]  rd_data_1       ,
    input           [31:0]  rd_data_2       ,
    input           [31:0]  rd_data_3       ,
    input           [31:0]  rd_data_4       ,
    input           [31:0]  rd_data_5       ,
    input           [31:0]  rd_data_6       ,
    input           [31:0]  rd_data_7       ,
    input           [31:0]  host_rd_addr    ,
    output  logic   [31:0]  i_miss_addr     ,
    output  logic           i_rd_req
);

    logic [31:0] mem [511:0];
    logic [63:0] valid;
    logic [8:0] i_phy_addr, host_phy_addr;
    logic segfault;

    assign i_phy_addr = i_addr[8:0];
    assign host_phy_addr = host_rd_addr[8:0];

    always_comb begin
        segfault = 0;
        if(i_rd) begin
            if(i_addr[31:12] != 20'h00010 | i_addr[11:9] != 0) segfault = 1;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            i_segfault <= 0;
            i_miss <= 0;
            i_rd_data <= 0;
        end
        else begin
            if(i_rd) begin
                if(segfault) i_segfault <= 1;
                else if(!valid[i_phy_addr[8:3]]) i_miss <= 1;
                else i_rd_data <= mem[i_phy_addr];
            end
            else begin
                i_segfault <= 0;
                i_miss <= 0;
                i_rd_data <= 0;
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            valid <= 0;
        end
        else if(host_rd_valid) begin
            valid[host_phy_addr[8:3]] <= 1;
            mem[host_phy_addr + 0 ] <= rd_data_0;
            mem[host_phy_addr + 1 ] <= rd_data_1;
            mem[host_phy_addr + 2 ] <= rd_data_2;
            mem[host_phy_addr + 3 ] <= rd_data_3;
            mem[host_phy_addr + 4 ] <= rd_data_4;
            mem[host_phy_addr + 5 ] <= rd_data_5;
            mem[host_phy_addr + 6 ] <= rd_data_6;
            mem[host_phy_addr + 7 ] <= rd_data_7;
        end
    end

    logic [31:0] last_addr;
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            last_addr <= 0;
        end
        else if(i_rd) last_addr <= i_addr;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            i_miss_addr <= 0;
            i_rd_req <= 0;
        end
        else if(i_miss & !i_rd_req) begin
            i_rd_req <= 1;
            i_miss_addr <= {last_addr[31:3], 3'b0};
        end
        else if(host_rd_valid) begin
            i_rd_req <= 0;
            i_miss_addr <= 0;
        end
    end
endmodule