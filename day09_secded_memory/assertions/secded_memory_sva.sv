`timescale 1ns/1ps

module secded_memory_sva (
    input logic clk,
    input logic reset_n,
    input logic req_valid,
    input logic req_write,
    input logic rsp_valid,
    input logic single_error,
    input logic double_error
);
    property p_read_response;
        @(posedge clk) disable iff (!reset_n)
            req_valid && !req_write |=> rsp_valid;
    endproperty
    assert property (p_read_response);

    property p_no_write_response;
        @(posedge clk) disable iff (!reset_n)
            req_valid && req_write |=> !rsp_valid;
    endproperty
    assert property (p_no_write_response);

    assert property (@(posedge clk) !(single_error && double_error));
    cover property (@(posedge clk) disable iff (!reset_n) rsp_valid && single_error);
    cover property (@(posedge clk) disable iff (!reset_n) rsp_valid && double_error);
endmodule
