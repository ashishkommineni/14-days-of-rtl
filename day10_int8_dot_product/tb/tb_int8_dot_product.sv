`timescale 1ns/1ps

module tb_int8_dot_product;
    localparam int LANES = 4;
    logic clk = 0;
    logic reset_n;
    logic in_valid, in_ready;
    logic signed [7:0] a [0:LANES-1];
    logic signed [7:0] b [0:LANES-1];
    logic signed [31:0] bias;
    logic out_valid, out_ready;
    logic signed [31:0] result;
    logic signed [31:0] expected [0:255];
    int put_ptr, get_ptr, queued, accepted, delivered, cycles;
    logic accepted_input;
    bit hit_positive, hit_negative, hit_zero, hit_stall, hit_bubble;

    int8_dot_product dut (.*);
    int8_dot_product_sva u_sva (.*);
    int8_dot_product_coverage u_cov (.*);
    always #5 clk = ~clk;

    function automatic logic signed [31:0] reference_dot;
        logic signed [31:0] sum;
        begin
            sum = bias;
            for (int lane = 0; lane < LANES; lane++)
                sum += $signed(a[lane]) * $signed(b[lane]);
            return sum;
        end
    endfunction

    task automatic observe_and_drive;
        logic signed [31:0] predicted;
        begin
            @(negedge clk);
            accepted_input = in_valid && in_ready;
            if (out_valid && out_ready) begin
                assert (queued > 0) else $fatal(1, "unexpected dot-product output");
                assert (result === expected[get_ptr])
                    else $fatal(1, "expected=%0d actual=%0d", expected[get_ptr], result);
                hit_positive |= result > 0;
                hit_negative |= result < 0;
                hit_zero |= result == 0;
                get_ptr = (get_ptr + 1) % 256;
                queued--;
                delivered++;
            end
            if (out_valid && !out_ready)
                hit_stall = 1;
            if (!in_valid)
                hit_bubble = 1;
            if (accepted_input) begin
                predicted = reference_dot();
                expected[put_ptr] = predicted;
                put_ptr = (put_ptr + 1) % 256;
                queued++;
                accepted++;
            end
            @(posedge clk);
            #1;
            cycles++;
        end
    endtask

    initial begin
        reset_n = 0; in_valid = 0; out_ready = 0; bias = 0;
        put_ptr = 0; get_ptr = 0; queued = 0; accepted = 0; delivered = 0; cycles = 0;
        hit_positive = 0; hit_negative = 0; hit_zero = 0; hit_stall = 0; hit_bubble = 0;
        accepted_input = 0;
        for (int lane = 0; lane < LANES; lane++) begin a[lane] = 0; b[lane] = 0; end
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n = 1;
        // Keep in_valid low through the first active edge.  All later vectors
        // are presented after a posedge and recorded at the following negedge,
        // so this alignment prevents an unscored startup acceptance.
        @(posedge clk);
        #1;

        // Deterministic positive, negative and zero results.
        a[0]=1; a[1]=2; a[2]=3; a[3]=4;
        b[0]=4; b[1]=3; b[2]=2; b[3]=1; bias=0; in_valid=1; out_ready=1;
        observe_and_drive();
        assert (accepted_input) else $fatal(1, "directed positive vector was not accepted");
        a[0]=-1; a[1]=-2; a[2]=-3; a[3]=-4;
        observe_and_drive();
        assert (accepted_input) else $fatal(1, "directed negative vector was not accepted");
        for (int lane=0; lane<LANES; lane++) begin a[lane]=0; b[lane]=0; end
        observe_and_drive();
        assert (accepted_input) else $fatal(1, "directed zero vector was not accepted");
        in_valid = 0;

        for (int test = 0; test < 80; test++) begin
            if (!in_valid && ($urandom_range(0, 3) != 0)) begin
                in_valid = 1;
                bias = $signed($urandom_range(0, 2000)) - 1000;
                for (int lane = 0; lane < LANES; lane++) begin
                    a[lane] = $signed($urandom_range(0, 31)) - 16;
                    b[lane] = $signed($urandom_range(0, 31)) - 16;
                end
            end
            out_ready = ($urandom_range(0, 3) != 0);
            observe_and_drive();
            if (accepted_input)
                in_valid = 0;
        end

        out_ready = 1;
        while (in_valid) begin
            observe_and_drive();
            if (accepted_input)
                in_valid = 0;
        end
        while (queued != 0 || out_valid)
            observe_and_drive();
        assert (accepted == delivered) else $fatal(1, "conservation failed accepted=%0d delivered=%0d", accepted, delivered);
        assert (hit_positive && hit_negative && hit_zero && hit_stall && hit_bubble)
            else $fatal(1, "dot-product functional coverage not closed");
        $display("[DAY 10] PASS: %0d vectors preserved through elastic INT8 pipeline", delivered);
        $finish;
    end
endmodule
