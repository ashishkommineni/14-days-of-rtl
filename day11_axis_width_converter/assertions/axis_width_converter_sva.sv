`timescale 1ns/1ps

module axis_width_converter_sva (
    input logic clk,
    input logic reset_n,
    input logic s_valid,
    input logic s_ready,
    input logic m_valid,
    input logic m_ready,
    input logic [31:0] m_data,
    input logic m_last
);
    property p_stable_during_backpressure;
        @(posedge clk) disable iff (!reset_n)
            m_valid && !m_ready |=> m_valid && $stable({m_data, m_last});
    endproperty
    assert property (p_stable_during_backpressure);

    assert property (@(posedge clk) disable iff (!reset_n) m_last |-> m_valid);
    assert property (@(posedge clk) disable iff (!reset_n) s_ready |-> !m_valid);
    cover property (@(posedge clk) disable iff (!reset_n) s_valid && s_ready);
    cover property (@(posedge clk) disable iff (!reset_n) m_valid && !m_ready);
    cover property (@(posedge clk) disable iff (!reset_n) m_valid && m_ready && m_last);
endmodule
