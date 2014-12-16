module bitshift(input[23:0] opA, input[7:0] shift, output[23:0] shifted_opA);

assign shifted_opA = (opA >> shift);

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

module complete_add(input[31:0] opA, input[31:0] opB, output[31:0] res);

wire compare = (opA[31:24] < opB[31:24]);
wire notcompare;
wire[31:0] larger;
wire[31:0] smaller;
wire[7:0] shifter;
wire[23:0] shifted_smaller;
wire[23:0] sum_val;

not compareinv(notcompare, compare);
mux2_32_bit larger_mux(opA[31:0], opB[31:0], compare, larger[31:0]);
mux2_32_bit smaller_mux(opA[31:0], opB[31:0], notcompare, smaller[31:0]);
assign shifter = (larger[31:24] - smaller[31:24]);
bitshift shift_smaller(smaller[23:0], shifter[7:0], shifted_smaller[23:0]);
assign sum_val[23:0] = (larger[23:0] + shifted_smaller[23:0]);
assign res = {larger[31:24],sum_val};

endmodule

module test_complete_add();

reg[31:0] opA;
reg[31:0] opB;
wire[31:0] sum;

complete_add adder01(opA, opB, sum);

initial begin
opA=32'h04000004;opB=32'h020000ff;
#4000
$display("A=%h, B=%h", opA, opB);
$display("sum=%h", sum);
end

endmodule
