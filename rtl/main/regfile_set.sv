/*
 * Module name: regfile_set
 * Engineer: Jianping Shen
 * Description: Register file set contain regfile for each thread
 * Dependency: regfile
 * Status: developing
**/

module regfile_set
(
    input                   clk         ,
    input                   rst_n       ,

    input           [2:0]   trd_dec     ,
    input           [4:0]   reg_rd_a    ,
    input           [4:0]   reg_rd_b    ,
    input           [2:0]   wr_trd      ,
    input           [4:0]   reg_wr      ,
    input                   wr_en       ,
    input           [31:0]  wr_data     ,
    input           [2:0]   new_trd_wb  ,
    input                   init_wb     ,
    input           [31:0]  init_data_wb,
    
    output          [31:0]  rd_data_a   ,
    output          [31:0]  rd_data_b    
);

    logic [31:0] reg_a_out [7:0];
    logic [31:0] reg_b_out [7:0];

    logic init_reg_exe;
    logic [2:0] init_trd_exe;
    logic final_data;

    assign rd_data_a = reg_a_out[trd_dec];
    assign rd_data_b = reg_b_out[trd_dec];

    logic init_0;
    assign init_0 = 0;


    regfile #(0)
    REGFILE_0
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_0      ),
        .new_trd     (new_trd_wb  ),
        .init_data   (0           ),

        .data_a      (reg_a_out[0]),
        .data_b      (reg_b_out[0])
    );

    regfile #(1)
    REGFILE_1
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[1]),
        .data_b      (reg_b_out[1])
    );

    regfile #(2)
    REGFILE_2
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[2]),
        .data_b      (reg_b_out[2])
    );

    regfile #(3)
    REGFILE_3
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[3]),
        .data_b      (reg_b_out[3])
    );

    regfile #(4)
    REGFILE_4
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[4]),
        .data_b      (reg_b_out[4])
    );

    regfile #(5)
    REGFILE_5
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[5]),
        .data_b      (reg_b_out[5])
    );

    regfile #(6)
    REGFILE_6
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[6]),
        .data_b      (reg_b_out[6])
    );

    regfile #(7)
    REGFILE_7
    (
        .clk         (clk         ),
        .rst_n       (rst_n       ),

        .reg_rd_a    (reg_rd_a    ),
        .reg_rd_b    (reg_rd_b    ),
        .reg_wr      (reg_wr      ),
        .wr_en       (wr_en       ),
        .wr_trd      (wr_trd      ),
        .wr_data     (wr_data     ),
        .init        (init_wb     ),
        .new_trd     (new_trd_wb  ),
        .init_data   (init_data_wb),

        .data_a      (reg_a_out[7]),
        .data_b      (reg_b_out[7])
    );

endmodule