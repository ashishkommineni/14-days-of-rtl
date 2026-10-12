module tb_programmable_timer;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    logic clk = 0, rst_n, enable, restart;
    logic [WIDTH-1:0] period_cycles;
    logic tick, square_out;
    logic [WIDTH-1:0] count_value;
    logic [WIDTH-1:0] exp_count;
    logic exp_tick, exp_square;
    int errors = 0;
    always #5ns clk = ~clk;
    programmable_timer #(.COUNTER_WIDTH(WIDTH)) dut (.*);

    task automatic cycle(input bit en, input bit rst_phase, input logic [WIDTH-1:0] period);
        @(negedge clk);
        enable = en; restart = rst_phase; period_cycles = period;
        @(posedge clk);
        exp_tick = 0;
        if (rst_phase) begin exp_count = '0; exp_square = 0; end
        else if (en) begin
            if (period <= 1 || exp_count >= period - 1'b1) begin
                exp_count = '0; exp_tick = 1; exp_square = ~exp_square;
            end else exp_count = exp_count + 1'b1;
        end
        #1ps;
        if (count_value !== exp_count || tick !== exp_tick || square_out !== exp_square) begin
            errors++;
            $error("period=%0d actual=%0d/%b/%b expected=%0d/%b/%b",
                period,count_value,tick,square_out,exp_count,exp_tick,exp_square);
        end
    endtask

    initial begin
        rst_n=0; enable=0; restart=0; period_cycles=4;
        exp_count=0; exp_tick=0; exp_square=0;
        repeat (2) @(negedge clk);
        rst_n=1;
        cycle(1,1,4);
        repeat(12) cycle(1,0,4);
        repeat(3) cycle(0,0,4);
        repeat(5) cycle(1,0,4);
        repeat(4) cycle(1,0,1);
        repeat(3) cycle(1,0,0);
        repeat(100) cycle($urandom_range(0,1),$urandom_range(0,10)==0,
                          $urandom_range(1,20));
        @(negedge clk);
        #2ns rst_n=0;
        #1ps;
        if (count_value !== '0 || tick !== 0 || square_out !== 0) begin
            errors++; $error("Asynchronous reset failure");
        end
        if(errors) $fatal(1,"FAIL %0d errors",errors);
        $display("TEST PASSED");
        $finish;
    end
endmodule
