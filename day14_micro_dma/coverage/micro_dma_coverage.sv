`timescale 1ns/1ps

module micro_dma_coverage (
    input logic clk,
    input logic reset_n,
    input logic start,
    input logic busy,
    input logic done,
    input logic config_error,
    input logic mem_req_valid,
    input logic mem_req_ready,
    input logic out_valid,
    input logic out_ready,
    input logic out_last
);
`ifndef VERILATOR
    covergroup dma_cg @(posedge clk);
        option.per_instance = 1;
        cp_request: coverpoint {mem_req_valid, mem_req_ready} iff (reset_n) {
            bins accepted = {2'b11}; bins stalled = {2'b10};
        }
        cp_output: coverpoint {out_valid, out_ready} iff (reset_n) {
            bins accepted = {2'b11}; bins stalled = {2'b10};
        }
        cp_completion: coverpoint {config_error, done} iff (reset_n) {
            bins success = {2'b01}; bins bad_config = {2'b10};
        }
        cp_last: coverpoint out_last iff (reset_n && out_valid && out_ready);
    endgroup
    dma_cg cg = new();
`endif
endmodule
