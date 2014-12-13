module SLT_behavioral(input clk, input[31:0] input1, input[31:0] input2, output is_true);

reg out;

always @(posedge clk) begin
if (input1 < input2) begin
	out = 1;
end
end

assign is_true = out;

endmodule

//module SLT_structural(input clk, input[31:0] input1, input[31:0] input2, output is_true);

//endmodule

module test_SLT();
reg clk;
initial clk = 0;
always #100 clk = !clk;

reg[31:0] input1;
reg[31:0] input2;
wire is_true;

SLT_behavioral SLT_test(clk, input1, input2, is_true);

initial begin
input1 = 32'd49; #10
input2 = 32'd67; #10
#200
$display("Input1=%d, Input2=%d, is_true=%b", input1, input2, is_true);
end

endmodule
