module multiplier(input clk, input reset, input[31:0] opA, input[31:0] opB, output[64:0] res);

wire[4:0] ct;
wire[63:0] A_SE;
wire[63:0] A_SH;
wire[31:0] B_SH;
wire[63:0] add_res;
wire[63:0] acc_val;
wire[63:0] B_add_in;

upcounter counter(clk, reset, ct);
barrel_shifter64 a_lshift(ct, 1'b0, A_SE, A_SH);
barrel_shifter32 b_rshift(ct, 1'b1, opB, B_SH);
sign_extend_u a_ext(opA, A_SE);
reg64 accumulator(clk, add_res, acc_val,reset);
and64 acc_if_true(A_SH,B_SH[0],B_add_in);
adder64 adder(acc_val, B_add_in, add_res);

assign res=acc_val;

endmodule

module test_mult();
reg clk;
initial clk=0;
always #100 clk=!clk;

reg[31:0] opA;
reg[31:0] opB;
wire[64:0] res;
reg reset;

multiplier dut(clk, reset, opA, opB, res);

initial begin
reset=1'b0; #1000
reset=1'b1; #1000
reset=1'b0;opA=32'd5;opB=32'd10;
#1000
$display("%b",res);
end

endmodule