`timescale 1ns/1ps

module two_bit_branch_predictor_coverage (
    input logic clk,
    input logic reset_n,
    input logic predict_taken,
    input logic update_valid,
    input logic actual_taken
);
`ifndef VERILATOR
    covergroup predictor_cg @(posedge clk);
        option.per_instance = 1;
        cp_prediction: coverpoint predict_taken iff (reset_n);
        cp_actual: coverpoint actual_taken iff (reset_n && update_valid);
        prediction_x_actual: cross cp_prediction, cp_actual;
    endgroup
    predictor_cg cg = new();
`endif
endmodule
