`timescale 1ns/1ps

module int8_dot_product_coverage (
    input logic clk,
    input logic reset_n,
    input logic in_valid,
    input logic in_ready,
    input logic out_valid,
    input logic out_ready,
    input logic signed [31:0] result
);
`ifndef VERILATOR
    covergroup dot_cg @(posedge clk);
        option.per_instance = 1;
        cp_input: coverpoint {in_valid, in_ready} iff (reset_n) {
            bins accepted = {2'b11}; bins blocked = {2'b10};
        }
        cp_output: coverpoint {out_valid, out_ready} iff (reset_n) {
            bins transferred = {2'b11}; bins stalled = {2'b10};
        }
        cp_sign: coverpoint result[31] iff (reset_n && out_valid && out_ready);
    endgroup
    dot_cg cg = new();
`endif
endmodule
