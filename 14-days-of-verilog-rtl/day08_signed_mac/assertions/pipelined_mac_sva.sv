module pipelined_mac_sva #(
 parameter int A_WIDTH=8, B_WIDTH=8, ACC_WIDTH=20
)(
 input logic clk,rst_n,in_valid,out_valid,overflow,
 input logic signed [ACC_WIDTH-1:0] result
);
 // External checker: for a two-register-stage MAC, sampled in_valid
 // is observed as sampled out_valid two SVA clock ticks later.
 assert property (@(posedge clk) disable iff(!rst_n)
   in_valid |-> ##2 out_valid);
 assert property (@(posedge clk) disable iff(!rst_n)
   !in_valid |-> ##2 !out_valid);
 assert property (@(posedge clk) disable iff(!rst_n)
   out_valid |-> !$isunknown({result,overflow}));
endmodule
