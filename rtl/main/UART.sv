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

    output  logic   [1:0]   mem_op      ,
);
    


endmodule