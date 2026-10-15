`timescale 1ns/1ps

module safe_clock_gate (
    input  logic clk,
    input  logic reset_n,
    input  logic enable,
    input  logic scan_enable,
    output logic gated_clk,
    output logic gate_latched
);
    // A real ASIC implementation maps this behavior to an integrated clock-gating cell.
    always_ff @(negedge clk or negedge reset_n) begin
        if (!reset_n)
            gate_latched <= 1'b0;
        else
            gate_latched <= enable | scan_enable;
    end

    assign gated_clk = clk & gate_latched;
endmodule
