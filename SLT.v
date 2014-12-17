module SLT_behavioral(input[31:0] input1, input[31:0] input2, output res);

assign res = (input1 < input2);

endmodule

module inverter_32(input[31:0] operand, output[31:0] res);
genvar i;
generate
for (i=0; i<32; i=i+1) begin: inverter
	not opB_inverter(res[i], operand[i]);
end
endgenerate
endmodule

module SLT_structural(input[31:0] opA, input[31:0] opB, output res);
wire[32:0] notopB;
wire[32:0] sum;
wire carryout, overflow;

inverter_32 opBinv(opB[31:0], notopB[31:0]);

csa32 adder01(sum[31:0], carryout, opA[31:0], notopB[31:0], 1'b1, overflow);

assign res = sum[31];

endmodule

module test_SLT();
reg[31:0] input1;
reg[31:0] input2;
wire res_behavioral;
wire res_structural;

SLT_behavioral SLT_test_behavioral(input1, input2, res_behavioral);
SLT_structural SLT_test_structural(input1, input2, res_structural);

initial begin
input1 = 32'd49; #10
input2 = 32'd67; #10
#800
$display("Input1=%d, Input2=%d, res_behavioral=%b, res_structural=%b", input1, input2, res_behavioral, res_structural);
end

endmodule
