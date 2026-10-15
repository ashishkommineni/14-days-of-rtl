`timescale 1ns/1ps

module tb_two_bit_branch_predictor;
    logic clk = 0;
    logic reset_n;
    logic [3:0] query_index;
    logic predict_taken;
    logic update_valid;
    logic [3:0] update_index;
    logic actual_taken;
    logic [1:0] reference [0:15];
    int checks;
    bit hit_transition [0:3][0:1];
    bit hit_correct_taken, hit_correct_not_taken, hit_mispredict_taken, hit_mispredict_not_taken;

    two_bit_branch_predictor dut (.*);
    two_bit_branch_predictor_sva u_sva (.*);
    two_bit_branch_predictor_coverage u_cov (.*);
    always #5 clk = ~clk;

    task automatic update(input logic [3:0] index, input bit outcome);
        logic prediction_before;
        logic [1:0] old_state;
        begin
            @(negedge clk);
            query_index = index;
            update_valid = 1;
            update_index = index;
            actual_taken = outcome;
            #1;
            prediction_before = predict_taken;
            old_state = reference[index];
            hit_transition[old_state][outcome] = 1;
            hit_correct_taken |= prediction_before && outcome;
            hit_correct_not_taken |= !prediction_before && !outcome;
            hit_mispredict_taken |= !prediction_before && outcome;
            hit_mispredict_not_taken |= prediction_before && !outcome;
            @(posedge clk); #1;
            if (outcome && reference[index] != 2'b11)
                reference[index]++;
            else if (!outcome && reference[index] != 2'b00)
                reference[index]--;
            assert (predict_taken == reference[index][1])
                else $fatal(1, "index %0d reference state=%b prediction=%b", index, reference[index], predict_taken);
            checks++;
            @(negedge clk) update_valid = 0;
        end
    endtask

    initial begin
        reset_n=0; query_index=0; update_valid=0; update_index=0; actual_taken=0; checks=0;
        hit_correct_taken=0; hit_correct_not_taken=0; hit_mispredict_taken=0; hit_mispredict_not_taken=0;
        for (int state=0; state<4; state++)
            for (int outcome=0; outcome<2; outcome++) hit_transition[state][outcome]=0;
        for (int entry=0; entry<16; entry++) reference[entry]=2'b01;
        repeat (3) @(posedge clk);
        @(negedge clk) reset_n=1;

        // Drive one entry through all states and both saturation boundaries.
        update(0,0); update(0,0); update(0,1); update(0,1); update(0,1); update(0,1);
        update(0,0); update(0,0); update(0,0);
        for (int test=0; test<80; test++)
            update($urandom_range(0,15), $urandom_range(0,1));

        assert (hit_correct_taken && hit_correct_not_taken && hit_mispredict_taken && hit_mispredict_not_taken)
            else $fatal(1, "prediction/outcome cross coverage not closed");
        assert (hit_transition[0][0] && hit_transition[0][1] && hit_transition[1][0] &&
                hit_transition[1][1] && hit_transition[2][0] && hit_transition[2][1] &&
                hit_transition[3][0] && hit_transition[3][1])
            else $fatal(1, "not all state/outcome transitions were covered");
        $display("[DAY 13] PASS: %0d predictor updates; all state/outcome transitions covered", checks);
        $finish;
    end
endmodule
