`timescale 1ns/1ps

module safe_clock_gate_coverage (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic scan_enable,
    input logic gated_clk
);
`ifndef VERILATOR
    covergroup gate_cg @(negedge clk);
        option.per_instance = 1;
        cp_enable: coverpoint enable iff (reset_n);
        cp_scan: coverpoint scan_enable iff (reset_n);
        request_cross: cross cp_enable, cp_scan;
    endgroup
    gate_cg cg = new();
`endif
endmodule
