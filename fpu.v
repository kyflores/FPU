module fpu(input[31:0] opA, input[31:0] opB, input[1:0] opcode, input clk, input reset, output ok_exp_flag, output overflow_flag, output[55:0] result);
wire carryout;
wire[1:0] flags_add, flags_sub, flags_mult, flags;
wire[31:0] not_opB_val, opB_ext;
wire[31:0] tmp_sub, tmp_add;
wire[55:0] add_val, sub_val, mult_val;

sign_extend_24_to_32 ext3(opB[23:0], opB_ext[31:0]);
inverter_32 inv_opB(opB_ext[31:0], not_opB_val[31:0]);
complete_add sub1(opA, {opB[31:24],not_opB_val[23:0]}, 1'b1, tmp_sub[31:0], carryout, flags_sub[0]);
sign_extend_32_to_56 ext1(tmp_sub[31:0], sub_val[55:0]);

complete_add adder1(opA, opB, 1'b0, tmp_add[31:0], carryout, flags_add[0]);
sign_extend_32_to_56 ext2(tmp_add[31:0], add_val[55:0]);

complete_multiplier mult1(clk, opA, opB, reset, flags_mult[1], mult_val);

assign flags_sub[1] = 1'b0;
assign flags_add[1] = 1'b0;
assign flags_mult[0] = 1'b0;

mux3_1_56 mux1(add_val, sub_val, mult_val, opcode, result);
mux3_1_2 mux2(flags_add, flags_sub, flags_mult, opcode, flags);
assign overflow_flag = flags[0];
assign ok_exp_flag = flags[1];
endmodule

module test_fpu();

reg[31:0] opA;
reg[31:0] opB;
reg[1:0] opcode;
reg clk;
initial clk=0;
always #100 clk=!clk;
reg reset;
wire exp_flag;
wire ovf_flag;
wire[55:0] result;

fpu final_fpu(opA, opB, opcode, clk, reset, exp_flag, ovf_flag, result);

initial begin
opA=32'h04000004;opB=32'h020000ff;opcode=2'b0;
#200
$display("A=%h, B=%h, opcode=%b", opA, opB, opcode);
$display("result=%h, exp_flag=%b, overflow=%b", result, exp_flag, ovf_flag);
opA=32'h04000004;opB=32'h02ffffff;opcode=2'b0;
#200
$display("A=%h, B=%h, opcode=%b", opA, opB, opcode);
$display("result=%h, exp_flag=%b, overflow=%b", result, exp_flag, ovf_flag);

reset=1'b0; #100
reset=1'b1; #100
reset=1'b0;opcode=2'b10;opA=32'b00000001000000000000000000000001;opB=32'b00000001000000000000000000000001; #10000
$display("A=%h, B=%h, opcode=%b", opA, opB, opcode);
$display("result=%h, exp_flag=%b, overflow=%b", result, exp_flag, ovf_flag);
reset=1'b1; #1000
reset=1'b0;opcode=2'b10;opA=32'b01000001000000000000000000000001;opB=32'b01111111111111111111111111111110; #10000
$display("A=%h, B=%h, opcode=%b", opA, opB, opcode);
$display("result=%h, exp_flag=%b, overflow=%b", result, exp_flag, ovf_flag);
end

endmodule
