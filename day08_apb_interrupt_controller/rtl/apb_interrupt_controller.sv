`timescale 1ns/1ps

module apb_interrupt_controller #(
    parameter int ADDR_WIDTH = 6,
    parameter int IRQ_WIDTH  = 8
) (
    input  logic                  pclk,
    input  logic                  preset_n,
    input  logic [ADDR_WIDTH-1:0] paddr,
    input  logic                  psel,
    input  logic                  penable,
    input  logic                  pwrite,
    input  logic [31:0]           pwdata,
    output logic [31:0]           prdata,
    output logic                  pready,
    output logic                  pslverr,
    input  logic [IRQ_WIDTH-1:0]  irq_sources,
    output logic                  irq
);
    localparam logic [ADDR_WIDTH-1:0] ADDR_CTRL       = 'h00;
    localparam logic [ADDR_WIDTH-1:0] ADDR_IRQ_ENABLE = 'h04;
    localparam logic [ADDR_WIDTH-1:0] ADDR_IRQ_STATUS = 'h08;
    localparam logic [ADDR_WIDTH-1:0] ADDR_ID         = 'h0c;

    logic global_enable;
    logic [IRQ_WIDTH-1:0] irq_enable;
    logic [IRQ_WIDTH-1:0] irq_status;
    logic access;
    logic address_valid;

    assign access = psel && penable;
    assign pready = 1'b1;
    assign address_valid = (paddr == ADDR_CTRL) ||
                           (paddr == ADDR_IRQ_ENABLE) ||
                           (paddr == ADDR_IRQ_STATUS) ||
                           (paddr == ADDR_ID);
    assign pslverr = access && (!address_valid || (paddr[1:0] != 2'b00) ||
                               (pwrite && (paddr == ADDR_ID)));
    assign irq = global_enable && |(irq_status & irq_enable);

    always_comb begin
        prdata = 32'h0;
        unique case (paddr)
            ADDR_CTRL:       prdata = {31'h0, global_enable};
            ADDR_IRQ_ENABLE: prdata = {{(32-IRQ_WIDTH){1'b0}}, irq_enable};
            ADDR_IRQ_STATUS: prdata = {{(32-IRQ_WIDTH){1'b0}}, irq_status};
            ADDR_ID:         prdata = 32'h4456_1408;
            default:         prdata = 32'h0;
        endcase
    end

    always_ff @(posedge pclk or negedge preset_n) begin
        logic [IRQ_WIDTH-1:0] clear_mask;
        if (!preset_n) begin
            global_enable <= 1'b0;
            irq_enable    <= '0;
            irq_status    <= '0;
        end else begin
            clear_mask = '0;
            if (access && pready && pwrite && !pslverr) begin
                unique case (paddr)
                    ADDR_CTRL:       global_enable <= pwdata[0];
                    ADDR_IRQ_ENABLE: irq_enable <= pwdata[IRQ_WIDTH-1:0];
                    ADDR_IRQ_STATUS: clear_mask = pwdata[IRQ_WIDTH-1:0];
                    default: ;
                endcase
            end
            // Set-dominant W1C: an event arriving with a clear is not lost.
            irq_status <= (irq_status & ~clear_mask) | irq_sources;
        end
    end
endmodule
