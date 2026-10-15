`timescale 1ns/1ps

module tb_safe_clock_gate;
    logic clk = 0;
    logic reset_n;
    logic enable, scan_enable;
    logic gated_clk, gate_latched;
    int source_rises, gated_rises;
    bit hit_enable, hit_disable, hit_scan, hit_midcycle_change;

    safe_clock_gate dut (.*);
    safe_clock_gate_sva u_sva (.*);
    safe_clock_gate_coverage u_cov (.*);
    always #5 clk = ~clk;
    always @(posedge clk) source_rises++;
    always @(posedge gated_clk) begin
        assert (clk) else $fatal(1, "gated clock rose while source clock was low");
        gated_rises++;
    end

    task automatic request(input bit functional_enable, input bit test_enable);
        @(posedge clk);
        #2; // deliberately change during the high phase
        enable = functional_enable;
        scan_enable = test_enable;
        hit_midcycle_change = 1;
        @(negedge clk); #1;
        assert (gate_latched == (functional_enable | test_enable))
            else $fatal(1, "gate request was not captured safely");
        hit_enable |= functional_enable;
        hit_disable |= !functional_enable && !test_enable;
        hit_scan |= test_enable;
    endtask

    initial begin
        reset_n=0; enable=0; scan_enable=0; source_rises=0; gated_rises=0;
        hit_enable=0; hit_disable=0; hit_scan=0; hit_midcycle_change=0;
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n=1;

        request(1,0);
        repeat (3) @(posedge clk);
        request(0,0);
        repeat (2) @(posedge clk);
        request(0,1);
        repeat (2) @(posedge clk);
        request(0,0);
        repeat (2) @(posedge clk);

        assert (gated_rises == 7)
            else $fatal(1, "expected seven full gated pulses, observed %0d", gated_rises);
        assert (hit_enable && hit_disable && hit_scan && hit_midcycle_change)
            else $fatal(1, "clock-gate functional coverage not closed");
        $display("[DAY 12] PASS: %0d full gated pulses; functional and scan requests covered", gated_rises);
        $finish;
    end
endmodule
