`timescale 1ns/1ps

module safe_clock_gate_sva (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic scan_enable,
    input logic gated_clk,
    input logic gate_latched
);
    // Sample the derived clock on its own transitions.  Sampling gated_clk on
    // a source-clock edge observes the preponed value and creates a false
    // failure before the continuous assignment has propagated that edge.
    assert property (@(posedge gated_clk) disable iff (!reset_n)
        clk && gate_latched);
    assert property (@(negedge gated_clk) disable iff (!reset_n)
        !clk);

    // The latched enable may change only during the safe low phase.  This is
    // an immediate assertion intentionally: a concurrent assertion triggered
    // by gate_latched samples clk in the preponed region and can still see the
    // value from just before the source-clock falling edge.
    always @(gate_latched) begin
        if (reset_n)
            assert (!clk);
    end

    property p_capture_request;
        @(negedge clk) disable iff (!reset_n)
            1'b1 |=> gate_latched == $past(enable | scan_enable);
    endproperty
    assert property (p_capture_request);

    cover property (@(posedge clk) disable iff (!reset_n) gated_clk);
    cover property (@(negedge clk) disable iff (!reset_n) scan_enable);
endmodule
