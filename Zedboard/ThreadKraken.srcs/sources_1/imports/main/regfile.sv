/*
 * Module name: regfile
 * Engineer: Jianping Shen
 * Description: Register file for each thread
 * Dependency:
 * Status: developing
**/
//`include "header.svh"

module regfile #( parameter TRD_ID = 0 )
(
    input                   clk         ,
    input                   rst_n       ,

    input           [4:0]   reg_rd_a    ,
    input           [4:0]   reg_rd_b    ,
    input           [4:0]   reg_wr      ,
    input                   wr_en       ,
    input           [2:0]   wr_trd      ,
    input           [31:0]  wr_data     ,
    input                   init        ,
    input           [2:0]   new_trd     ,
    input           [31:0]  init_data   ,

    output  logic   [31:0]  data_a      ,
    output  logic   [31:0]  data_b
);
    logic [31:0] data [31:0];
// Operation code
parameter CAL       =   4'b1111;
parameter CALI      =   4'b1110;
parameter SHIFT     =   4'b1100;
parameter LOADI     =   4'b1001;
parameter MEMOP     =   4'b1000;
parameter BRANCH    =   4'b1010;
parameter EXC       =   4'b0000;
parameter MULTI     =   4'b0110;

// Function code
parameter ADD       =   3'b110;
parameter NOT       =   3'b000;
parameter AND       =   3'b111;
parameter OR        =   3'b101;
parameter XOR       =   3'b011;
parameter SHLT      =   3'b001;
parameter SHRT      =   3'b010;
parameter SHAR      =   3'b100;
parameter LBI       =   3'b001;
parameter SLB       =   3'b010;

// PC Address
parameter START_PC  =   32'h0001_0100;
parameter HANDLER   =   32'h0001_0000;

// Init and end stack for each thread
parameter TRD0_INIT_ESP = 32'h0001_0FFF;
parameter TRD1_INIT_ESP = 32'h0001_0DFF;
parameter TRD2_INIT_ESP = 32'h0001_0CFF;
parameter TRD3_INIT_ESP = 32'h0001_0BFF;
parameter TRD4_INIT_ESP = 32'h0001_0AFF;
parameter TRD5_INIT_ESP = 32'h0001_09FF;
parameter TRD6_INIT_ESP = 32'h0001_08FF;
parameter TRD7_INIT_ESP = 32'h0001_07FF;

parameter TRD0_END_ESP = 32'h0001_0E00;
parameter TRD1_END_ESP = 32'h0001_0D00;
parameter TRD2_END_ESP = 32'h0001_0C00;
parameter TRD3_END_ESP = 32'h0001_0B00;
parameter TRD4_END_ESP = 32'h0001_0A00;
parameter TRD5_END_ESP = 32'h0001_0900;
parameter TRD6_END_ESP = 32'h0001_0800;
parameter TRD7_END_ESP = 32'h0001_0700;

    // Data write
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data[0] <= 32'h000;
            data[1] <= TRD_ID;
            case(TRD_ID)
                0: data[2] <= TRD0_INIT_ESP;
                1: data[2] <= TRD1_INIT_ESP;
                2: data[2] <= TRD2_INIT_ESP;
                3: data[2] <= TRD3_INIT_ESP;
                4: data[2] <= TRD4_INIT_ESP;
                5: data[2] <= TRD5_INIT_ESP;
                6: data[2] <= TRD6_INIT_ESP;
                7: data[2] <= TRD7_INIT_ESP;
            endcase
            case(TRD_ID)
                0: data[3] <= TRD0_INIT_ESP;
                1: data[3] <= TRD1_INIT_ESP;
                2: data[3] <= TRD2_INIT_ESP;
                3: data[3] <= TRD3_INIT_ESP;
                4: data[3] <= TRD4_INIT_ESP;
                5: data[3] <= TRD5_INIT_ESP;
                6: data[3] <= TRD6_INIT_ESP;
                7: data[3] <= TRD7_INIT_ESP;
            endcase
            for(int i = 4; i<32; i++) begin
                data[i] <= 32'b0;
            end
        end
        else if(init & new_trd == TRD_ID) begin
            data[0] <= 32'h000;
            data[1] <= TRD_ID;
            case(TRD_ID)
                0: data[2] <= TRD0_INIT_ESP;
                1: data[2] <= TRD1_INIT_ESP;
                2: data[2] <= TRD2_INIT_ESP;
                3: data[2] <= TRD3_INIT_ESP;
                4: data[2] <= TRD4_INIT_ESP;
                5: data[2] <= TRD5_INIT_ESP;
                6: data[2] <= TRD6_INIT_ESP;
                7: data[2] <= TRD7_INIT_ESP;
            endcase
            case(TRD_ID)
                0: data[3] <= TRD0_INIT_ESP;
                1: data[3] <= TRD1_INIT_ESP;
                2: data[3] <= TRD2_INIT_ESP;
                3: data[3] <= TRD3_INIT_ESP;
                4: data[3] <= TRD4_INIT_ESP;
                5: data[3] <= TRD5_INIT_ESP;
                6: data[3] <= TRD6_INIT_ESP;
                7: data[3] <= TRD7_INIT_ESP;
            endcase
            data[4] <= init_data;
            for(int i = 5; i<32; i++) begin
                data[i] <= 0;
            end
        end
        else if(wr_en & wr_trd == TRD_ID) begin
            if(reg_wr > 1) data[reg_wr] <= wr_data;
        end
    end

    // Read register
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            data_a <= 32'h0;
            data_b <= 32'h0;
        end
        else begin
            if(wr_en & wr_trd == TRD_ID & reg_wr == reg_rd_a) data_a <= wr_data;
            else data_a <= data[reg_rd_a];

            if(wr_en & wr_trd == TRD_ID & reg_wr == reg_rd_b) data_b <= wr_data;
            else data_b <= data[reg_rd_b];
        end
    end
endmodule