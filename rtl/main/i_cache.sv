/*
 * Module name: i-cache
 * Engineer: Jianping Shen
 * Description: Instruction cache. 2 kb size. Handler address from 0x0001_0000 to 0x000101FF
 * Dependency:
 * Status: Developing
**/
module i_cache(
    input                   clk             ,
    input                   rst_n           ,

    input           [31:0]  i_addr          ,
    input                   i_rd            ,
    output  logic           i_miss          ,
    output  logic   [31:0]  i_rd_data       ,
    output  logic           i_segfault      ,

    input                   host_rd_ready   ,
    input           [512:0] host_rd_data    ,
    input           [31:0]  host_rd_addr    ,
    output  logic   [31:0]  i_miss_addr     ,
    output  logic           i_rd_req
);

    logic [31:0] mem [511:0];
    logic [31:0] valid;
    logic [8:0] i_phy_addr, host_phy_addr;
    logic segfault;
    logic host_rd_valid;

    assign i_phy_addr = i_addr[8:0];
    assign host_phy_addr = host_rd_addr[8:0];

    always_comb begin
        segfault = 0;
        host_rd_valid = 0;
        if(i_rd) begin
            if(i_addr[31:12] != 20'h00010 | i_addr[11:9] != 0) segfault = 1;
        end
        if(host_rd_ready) begin
            if(host_rd_addr[31:12] == 20'h00010 & host_rd_addr[11:9] == 0) host_rd_valid = 1;
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
                else if(!valid[i_phy_addr[8:4]]) i_miss <= 1;
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
            valid[host_phy_addr[8:4]] <= 1;
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
        else if(i_rd) last_addr <= i_addr;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            i_miss_addr <= 0;
            i_rd_req <= 0;
        end
        else if(i_miss & !i_rd_req) begin
            i_rd_req <= 1;
            i_miss_addr <= last_addr;
        end
        else if(host_rd_valid) begin
            i_rd_req <= 0;
            i_miss_addr <= 0;
        end
    end
endmodule