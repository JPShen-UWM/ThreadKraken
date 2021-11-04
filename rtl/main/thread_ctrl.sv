/*
 * Module name: thread_ctrl
 * Engineer: Jianping Shen
 * Description: Main thread controler in IF. Store the status of each thread, determine next thread, create, kill or sleep a thread.
 * Dependency: thread_csr
 * Status: developing
 */

`include "header.svh"

module thread_ctrl(
    input               clk,
    input               rst_n,

    input               atomic,     // Do not increment thread pointer
    input               kill,       // Kill determined thread
    input               slp,        // Sleep the objective thread
    input               wake,       // wake up the objective thread
    input [2:0]         act_thrd,   // Act thread that sending the commend
    input [2:0]         obj_thrd,   // Objective thread that being kill, sleep, or wake
    input               stall,      // Stall any action

    output logic [2:0]  cur_thrd,   // Current thread pointing to
    output logic [2:0]  nxt_thrd,   // Next thread
    output logic [2:0]  new_thrd,   // New thread that just been create
    output logic [7:0]  valid_thrd, // Threads that is valid
    output logic [7:0]  run_thrd,   // Threads that is not sleeping
    output logic        thrd_full,  // All threads are valid
    output logic        thrd_of,    // Thread overflow: trying the create a new thread when all threads are used
    output logic        invalid_op, // Trying to kill or sleep a thread that is not its child or itself
    output logic        error       // Other unrecoverable error
);

endmodule