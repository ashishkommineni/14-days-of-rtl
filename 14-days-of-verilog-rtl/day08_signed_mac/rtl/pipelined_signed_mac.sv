module pipelined_signed_mac #(
 parameter int unsigned A_WIDTH=8, B_WIDTH=8, ACC_WIDTH=20,
 parameter bit SATURATE=1'b1
)(
 input logic clk, rst_n, in_valid,
 input logic signed [A_WIDTH-1:0] a,
 input logic signed [B_WIDTH-1:0] b,
 input logic signed [ACC_WIDTH-1:0] addend,
 output logic out_valid,
 output logic signed [ACC_WIDTH-1:0] result,
 output logic overflow
);
 localparam int unsigned PROD_WIDTH=A_WIDTH+B_WIDTH;
 localparam int unsigned SUM_WIDTH=
   ((PROD_WIDTH>ACC_WIDTH)?PROD_WIDTH:ACC_WIDTH)+1;
 localparam logic signed [ACC_WIDTH-1:0] ACC_MAX =
   {1'b0,{(ACC_WIDTH-1){1'b1}}};
 localparam logic signed [ACC_WIDTH-1:0] ACC_MIN =
   {1'b1,{(ACC_WIDTH-1){1'b0}}};
 logic signed [PROD_WIDTH-1:0] product_s1;
 logic signed [SUM_WIDTH-1:0] addend_s1,full_sum;
 logic valid_s1;
 logic signed [ACC_WIDTH-1:0] result_c;
 logic overflow_c;
 logic signed [PROD_WIDTH-1:0] a_ext,b_ext;
 logic signed [SUM_WIDTH-1:0] max_ext,min_ext;
 assign a_ext={{B_WIDTH{a[A_WIDTH-1]}},a};
 assign b_ext={{A_WIDTH{b[B_WIDTH-1]}},b};
 assign max_ext={{(SUM_WIDTH-ACC_WIDTH){ACC_MAX[ACC_WIDTH-1]}},ACC_MAX};
 assign min_ext={{(SUM_WIDTH-ACC_WIDTH){ACC_MIN[ACC_WIDTH-1]}},ACC_MIN};
 assign full_sum=
   $signed({{(SUM_WIDTH-PROD_WIDTH){product_s1[PROD_WIDTH-1]}},product_s1})
   + addend_s1;
 always_comb begin
   overflow_c=(full_sum>max_ext)||(full_sum<min_ext);
   if (SATURATE && overflow_c)
     result_c=full_sum[SUM_WIDTH-1]?ACC_MIN:ACC_MAX;
   else result_c=full_sum[ACC_WIDTH-1:0];
 end
 always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
     product_s1<='0; addend_s1<='0; valid_s1<=0;
     out_valid<=0; result<='0; overflow<=0;
   end else begin
     valid_s1<=in_valid;
     if(in_valid) begin
       product_s1<=a_ext*b_ext;
       addend_s1<=$signed({{(SUM_WIDTH-ACC_WIDTH){addend[ACC_WIDTH-1]}},addend});
     end
     out_valid<=valid_s1;
     if(valid_s1) begin
       result<=result_c; overflow<=overflow_c;
     end else overflow<=0;
   end
 end
endmodule
