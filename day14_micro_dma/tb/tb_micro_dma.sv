`timescale 1ns/1ps

module tb_micro_dma;
    logic clk = 0;
    logic reset_n;
    logic start;
    logic [31:0] base_addr;
    logic [15:0] length_words;
    logic busy, done, config_error;
    logic mem_req_valid, mem_req_ready;
    logic [31:0] mem_req_addr;
    logic mem_rsp_valid;
    logic [31:0] mem_rsp_data;
    logic out_valid, out_ready;
    logic [31:0] out_data;
    logic out_last;
    logic [31:0] pending_addr;
    int response_delay;
    int words_seen, requests_seen;
    bit hit_req_stall, hit_out_stall, hit_done, hit_zero_error, hit_align_error, hit_last;

    micro_dma dut (.*);
    micro_dma_sva u_sva (.*);
    micro_dma_coverage u_cov (.*);
    always #5 clk = ~clk;

    function automatic logic [31:0] memory_value(input logic [31:0] address);
        return address ^ 32'ha5a5_5a5a;
    endfunction

    // One-outstanding-request memory model with deterministic variable latency.
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mem_rsp_valid <= 0;
            mem_rsp_data <= 0;
            pending_addr <= 0;
            response_delay <= -1;
        end else begin
            mem_rsp_valid <= 0;
            if (mem_req_valid && mem_req_ready) begin
                pending_addr <= mem_req_addr;
                response_delay <= (mem_req_addr[3:2] % 3);
                requests_seen <= requests_seen + 1;
            end else if (response_delay == 0) begin
                mem_rsp_valid <= 1;
                mem_rsp_data <= memory_value(pending_addr);
                response_delay <= -1;
            end else if (response_delay > 0) begin
                response_delay <= response_delay - 1;
            end
        end
    end

    task automatic launch(input logic [31:0] address, input int unsigned words);
        @(negedge clk); base_addr=address; length_words=words[15:0]; start=1;
        @(negedge clk); start=0;
    endtask

    task automatic wait_idle;
        int watchdog;
        begin
            watchdog=0;
            while (busy && watchdog < 500) begin
                @(negedge clk);
                if (mem_req_valid && !hit_req_stall)
                    mem_req_ready = 0;
                else
                    mem_req_ready = ($urandom_range(0,3) != 0);
                if (out_valid && !hit_out_stall)
                    out_ready = 0;
                else
                    out_ready = ($urandom_range(0,3) != 0);
                hit_req_stall |= mem_req_valid && !mem_req_ready;
                hit_out_stall |= out_valid && !out_ready;
                if (out_valid && out_ready) begin
                    assert (out_data == memory_value(base_addr + 4*words_seen))
                        else $fatal(1, "DMA word %0d mismatch expected=%h actual=%h", words_seen,
                                    memory_value(base_addr + 4*words_seen), out_data);
                    words_seen++;
                    hit_last |= out_last;
                end
                watchdog++;
            end
            assert (watchdog < 500) else $fatal(1, "DMA watchdog expired");
            hit_done |= done;
        end
    endtask

    initial begin
        reset_n=0; start=0; base_addr=0; length_words=0;
        mem_req_ready=0; out_ready=0; words_seen=0; requests_seen=0;
        hit_req_stall=0; hit_out_stall=0; hit_done=0; hit_zero_error=0; hit_align_error=0; hit_last=0;
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n=1;

        launch(32'h0000_1000, 0);
        #1; hit_zero_error = config_error;
        assert (config_error && !busy) else $fatal(1, "zero-length transfer must be rejected");

        launch(32'h0000_1002, 4);
        #1; hit_align_error = config_error;
        assert (config_error && !busy) else $fatal(1, "misaligned transfer must be rejected");

        words_seen=0; requests_seen=0;
        launch(32'h0000_2000, 12);
        wait_idle();
        assert (words_seen == 12 && requests_seen == 12)
            else $fatal(1, "DMA conservation failed requests=%0d outputs=%0d", requests_seen, words_seen);
        assert (hit_req_stall && hit_out_stall && hit_done && hit_zero_error && hit_align_error && hit_last)
            else $fatal(1, "DMA functional coverage not closed");
        $display("[DAY 14] PASS: 12-word DMA transfer preserved address/data/order under backpressure");
        $finish;
    end
endmodule
