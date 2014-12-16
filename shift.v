/*module shift_exponent(input[31:0] opA, input[31:0] opB, output[31:0] opA_shifted, output[31:0] opB_shifted);

reg diff[7:0];

opB_shifted = 

// exponents are MSB-1:MSB-7
always @(*) begin
if (opA[31:24] > opB[31:24]) begin
	opB_shifted[31:24] = opA[31:24];
	diff = opA[31:24] - opB[31:24];
	opB_shifted[23:0] = opB[23:0] << diff;
	opA_shifted[31:0] = opA[31:0];
end
else if (opA[31:24] < opB[31:24]) begin
	opA_shifted[31:24] = opB[31:24];
	diff[7:0] = opA[31:24] - opA[31:24];
	opA_shifted[23:0] = opA[23:0] << diff;
	opB_shifted[31:0] = opB[31:0];
end
end

endmodule*/

module bitshift(input[23:0] opA, input[7:0] shift, output[23:0] shifted_opA);

assign shifted_opA = (opA << shift);

endmodule

module complete_add(input[31:0] opA, input[31:0] opB, output[31:0] res);

wire[23:0] valA = opA[23:0];
wire[23:0] valB = opB[23:0];

wire[23:0] valSum = valA + valB;

wire[7:0] diff1 = valA - valB;
wire[7:0] diff2 = valB - valA;

wire[23:0] valB_bitshift;
wire[23:0] valA_bitshift;

bitshift bitshift1(valB[23:0], diff1[7:0], valB_bitshift[23:0]);
bitshift bitshift2(valA[23:0], diff2[7:0], valA_bitshift[23:0]);

wire[23:0] valSum1 = valA + valB_bitshift;
wire[23:0] valSum2 = valB + valA_bitshift;

wire[31:0] res1 = {opA[31:24],valSum1};
wire[31:0] res2 = {opB[31:24],valSum2};

wire[31:0] choice1;
wire[31:0] choice2;

wire compare = (opA[31:24] > opB[31:24]);
wire notcompare;

not compareinv(notcompare, compare);

genvar i;
generate

for (i = 0; i < 32; i = i+1) begin: comparison
	and and1(choice1[i], res1[i], compare);
	and and2(choice2[i], res2[i], notcompare);
	or or1(res[i], choice1[i], choice2[i]);
end

endgenerate

endmodule

module test_complete_add();

reg[31:0] opA;
reg[31:0] opB;
wire[31:0] sum;

complete_add adder01(opA, opB, sum);
bitshift shifter01(opA[23:0], shift, shifted);

initial begin
opA=32'h04000021;opB=32'h02000019;
#4000
$display("A=%d, B=%d", opA[23:0], opB[23:0]);
$display("sum=%d", sum);
end

endmodule
