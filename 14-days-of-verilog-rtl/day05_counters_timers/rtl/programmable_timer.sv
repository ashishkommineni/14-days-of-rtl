module programmable_timer #(
    parameter int unsigned COUNTER_WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic restart,
    input  logic [COUNTER_WIDTH-1:0] period_cycles,
    output logic tick,
    output logic square_out,
    output logic [COUNTER_WIDTH-1:0] count_value
);
    localparam logic [COUNTER_WIDTH-1:0] ONE = {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_value <= '0;
            tick <= 1'b0;
            square_out <= 1'b0;
        end else begin
            tick <= 1'b0;
            if (restart) begin
                count_value <= '0;
                square_out <= 1'b0;
            end else if (enable) begin
                if (period_cycles <= ONE || count_value >= period_cycles - ONE) begin
                    count_value <= '0;
                    tick <= 1'b1;
                    square_out <= ~square_out;
                end else count_value <= count_value + ONE;
            end
        end
    end
endmodule
