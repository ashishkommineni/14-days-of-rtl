`timescale 1ns/1ps

module int8_dot_product #(
    parameter int LANES = 4
) (
    input  logic                         clk,
    input  logic                         reset_n,
    input  logic                         in_valid,
    output logic                         in_ready,
    input  logic signed [7:0]            a [0:LANES-1],
    input  logic signed [7:0]            b [0:LANES-1],
    input  logic signed [31:0]           bias,
    output logic                         out_valid,
    input  logic                         out_ready,
    output logic signed [31:0]           result
);
    logic s1_valid, s2_valid;
    logic signed [31:0] s1_sum, s2_sum;
    logic s1_ready, s2_ready;
    logic signed [31:0] dot_comb;

    always_comb begin
        dot_comb = bias;
        for (int lane = 0; lane < LANES; lane++)
            dot_comb += $signed(a[lane]) * $signed(b[lane]);
    end

    assign s2_ready = !s2_valid || out_ready;
    assign s1_ready = !s1_valid || s2_ready;
    assign in_ready = s1_ready;
    assign out_valid = s2_valid;
    assign result = s2_sum;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            s1_valid <= 1'b0;
            s2_valid <= 1'b0;
            s1_sum <= '0;
            s2_sum <= '0;
        end else begin
            if (s2_ready) begin
                s2_valid <= s1_valid;
                if (s1_valid)
                    s2_sum <= s1_sum;
            end
            if (s1_ready) begin
                s1_valid <= in_valid;
                if (in_valid)
                    s1_sum <= dot_comb;
            end
        end
    end
endmodule
