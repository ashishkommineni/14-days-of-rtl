`timescale 1ns/1ps

module secded_memory_coverage (
    input logic clk,
    input logic reset_n,
    input logic req_valid,
    input logic req_write,
    input logic rsp_valid,
    input logic single_error,
    input logic double_error
);
`ifndef VERILATOR
    covergroup ecc_cg @(posedge clk);
        option.per_instance = 1;
        cp_operation: coverpoint req_write iff (reset_n && req_valid) {
            bins read = {0}; bins write = {1};
        }
        cp_result: coverpoint {double_error, single_error} iff (reset_n && rsp_valid) {
            bins clean = {2'b00};
            bins corrected = {2'b01};
            bins detected = {2'b10};
            illegal_bins impossible = {2'b11};
        }
    endgroup
    ecc_cg cg = new();
`endif
endmodule
