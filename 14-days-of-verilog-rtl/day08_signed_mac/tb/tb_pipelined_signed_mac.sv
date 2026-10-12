module tb_pipelined_signed_mac;
 timeunit 1ns; timeprecision 1ps;
 localparam int A_WIDTH=4,B_WIDTH=4,ACC_WIDTH=8;
 logic clk=0,rst_n=0,in_valid=0;
 logic signed [A_WIDTH-1:0] a='0;
 logic signed [B_WIDTH-1:0] b='0;
 logic signed [ACC_WIDTH-1:0] addend='0;
 logic out_valid,overflow;
 logic signed [ACC_WIDTH-1:0] result;
 int errors=0, checked=0;
 typedef struct packed {logic signed [ACC_WIDTH-1:0] value; logic ov;} expected_t;
 expected_t queue[$];
 expected_t item;
 always #5ns clk=~clk;
 pipelined_signed_mac #(.A_WIDTH(A_WIDTH),.B_WIDTH(B_WIDTH),
    .ACC_WIDTH(ACC_WIDTH),.SATURATE(1'b1)) dut (.*);
 pipelined_mac_sva #(.A_WIDTH(A_WIDTH), .B_WIDTH(B_WIDTH),
                     .ACC_WIDTH(ACC_WIDTH)) u_assertions (
   .clk, .rst_n, .in_valid, .out_valid, .overflow, .result
 );
 function automatic expected_t ref_mac(input integer signed aa,bb,cc);
   integer signed sum;
   expected_t e;
   sum=aa*bb+cc;
   e.ov=(sum>127)||(sum< -128);
   if(sum>127) e.value=8'sd127;
   else if(sum< -128) e.value=-8'sd128;
   else e.value=8'(sum);
   return e;
 endfunction
 task automatic drive(input bit v, input integer signed aa,bb,cc);
   @(negedge clk);
   in_valid=v; a=A_WIDTH'(aa); b=B_WIDTH'(bb); addend=ACC_WIDTH'(cc);
   if(v) queue.push_back(ref_mac(aa,bb,cc));
 endtask
 // The checker runs after NBA and compares outputs when valid.
 always @(posedge clk) begin
   #1ps;
   if(rst_n && out_valid) begin
     if(queue.size()==0) begin errors++; $error("Unexpected output"); end
     else begin
       item=queue.pop_front();
       checked++;
       if(result !== item.value || overflow !== item.ov) begin
         errors++;
         $error("actual %0d ov=%b expected %0d ov=%b",
                result,overflow,item.value,item.ov);
       end
     end
   end
 end
 initial begin
   repeat(2) @(negedge clk);
   rst_n=1;
   drive(1,3,4,5);
   drive(1,-3,4,2);
   drive(1,7,7,100);
   drive(1,-8,7,-100);
   drive(1,-8,-8,0);
   drive(0,0,0,0);
   drive(1,-1,-1,-128);
   repeat(100) begin
      drive($urandom_range(0,1),
        $signed(4'($urandom_range(0,15))),
        $signed(4'($urandom_range(0,15))),
        $signed(8'($urandom_range(0,255))));
   end
   repeat(4) drive(0,0,0,0);
   @(negedge clk);
   if(queue.size()!=0) begin errors++; $error("Unconsumed expected transactions"); end
   if(checked==0) begin errors++; $error("No transactions checked"); end
   if(errors) $fatal(1,"TEST FAILED: %0d errors",errors);
   $display("TEST PASSED: checked %0d transactions",checked);
   $finish;
 end
endmodule
