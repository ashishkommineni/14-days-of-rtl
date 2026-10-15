`timescale 1ns/1ps

module axis_width_converter_coverage (
    input logic clk,
    input logic reset_n,
    input logic s_valid,
    input logic s_ready,
    input logic s_last,
    input logic m_valid,
    input logic m_ready,
    input logic m_last
);
`ifndef VERILATOR
    covergroup width_cg @(posedge clk);
        option.per_instance = 1;
        cp_input_last: coverpoint s_last iff (reset_n && s_valid && s_ready);
        cp_output: coverpoint {m_valid, m_ready} iff (reset_n) {
            bins transferred = {2'b11}; bins stalled = {2'b10};
        }
        cp_output_last: coverpoint m_last iff (reset_n && m_valid && m_ready);
    endgroup
    width_cg cg = new();
`endif
endmodule
