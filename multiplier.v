module negate_v(input negate, input[31:0] operand, output[31:0] res);
//multiply by -1 if negate is high.
wire DUMMY1;
wire DUMMY2;
wire[31:0] n_op;
wire[31:0] n_result;

genvar t;
generate
for (t = 0; t < 32; t = t + 1) begin: not_arr
    not n(n_op[t],operand[t]);
end
endgenerate
//What a waste of an adder. Lol.
csa32 add_1(n_result, DUMMY1, n_op, 32'b1, 1'b0, DUMMY2);
mux2_1_32 negate_mux(operand, n_result, negate, res);

endmodule

module multiplier(input clk, input reset, input[31:0] opA, input[31:0] opB, output[64:0] res, output res_ok);

wire[4:0] ct; //Counter flag
wire[63:0] A_SE; //A sign extended to 64 bits.
wire[63:0] A_SH; //A's lshifted value.
wire[31:0] B_SH; //B's rshifted value.
wire[63:0] add_res; //Add result from Adder
wire[63:0] acc_val; //Accumulator register's value.
wire[63:0] B_add_in; //B input operand (which is actually A if B[0] is high)
wire carryout;

upcounter counter(clk, reset, ct);
barrel_shifter64 a_lshift(ct, 1'b0, A_SE, A_SH);
barrel_shifter32 b_rshift(ct, 1'b1, opB, B_SH);
sign_extend_u a_ext(opA, A_SE);
reg64 accumulator(clk, add_res, acc_val,reset);
and64 acc_if_true(A_SH,B_SH[0],B_add_in);
//adder64 adder(acc_val, B_add_in, add_res);
csa64 adder(add_res, carryout, acc_val, B_add_in, 1'b0);

//This nor will raise res_ok high when the mulitplication result completes. Result completes prematurely if B has leading 0's.
nor check_completion(res_ok,B_SH[0],B_SH[1],B_SH[2],B_SH[3],B_SH[4],B_SH[5],B_SH[6],B_SH[7],B_SH[8],B_SH[9],B_SH[10],B_SH[11],B_SH[12],B_SH[13],B_SH[14],B_SH[15],B_SH[16],B_SH[17],B_SH[18],B_SH[19],B_SH[20],B_SH[21],B_SH[22],B_SH[23],B_SH[24],B_SH[25],B_SH[26],B_SH[27],B_SH[28],B_SH[29],B_SH[30],B_SH[31]);

assign res=acc_val;

endmodule

module test_negate();
reg[31:0] op;
wire[31:0] out;
reg negate;
negate_v lol(negate, op, out);
initial begin
op=32'b1; negate=1'b1; #1000
$display("Negate=%b",out);
$display("Negate=%b",-op);
end
endmodule

module test_mult();
reg clk;
initial clk=0;
always #100 clk=!clk;

reg[31:0] opA;
reg[31:0] opB;
wire[63:0] res;
wire res_ok;
reg reset;

multiplier dut(clk, reset, opA, opB, res, res_ok);

initial begin
reset=1'b0; #100
reset=1'b1; #100
reset=1'b0;opA=32'd78319;opB=32'd54491;
#4000
$display("A=%d, B=%d", opA, opB);
$display("R=%d",res);
end

endmodule