module SLT_behavioral(input[31:0] input1, input[31:0] input2, output res);

assign res = (input1 < input2);

endmodule

module SLT_structural(input[31:0] input1, input[31:0] input2, output res);

wire sub_result[31:0];
wire carryout;
wire carryin;
wire tempXOR[31:0];

assign carryin = 0;

genvar i;
generate
for (i = 0; i < 32; i = i + 1) begin: bitslice
	xor XOR2(tempXOR[i], input2[i], 1'b1);
	f_adder adder2(sub_result[i], carryout, input1[i], tempXOR[i], carryin);
	assign carryin = carryout;
end
endgenerate

assign res = sub_result[31];

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
