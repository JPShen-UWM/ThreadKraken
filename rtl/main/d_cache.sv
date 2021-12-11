/*
 * Module name: d-cache
 * Engineer: Jianping Shen
 * Description: Data cache. 14 kb size. Handler address from 0x0001_0200 to 0x00010FFF
 * Dependency:
 * Status: Developing
**/
module d_cache(
    input                   clk             ,
    input                   rst_n           ,

    input           [31:0]  d_addr          ,
    input                   d_rd            ,
    input                   d_wr            ,
    input           [31:0]  d_wr_data       ,
    output  logic           d_miss          ,
    output  logic   [31:0]  d_rd_data       ,
    output  logic           d_segfault      ,

    input                   host_rd_ready   ,
    input           [512:0] host_rd_data    ,
    input           [31:0]  host_rd_addr    ,
    output  logic   [31:0]  d_miss_addr     ,
    output  logic           d_rd_req
);

    logic [31:0] mem [4095:0];
    logic [255:0] valid;
    logic [11:0] d_phy_addr, host_phy_addr;
    logic host_rd_valid;
    logic segfault;

    assign d_phy_addr = d_addr[11:0];
    assign host_phy_addr = host_rd_addr[11:0];

    always_comb begin
        segfault = 0;
        host_rd_valid = 0;
        if(d_rd | d_wr) begin
            if(d_addr[31:12] != 20'h00010 | d_addr[11:9] == 0) segfault = 1;
        end
        if(host_rd_ready) begin
            if(host_rd_addr[31:12] == 20'h00010 & host_rd_addr[11:9] != 0) host_rd_valid = 1;
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
                else if(!valid[d_phy_addr[11:4]]) d_miss <= 1;
                else d_rd_data <= mem[d_phy_addr];
            end
            else if(d_wr) begin
                d_rd_data <= 0;
                if(segfault) d_segfault <= 1;
                else if(!valid[d_phy_addr[11:4]]) d_miss <= 1;
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
            valid <= 0;
        end
        else if(d_wr) begin
                if(!valid[d_phy_addr[11:4]]) mem[d_phy_addr] <= d_wr_data;
            end
        else if(host_rd_valid) begin
            valid[host_phy_addr[11:4]] <= 1;
            mem[host_phy_addr + 0 ] <= host_rd_data[ 31:  0];
            mem[host_phy_addr + 1 ] <= host_rd_data[ 63: 32];
            mem[host_phy_addr + 2 ] <= host_rd_data[ 95: 64];
            mem[host_phy_addr + 3 ] <= host_rd_data[127: 96];
            mem[host_phy_addr + 4 ] <= host_rd_data[159:128];
            mem[host_phy_addr + 5 ] <= host_rd_data[191:160];
            mem[host_phy_addr + 6 ] <= host_rd_data[223:192];
            mem[host_phy_addr + 7 ] <= host_rd_data[255:224];
            mem[host_phy_addr + 8 ] <= host_rd_data[287:256];
            mem[host_phy_addr + 9 ] <= host_rd_data[319:288];
            mem[host_phy_addr + 10] <= host_rd_data[351:320];
            mem[host_phy_addr + 11] <= host_rd_data[383:352];
            mem[host_phy_addr + 12] <= host_rd_data[415:384];
            mem[host_phy_addr + 13] <= host_rd_data[447:416];
            mem[host_phy_addr + 14] <= host_rd_data[479:448];
            mem[host_phy_addr + 15] <= host_rd_data[511:480];
        end
    end

    logic [31:0] last_addr;
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            last_addr <= 0;
        end
        else if(d_rd | d_wr) last_addr <= d_addr;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            d_miss_addr <= 0;
            d_rd_req <= 0;
        end
        else if(d_miss & !d_rd_req) begin
            d_rd_req <= 1;
            d_miss_addr <= last_addr;
        end
        else if(host_rd_valid) begin
            d_rd_req <= 0;
            d_miss_addr <= 0;
        end
    end
endmodule