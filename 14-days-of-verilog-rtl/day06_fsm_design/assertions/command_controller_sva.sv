module command_controller_sva #(
 parameter int unsigned TIMEOUT_CYCLES = 8
) (
 input logic clk,rst_n,start,request_valid,request_ready,
 input logic response_valid,response_error,busy,done,error
);
 // Port-level obligations. State-transition properties may be bound to internals.
 assert property (@(posedge clk) disable iff (!rst_n)
    request_valid && !request_ready |=> request_valid);
 assert property (@(posedge clk) disable iff (!rst_n)
    !(done && error));
 assert property (@(posedge clk) disable iff (!rst_n)
    done |=> !done);
 assert property (@(posedge clk) disable iff (!rst_n)
    error |=> !error);
 assert property (@(posedge clk) disable iff (!rst_n)
    done |-> !busy && !request_valid);
 assert property (@(posedge clk) disable iff (!rst_n)
    error |-> !busy && !request_valid);
endmodule
