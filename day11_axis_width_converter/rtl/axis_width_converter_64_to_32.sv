`timescale 1ns/1ps

module axis_width_converter_64_to_32 (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        s_valid,
    output logic        s_ready,
    input  logic [63:0] s_data,
    input  logic        s_last,
    output logic        m_valid,
    input  logic        m_ready,
    output logic [31:0] m_data,
    output logic        m_last
);
    logic busy;
    logic upper_half;
    logic [63:0] data_q;
    logic last_q;

    assign s_ready = !busy;
    assign m_valid = busy;
    assign m_data = upper_half ? data_q[63:32] : data_q[31:0];
    assign m_last = busy && upper_half && last_q;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            busy <= 1'b0;
            upper_half <= 1'b0;
            data_q <= '0;
            last_q <= 1'b0;
        end else begin
            if (s_valid && s_ready) begin
                busy <= 1'b1;
                upper_half <= 1'b0;
                data_q <= s_data;
                last_q <= s_last;
            end else if (m_valid && m_ready) begin
                if (!upper_half)
                    upper_half <= 1'b1;
                else begin
                    busy <= 1'b0;
                    upper_half <= 1'b0;
                end
            end
        end
    end
endmodule
