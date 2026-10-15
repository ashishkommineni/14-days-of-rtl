`timescale 1ns/1ps

module micro_dma_sva (
    input logic clk,
    input logic reset_n,
    input logic start,
    input logic busy,
    input logic done,
    input logic config_error,
    input logic mem_req_valid,
    input logic mem_req_ready,
    input logic [31:0] mem_req_addr,
    input logic mem_rsp_valid,
    input logic out_valid,
    input logic out_ready,
    input logic [31:0] out_data,
    input logic out_last
);
    property p_request_stable;
        @(posedge clk) disable iff (!reset_n)
            mem_req_valid && !mem_req_ready |=> mem_req_valid && $stable(mem_req_addr);
    endproperty
    assert property (p_request_stable);

    property p_output_stable;
        @(posedge clk) disable iff (!reset_n)
            out_valid && !out_ready |=> out_valid && $stable({out_data, out_last});
    endproperty
    assert property (p_output_stable);

    assert property (@(posedge clk) disable iff (!reset_n) done |-> !busy);
    assert property (@(posedge clk) disable iff (!reset_n) out_last |-> out_valid);
    assert property (@(posedge clk) disable iff (!reset_n) !(done && config_error));
    cover property (@(posedge clk) disable iff (!reset_n) mem_req_valid && !mem_req_ready);
    cover property (@(posedge clk) disable iff (!reset_n) out_valid && !out_ready);
    cover property (@(posedge clk) disable iff (!reset_n) done);
    cover property (@(posedge clk) disable iff (!reset_n) config_error);
endmodule
