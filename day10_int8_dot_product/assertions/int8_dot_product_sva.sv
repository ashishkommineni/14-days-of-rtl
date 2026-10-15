`timescale 1ns/1ps

module int8_dot_product_sva (
    input logic clk,
    input logic reset_n,
    input logic in_valid,
    input logic in_ready,
    input logic out_valid,
    input logic out_ready,
    input logic signed [31:0] result
);
    property p_output_stable_when_stalled;
        @(posedge clk) disable iff (!reset_n)
            out_valid && !out_ready |=> out_valid && $stable(result);
    endproperty
    assert property (p_output_stable_when_stalled);

    property p_valid_does_not_drop_when_stalled;
        @(posedge clk) disable iff (!reset_n)
            out_valid && !out_ready |=> out_valid;
    endproperty
    assert property (p_valid_does_not_drop_when_stalled);

    cover property (@(posedge clk) disable iff (!reset_n) in_valid && in_ready);
    cover property (@(posedge clk) disable iff (!reset_n) out_valid && !out_ready);
    cover property (@(posedge clk) disable iff (!reset_n) out_valid && out_ready && result < 0);
    cover property (@(posedge clk) disable iff (!reset_n) out_valid && out_ready && result > 0);
endmodule
