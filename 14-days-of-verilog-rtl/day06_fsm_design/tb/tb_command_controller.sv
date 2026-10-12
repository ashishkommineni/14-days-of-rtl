module tb_command_controller;
  timeunit 1ns; timeprecision 1ps;
  logic clk=0, rst_n=0, start=0, request_valid, request_ready=0;
  logic response_valid=0, response_error=0, busy, done, error;
  int errors=0;
  always #5ns clk=~clk;
  command_controller #(.TIMEOUT_CYCLES(4)) dut (.*);
  task automatic step(input bit s,r,v,e,
                      input bit req,bs,dn,err);
    @(negedge clk);
    start=s; request_ready=r; response_valid=v; response_error=e;
    @(posedge clk); #1ps;
    if ({request_valid,busy,done,error} !== {req,bs,dn,err}) begin
      errors++;
      $error("actual %b expected %b",
        {request_valid,busy,done,error},{req,bs,dn,err});
    end
  endtask
  initial begin
    repeat(2) @(negedge clk); rst_n=1;
    step(0,0,0,0, 0,0,0,0);
    step(1,0,0,0, 1,1,0,0);
    step(0,0,0,0, 1,1,0,0);
    step(0,1,0,0, 0,1,0,0);
    step(0,0,1,0, 0,0,1,0);
    step(0,0,0,0, 0,0,0,0);
    step(1,0,0,0, 1,1,0,0);
    step(0,1,0,0, 0,1,0,0);
    step(0,0,1,1, 0,0,0,1);
    step(0,0,0,0, 0,0,0,0);
    step(1,0,0,0, 1,1,0,0);
    step(0,1,0,0, 0,1,0,0);
    repeat(3) step(0,0,0,0, 0,1,0,0);
    step(0,0,0,0, 0,0,0,1);
    step(0,0,0,0, 0,0,0,0);
    step(1,0,0,0, 1,1,0,0);
    step(0,1,0,0, 0,1,0,0);
    repeat(3) step(0,0,0,0, 0,1,0,0);
    step(0,0,1,0, 0,0,1,0);
    step(0,0,0,0, 0,0,0,0);
    if(errors) $fatal(1,"TEST FAILED: %0d",errors);
    $display("TEST PASSED"); $finish;
  end
endmodule
