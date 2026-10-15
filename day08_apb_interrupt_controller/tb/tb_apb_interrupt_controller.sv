`timescale 1ns/1ps

module tb_apb_interrupt_controller;
    logic pclk = 0;
    logic preset_n;
    logic [5:0] paddr;
    logic psel, penable, pwrite;
    logic [31:0] pwdata, prdata;
    logic pready, pslverr;
    logic [7:0] irq_sources;
    logic irq;
    int checks;
    bit hit_read, hit_write, hit_error, hit_irq, hit_w1c_set_dominant;

    apb_interrupt_controller dut (.*);
    apb_interrupt_controller_sva u_sva (.*);
    apb_interrupt_controller_coverage u_cov (.*);

    always #5 pclk = ~pclk;

    task automatic apb_transfer(
        input bit write,
        input logic [5:0] addr,
        input logic [31:0] data,
        output logic [31:0] read_data,
        output bit error
    );
        @(negedge pclk);
        psel = 1; penable = 0; pwrite = write; paddr = addr; pwdata = data;
        @(negedge pclk);
        penable = 1;
        #1;
        assert (pready) else $fatal(1, "APB access did not complete");
        read_data = prdata;
        error = pslverr;
        hit_write |= write && !error;
        hit_read  |= !write && !error;
        hit_error |= error;
        @(negedge pclk);
        psel = 0; penable = 0; pwrite = 0; paddr = 0; pwdata = 0;
        checks++;
    endtask

    initial begin
        logic [31:0] rd;
        bit err;
        preset_n = 0; paddr = 0; psel = 0; penable = 0; pwrite = 0;
        pwdata = 0; irq_sources = 0; checks = 0;
        hit_read = 0; hit_write = 0; hit_error = 0; hit_irq = 0;
        hit_w1c_set_dominant = 0;
        repeat (3) @(posedge pclk);
        @(negedge pclk) preset_n = 1;

        apb_transfer(0, 6'h0c, 0, rd, err);
        assert (!err && rd == 32'h4456_1408) else $fatal(1, "ID read failed");

        apb_transfer(1, 6'h04, 32'h0000_0005, rd, err);
        assert (!err) else $fatal(1, "enable write failed");
        apb_transfer(1, 6'h00, 32'h0000_0001, rd, err);

        @(negedge pclk) irq_sources = 8'h01;
        @(posedge pclk); #1;
        @(negedge pclk) irq_sources = 0;
        assert (irq) else $fatal(1, "enabled interrupt was not raised");
        hit_irq = 1;
        apb_transfer(0, 6'h08, 0, rd, err);
        assert (rd[7:0] == 8'h01) else $fatal(1, "status did not latch source");

        // Clear bit 0 while bit 2 arrives. Set dominance must preserve bit 2.
        @(negedge pclk);
        irq_sources = 8'h04;
        psel = 1; penable = 0; pwrite = 1; paddr = 6'h08; pwdata = 32'h1;
        @(negedge pclk) penable = 1;
        @(posedge pclk); #1;
        @(negedge pclk);
        psel = 0; penable = 0; pwrite = 0; irq_sources = 0;
        apb_transfer(0, 6'h08, 0, rd, err);
        assert (rd[7:0] == 8'h04) else $fatal(1, "W1C/set-dominant behavior failed: %h", rd);
        hit_w1c_set_dominant = 1;

        apb_transfer(1, 6'h0c, 32'hdead_beef, rd, err);
        assert (err) else $fatal(1, "write to read-only ID must error");
        apb_transfer(0, 6'h10, 0, rd, err);
        assert (err) else $fatal(1, "unmapped read must error");
        apb_transfer(0, 6'h05, 0, rd, err);
        assert (err) else $fatal(1, "misaligned read must error");

        assert (hit_read && hit_write && hit_error && hit_irq && hit_w1c_set_dominant)
            else $fatal(1, "functional coverage goals were not closed");
        $display("[DAY 8] PASS: %0d APB checks; read/write/error/IRQ/W1C coverage closed", checks);
        $finish;
    end
endmodule
