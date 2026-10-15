`timescale 1ns/1ps

module tb_axis_width_converter;
    logic clk = 0;
    logic reset_n;
    logic s_valid, s_ready;
    logic [63:0] s_data;
    logic s_last;
    logic m_valid, m_ready;
    logic [31:0] m_data;
    logic m_last;
    logic [31:0] expected_data [0:511];
    logic expected_last [0:511];
    int put_ptr, get_ptr, queued, inputs, outputs;
    logic pending_valid;
    logic [63:0] pending_data;
    logic pending_last;
    logic accepted_input;
    bit hit_stall, hit_last, hit_nonlast, hit_low, hit_high;

    axis_width_converter_64_to_32 dut (.*);
    axis_width_converter_sva u_sva (.*);
    axis_width_converter_coverage u_cov (.*);
    always #5 clk = ~clk;

    task automatic cycle;
        begin
            @(negedge clk);
            accepted_input = s_valid && s_ready;
            if (m_valid && m_ready) begin
                assert (queued > 0) else $fatal(1, "unexpected 32-bit output");
                assert (m_data === expected_data[get_ptr] && m_last === expected_last[get_ptr])
                    else $fatal(1, "width conversion mismatch data=%h last=%b", m_data, m_last);
                hit_low  |= ((outputs & 1) == 0);
                hit_high |= ((outputs & 1) == 1);
                hit_last |= m_last;
                hit_nonlast |= !m_last;
                get_ptr = (get_ptr + 1) % 512;
                queued--;
                outputs++;
            end
            if (m_valid && !m_ready)
                hit_stall = 1;
            if (accepted_input) begin
                expected_data[put_ptr] = s_data[31:0];
                expected_last[put_ptr] = 1'b0;
                put_ptr = (put_ptr + 1) % 512;
                expected_data[put_ptr] = s_data[63:32];
                expected_last[put_ptr] = s_last;
                put_ptr = (put_ptr + 1) % 512;
                queued += 2;
                inputs++;
            end
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        reset_n=0; s_valid=0; s_data=0; s_last=0; m_ready=0;
        pending_valid=0; pending_data=0; pending_last=0; accepted_input=0;
        put_ptr=0; get_ptr=0; queued=0; inputs=0; outputs=0;
        hit_stall=0; hit_last=0; hit_nonlast=0; hit_low=0; hit_high=0;
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n=1;

        // Force one packet-ending beat before randomized held-valid traffic.
        pending_valid=1; pending_data=64'h1122_3344_aabb_ccdd; pending_last=1;
        while (pending_valid) begin
            s_valid=pending_valid; s_data=pending_data; s_last=pending_last; m_ready=1;
            cycle();
            if (accepted_input) pending_valid=0;
        end

        for (int test=0; test<60; test++) begin
            if (!pending_valid && ($urandom_range(0,2) != 0)) begin
                pending_valid=1;
                pending_data={$urandom(), $urandom()};
                pending_last=((test % 7) == 6);
            end
            s_valid = pending_valid;
            s_data = pending_data;
            s_last = pending_last;
            m_ready = ($urandom_range(0,3) != 0);
            cycle();
            if (accepted_input) pending_valid=0;
        end
        while (pending_valid) begin
            s_valid=pending_valid; s_data=pending_data; s_last=pending_last; m_ready=1;
            cycle();
            if (accepted_input) pending_valid=0;
        end
        s_valid=0; m_ready=1;
        while (queued != 0 || m_valid)
            cycle();
        assert (outputs == 2*inputs) else $fatal(1, "beat conservation failed");
        assert (hit_stall && hit_last && hit_nonlast && hit_low && hit_high)
            else $fatal(1, "width-converter functional coverage not closed");
        $display("[DAY 11] PASS: %0d 64-bit beats became %0d ordered 32-bit beats", inputs, outputs);
        $finish;
    end
endmodule
