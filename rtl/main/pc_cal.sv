/*
 * Module name: pc_cal
 * Engineer: Jianping Shen
 * Description: Calculate jump pc in branching or jump
 * Dependency:
 * Status: developing
**/
`include "header.svh"
module pc_cal(
    input           [31:0]  cur_pc  ,
    input           [11:0]  imm     ,
    input           [31:0]  data_a  ,
    input           [3:0]   jmp_con ,
    input                   eq      ,
    input                   lt      ,
    
    output  logic   [31:0]  jmp_pc  ,
    output  logic           jmp_en
);

    // jmp_con: jmp condition
    // 0001: equal
    // 0010: little
    // 0100: not equal
    // 0111: reference unconditional jump
    // 1111: non-reference unconditional jump

    logic [31:0] imm_ext;
    assign imm_ext = {{20{imm[11]}}, imm};

    always_comb begin
        jmp_pc = HANDLER;
        jmp_en = 0;

        case(jmp_con)
            4'b0001: begin
                if(eq) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0010: begin
                if(lt) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0100: begin
                if(!eq) begin
                    jmp_pc = cur_pc + 1 + imm_ext;
                    jmp_en = 1;
                end
            end
            4'b0111: begin
                jmp_pc = data_a + imm_ext;
                jmp_en = 1;
            end
            4'b1111: begin
                jmp_pc = cur_pc + 1 + imm_ext;
                jmp_en = 1;
            end
        endcase
    end

endmodule