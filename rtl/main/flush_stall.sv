/*
 * Module name: flush_stall
 * Engineer: Jianping Shen
 * Description: Flush stall controller
 * Dependency:
 * Status: Done
**/

module flush_stall(
    input                   jmp,
    input                   kill,
    input                   sleep,
    input                   stall_req,
    input           [2:0]   trd_if,
    input           [2:0]   trd_dec,
    input           [2:0]   trd_exe,
    input           [2:0]   trd_mem,
    input           [2:0]   trd_wb,
    input                   d_miss,
    output  logic           flushEX,
    output  logic           flushID,
    output  logic           flushMEM,
    output  logic           flushIF,
    output  logic           flushWB,
    output  logic           stall
);

    always_comb begin
        flushEX = 0;
        flushMEM = 0;
        flushIF = 0;
        flushID = 0;
        stall = 0;
        flushWB = 0;
        if(kill | sleep | d_miss) begin
            if(trd_if == trd_wb) flushIF = 1;
            if(trd_dec == trd_wb) flushID = 1;
            if(trd_exe == trd_wb) flushEX = 1;
            if(trd_mem == trd_wb) flushMEM = 1;
            flushWB = 1;           
        end
        else if(jmp) begin
            if(trd_if == trd_exe) flushIF = 1;
            if(trd_dec == trd_exe) flushID = 1;
        end
        else if(stall_req) stall = 1;
    end

endmodule