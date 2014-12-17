module bitshift_right(input[23:0] opA, input[7:0] shift, output[23:0] shifted_opA);

assign shifted_opA = ($signed(opA) >>> shift);

endmodule

module bitshift_left(input[23:0] opA, input[7:0] shift, output[23:0] shifted_opA);
// This needs to sign extend so that subtraction and addition with negative numbers works
assign shifted_opA = (opA << shift);
endmodule

module mux2_32_bit(input[31:0] val1, input[31:0] val2, input select, output[31:0] res);
wire[31:0] choice1;
wire[31:0] choice2;
wire notselect;

not selectinv(notselect, select);

genvar i;
generate
for (i=0; i<32; i=i+1) begin: selector
	and andchoice1(choice1[i], notselect, val1[i]);
	and andchoice2(choice2[i], select, val2[i]);
	or getresult(res[i], choice1[i], choice2[i]);
end
endgenerate
endmodule

module sign_extend_8_to_32(input[7:0] operand, output[31:0] res);
wire[31:0] ext[1:0];
assign ext[0] = {24'h0,operand};
assign ext[1] = {24'hffffff,operand};
assign res = ext[operand[7]];
endmodule

module sign_extend_24_to_32(input[23:0] operand, output[31:0] res);
wire[31:0] ext[1:0];
assign ext[0] = {8'h00,operand};
assign ext[1] = {8'hff,operand};
assign res = ext[operand[23]];
endmodule

module complete_add(input[31:0] opA, input[31:0] opB, output[31:0] res);

wire compare;
wire notcompare;
wire[31:0] expA_ext, expB_ext;
wire[31:0] larger;
wire[31:0] smaller;
wire[31:0] larger_exp_ext;
wire[31:0] smaller_exp_ext;
wire[31:0] smaller_exp_ext_neg;
wire[31:0] shifter_ext;
wire[7:0] shifter;
wire[23:0] shifted_smaller;
wire[23:0] sum_val;
wire carryout, overflow;

sign_extend_8_to_32 ext_expA(opA[31:24], expA_ext[31:0]);
sign_extend_8_to_32 ext_expB(opB[31:24], expB_ext[31:0]);

// Use SLT to compare
// assign compare = (opA[31:24] < opB[31:24]);
SLT_structural SLT01(expA_ext[31:0], expB_ext[31:0], compare);

not compareinv(notcompare, compare);

sign_extend_8_to_32 ext_smaller(smaller[31:24], smaller_exp_ext[31:0]);
sign_extend_8_to_32 ext_larger(larger[31:24], larger_exp_ext[31:0]);

mux2_32_bit larger_mux(opA[31:0], opB[31:0], compare, larger[31:0]);
mux2_32_bit smaller_mux(opA[31:0], opB[31:0], notcompare, smaller[31:0]);

// To use structural, 2's complement smaller, sign extend larger and smaller to 32-bits, use CS adder
// assign shifter = (larger[31:24] - smaller[31:24]);
inverter_32 opB_inverter(smaller_exp_ext[31:0], smaller_exp_ext_neg[31:0]);
csa32 complement_adder(shifter_ext[31:0], carryout, larger_exp_ext[31:0], smaller_exp_ext_neg[31:0], 1'b1, overflow);
assign shifter = shifter_ext[7:0];

bitshift_right shift_smaller(smaller[23:0], shifter[7:0], shifted_smaller[23:0]);

// To use structural, sign extend larger and shifted_smaller to 32-bits, use CS adder
// assign sum_val[23:0] = (larger[23:0] + shifted_smaller[23:0]);
csa24 val_adder(sum_val[23:0], carryout, larger[23:0], shifted_smaller[23:0], 1'b0);

assign res = {larger[31:24],sum_val[23:0]};

endmodule

module test_complete_add();

reg[31:0] opA;
reg[31:0] opB;
wire[31:0] sum;

reg[23:0] op;
reg[7:0] shifter;
wire[23:0] shifted;

complete_add adder01(opA, opB, sum);
bitshift_right right01(op, shifter, shifted);

initial begin
opA=32'h04000004;opB=32'h020000ff;
#200
$display("A=%h, B=%h", opA, opB);
$display("sum=%h", sum);

opA=32'h04000004;opB=32'h02ffffff;
#200
$display("A=%h, B=%h", opA, opB);
$display("sum=%h", sum);

op=24'hfffff0ff;shifter=7'd4;
#200
$display("opA=%h, shifter=%d", op, shifter);
$display("shifted=%h", shifted);
end

endmodule
