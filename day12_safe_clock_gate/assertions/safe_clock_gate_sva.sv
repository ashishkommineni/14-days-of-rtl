`timescale 1ns/1ps

module safe_clock_gate_sva (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic scan_enable,
    input logic gated_clk,
    input logic gate_latched
);
    assert property (@(posedge clk) disable iff (!reset_n) gated_clk == gate_latched);
    assert property (@(negedge clk) disable iff (!reset_n) !gated_clk);

    property p_capture_request;
        @(negedge clk) disable iff (!reset_n)
            1'b1 |=> gate_latched == $past(enable | scan_enable);
    endproperty
    assert property (p_capture_request);

    cover property (@(posedge clk) disable iff (!reset_n) gated_clk);
    cover property (@(negedge clk) disable iff (!reset_n) scan_enable);
endmodule
