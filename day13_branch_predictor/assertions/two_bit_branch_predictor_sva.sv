`timescale 1ns/1ps

module two_bit_branch_predictor_sva #(
    parameter int INDEX_WIDTH = 4
) (
    input logic clk,
    input logic reset_n,
    input logic [INDEX_WIDTH-1:0] query_index,
    input logic predict_taken,
    input logic update_valid,
    input logic [INDEX_WIDTH-1:0] update_index,
    input logic actual_taken
);
    assert property (@(posedge clk) disable iff (!reset_n) !$isunknown(predict_taken));
    assert property (@(posedge clk) disable iff (!reset_n) !$isunknown(query_index));
    cover property (@(posedge clk) disable iff (!reset_n) update_valid && actual_taken);
    cover property (@(posedge clk) disable iff (!reset_n) update_valid && !actual_taken);
    cover property (@(posedge clk) disable iff (!reset_n) predict_taken);
    cover property (@(posedge clk) disable iff (!reset_n) !predict_taken);
endmodule
