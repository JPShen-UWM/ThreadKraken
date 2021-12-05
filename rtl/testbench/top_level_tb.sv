/*
 * Module name: top_level_tb
 * Engineer: Jianping Shen
 * Description: Testbench for thread kraken processor
 * Dependency: threadkraken_top.sv, no_miss_mem.sv, miss_mem.sv
 * Status: Done
**/

`include "../main/header.svh"
module thread_ctrl_tb();
    parameter mem_miss = 0; // 1 to simulate cache miss
    parameter test_file = ""