`timescale 1ns/1ps

module apb_interrupt_controller_sva #(
    parameter int ADDR_WIDTH = 6
) (
    input logic                  pclk,
    input logic                  preset_n,
    input logic [ADDR_WIDTH-1:0] paddr,
    input logic                  psel,
    input logic                  penable,
    input logic                  pwrite,
    input logic [31:0]           pwdata,
    input logic                  pready,
    input logic                  pslverr,
    input logic                  irq
);
    property p_access_completes;
        @(posedge pclk) disable iff (!preset_n)
            psel && penable |-> pready;
    endproperty
    assert property (p_access_completes);

    property p_setup_before_access;
        @(posedge pclk) disable iff (!preset_n)
            psel && penable |-> $past(psel);
    endproperty
    assert property (p_setup_before_access);

    property p_control_stable_during_access;
        @(posedge pclk) disable iff (!preset_n)
            psel && penable && !pready |=> $stable({paddr, pwrite, pwdata});
    endproperty
    assert property (p_control_stable_during_access);

    cover property (@(posedge pclk) disable iff (!preset_n) psel && penable && !pwrite && !pslverr);
    cover property (@(posedge pclk) disable iff (!preset_n) psel && penable &&  pwrite && !pslverr);
    cover property (@(posedge pclk) disable iff (!preset_n) irq);
    cover property (@(posedge pclk) disable iff (!preset_n) pslverr);
endmodule
