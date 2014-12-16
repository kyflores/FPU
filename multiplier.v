module negate_32(input negate, input[31:0] operand, output[31:0] res);
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

module negate_64(input negate, input[63:0] operand, output[63:0] res);
//multiply by -1 if negate is high.
wire DUMMY1;
wire[63:0] n_op;
wire[63:0] n_result;
genvar t;
generate
for (t = 0; t < 64; t = t + 1) begin: not_arr
    not n(n_op[t],operand[t]);
end
endgenerate
//What a waste of an adder. Lol.
csa64 add_1(n_result, DUMMY1, n_op, 64'b1, 1'b0);
mux2_1_64 negate_mux(operand, n_result, negate, res);

endmodule

module multiplier(input clk, input reset, input[31:0] opA, input[31:0] opB, output[63:0] res, output res_ok);

wire[4:0] ct; //Counter flag
wire[63:0] A_SE; //A sign extended to 64 bits.
wire[63:0] A_SH; //A's lshifted value.
wire[31:0] B_SH; //B's rshifted value.
wire[63:0] add_res; //Add result from Adder
wire[63:0] acc_val; //Accumulator register's value.
wire[63:0] B_add_in; //B input operand (which is actually A if B[0] is high)
wire[31:0] opA_ss; //ss means sign selected
wire[31:0] opB_ss;
wire carryout;
wire outsign;

xor signcheck(outsign,opA[31],opB[31]);
negate_32 nA(opA[31], opA, opA_ss);
negate_32 nB(opB[31], opB, opB_ss);
negate_64 nOut(outsign, acc_val, res);

upcounter counter(clk, reset, ct);
sign_extend_u a_ext(opA_ss, A_SE);
barrel_shifter64 a_lshift(ct, 1'b0, A_SE, A_SH);
barrel_shifter32 b_rshift(ct, 1'b1, opB_ss, B_SH);
reg64 accumulator(clk, add_res, acc_val,reset);
and64 acc_if_true(A_SH,B_SH[0],B_add_in);
//adder64 adder(acc_val, B_add_in, add_res);
csa64 adder(add_res, carryout, acc_val, B_add_in, 1'b0);

//This nor will raise res_ok high when the mulitplication result completes. Result completes prematurely if B has leading 0's.
nor check_completion(res_ok,B_SH[0],B_SH[1],B_SH[2],B_SH[3],B_SH[4],B_SH[5],B_SH[6],B_SH[7],B_SH[8],B_SH[9],B_SH[10],B_SH[11],B_SH[12],B_SH[13],B_SH[14],B_SH[15],B_SH[16],B_SH[17],B_SH[18],B_SH[19],B_SH[20],B_SH[21],B_SH[22],B_SH[23],B_SH[24],B_SH[25],B_SH[26],B_SH[27],B_SH[28],B_SH[29],B_SH[30],B_SH[31]);

//assign res=acc_val;

endmodule

module test_negate();
reg[31:0] op;
wire[31:0] out;
reg negate;
negate_32 lol(negate, op, out);
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
reset=1'b0;opA=32'd15;opB=32'd13; #4000
$display("A=%b, B=%b", opA, opB);
$display("R=%b",res);
reset=1'b1; #100
reset=1'b0;opA=32'b11111111111111111111111111110001;opB=32'd13; #4000
$display("A=%b, B=%b", opA, opB);
$display("R=%b",res);
end

endmodule