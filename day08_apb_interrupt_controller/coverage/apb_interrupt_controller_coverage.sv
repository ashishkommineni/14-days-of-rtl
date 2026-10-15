`timescale 1ns/1ps

module apb_interrupt_controller_coverage #(
    parameter int ADDR_WIDTH = 6
) (
    input logic                  pclk,
    input logic                  preset_n,
    input logic [ADDR_WIDTH-1:0] paddr,
    input logic                  psel,
    input logic                  penable,
    input logic                  pwrite,
    input logic                  pslverr,
    input logic                  irq
);
`ifndef VERILATOR
    covergroup apb_irq_cg @(posedge pclk);
        option.per_instance = 1;
        cp_operation: coverpoint pwrite iff (preset_n && psel && penable) {
            bins read = {0}; bins write = {1};
        }
        cp_address: coverpoint paddr[3:2] iff (preset_n && psel && penable && !pslverr) {
            bins registers[] = {[0:3]};
        }
        cp_error: coverpoint pslverr iff (preset_n && psel && penable);
        cp_irq: coverpoint irq iff (preset_n);
        operation_x_address: cross cp_operation, cp_address;
    endgroup
    apb_irq_cg cg = new();
`endif
endmodule
