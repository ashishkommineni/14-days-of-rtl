`timescale 1ns/1ps

module two_bit_branch_predictor #(
    parameter int ENTRIES = 16,
    parameter int INDEX_WIDTH = $clog2(ENTRIES)
) (
    input  logic                   clk,
    input  logic                   reset_n,
    input  logic [INDEX_WIDTH-1:0] query_index,
    output logic                   predict_taken,
    input  logic                   update_valid,
    input  logic [INDEX_WIDTH-1:0] update_index,
    input  logic                   actual_taken
);
    logic [1:0] counter [0:ENTRIES-1];
    assign predict_taken = counter[query_index][1];

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int entry = 0; entry < ENTRIES; entry++)
                counter[entry] <= 2'b01; // weakly not-taken
        end else if (update_valid) begin
            if (actual_taken) begin
                if (counter[update_index] != 2'b11)
                    counter[update_index] <= counter[update_index] + 1'b1;
            end else begin
                if (counter[update_index] != 2'b00)
                    counter[update_index] <= counter[update_index] - 1'b1;
            end
        end
    end
endmodule
