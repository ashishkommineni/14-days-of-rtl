module programmable_timer_sva #(
    parameter int unsigned COUNTER_WIDTH = 16
) (
    input logic clk, rst_n, enable, restart, tick, square_out,
    input logic [COUNTER_WIDTH-1:0] period_cycles,
    input logic [COUNTER_WIDTH-1:0] count_value
);
    localparam logic [COUNTER_WIDTH-1:0] ONE =
        {{(COUNTER_WIDTH-1){1'b0}},1'b1};
    // Checks use SVA preponed sampling; current inputs affect next sampled output.
    assert property (@(posedge clk) disable iff (!rst_n)
        restart |=> (count_value=='0 && !tick && !square_out));
    assert property (@(posedge clk) disable iff (!rst_n)
        (!restart && !enable) |=>
          (!tick && $stable(count_value) && $stable(square_out)));
    assert property (@(posedge clk) disable iff (!rst_n)
        (!restart && enable &&
         (period_cycles<=ONE || count_value>=period_cycles-ONE))
         |=> (tick && count_value=='0 && square_out!=$past(square_out)));
    assert property (@(posedge clk) disable iff (!rst_n)
        tick |-> count_value=='0);
    assert property (@(posedge clk) disable iff (!rst_n)
        (!restart && enable && period_cycles>ONE &&
         count_value<period_cycles-ONE)
         |=> (!tick && count_value==$past(count_value)+ONE));
endmodule
