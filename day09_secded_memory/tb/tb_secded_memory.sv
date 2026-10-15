`timescale 1ns/1ps

module tb_secded_memory;
    logic clk = 0;
    logic reset_n;
    logic req_valid, req_write;
    logic [3:0] req_addr;
    logic [31:0] req_wdata;
    logic rsp_valid;
    logic [31:0] rsp_rdata;
    logic single_error, double_error;
    logic inject_valid;
    logic [3:0] inject_addr;
    logic [38:0] inject_mask;
    int checks;
    bit hit_clean, hit_single_data, hit_single_parity, hit_double;

    secded_memory dut (.*);
    secded_memory_sva u_sva (.*);
    secded_memory_coverage u_cov (.*);
    always #5 clk = ~clk;

    task automatic write_word(input logic [3:0] address, input logic [31:0] data);
        @(negedge clk); req_valid = 1; req_write = 1; req_addr = address; req_wdata = data;
        @(negedge clk); req_valid = 0; req_write = 0;
    endtask

    task automatic inject(input logic [3:0] address, input logic [38:0] mask);
        @(negedge clk); inject_valid = 1; inject_addr = address; inject_mask = mask;
        @(negedge clk); inject_valid = 0; inject_mask = 0;
    endtask

    task automatic read_check(
        input logic [3:0] address,
        input logic [31:0] expected,
        input bit expect_single,
        input bit expect_double
    );
        @(negedge clk); req_valid = 1; req_write = 0; req_addr = address;
        @(posedge clk); #1;
        assert (rsp_valid) else $fatal(1, "missing read response");
        if (!expect_double)
            assert (rsp_rdata === expected)
                else $fatal(1, "address %0d expected=%h actual=%h", address, expected, rsp_rdata);
        assert (single_error == expect_single && double_error == expect_double)
            else $fatal(1, "ECC flags mismatch single=%b double=%b", single_error, double_error);
        hit_clean         |= !expect_single && !expect_double;
        hit_single_data   |= expect_single && !expect_double && (address == 1);
        hit_single_parity |= expect_single && !expect_double && (address == 2);
        hit_double        |= expect_double;
        checks++;
        @(negedge clk); req_valid = 0;
    endtask

    initial begin
        reset_n = 0; req_valid = 0; req_write = 0; req_addr = 0; req_wdata = 0;
        inject_valid = 0; inject_addr = 0; inject_mask = 0; checks = 0;
        hit_clean = 0; hit_single_data = 0; hit_single_parity = 0; hit_double = 0;
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n = 1;

        write_word(0, 32'h1234_5678);
        write_word(1, 32'h89ab_cdef);
        write_word(2, 32'h0bad_f00d);
        write_word(3, 32'hcafe_babe);
        read_check(0, 32'h1234_5678, 0, 0);

        inject(1, 39'b1 << 5);
        read_check(1, 32'h89ab_cdef, 1, 0);

        inject(2, 39'b1 << 38);
        read_check(2, 32'h0bad_f00d, 1, 0);

        inject(3, (39'b1 << 5) | (39'b1 << 12));
        // Uncorrectable data is intentionally not compared; only classification is valid.
        read_check(3, 32'hcafe_babe, 0, 1);

        assert (hit_clean && hit_single_data && hit_single_parity && hit_double)
            else $fatal(1, "ECC functional coverage was not closed");
        $display("[DAY 9] PASS: %0d reads; clean/corrected/parity/double-error coverage closed", checks);
        $finish;
    end
endmodule
