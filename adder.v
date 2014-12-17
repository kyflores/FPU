module f_adder(out, carryout, a, b, carryin);
output out, carryout;
input a, b, carryin;
 // Your Code Here
wire axorb;
xor AxorB(axorb,a,b);
xor ABxorC(out,carryin,axorb);

wire aandb;
wire axorbandc;

and AxorBandC(axorbandc,axorb,carryin);
and AandB(aandb,a,b);

or AxorBandCorAandB(carryout,aandb,axorbandc);

endmodule

module workgroup8(output[7:0] out, output carryout, input[7:0] opA, input[7:0] opB, input carryin, output overflow);
//Building block of carry select adder with 8 adders as the unit.
wire[8:0] c_u;
wire[8:0] c_l;
wire overflow_u;
wire overflow_l;
wire[7:0] res_u;
wire[7:0] res_l;

assign c_u[0]=1'b0;
assign c_l[0]=1'b1;

genvar t;
generate
for (t = 0; t < 8; t = t + 1) begin: group_gen
    f_adder t_a(res_u[t], c_u[t+1], opA[t], opB[t], c_u[t]);
    f_adder b_a(res_l[t], c_l[t+1], opA[t], opB[t], c_l[t]);
    mux2_1_1 csel(res_u[t],res_l[t],carryin,out[t]);
    
end
endgenerate
mux2_1_1 cout_mux(c_u[8],c_l[8],carryin,carryout);

xor ovfu(overflow_u,c_u[8],c_u[7]);
xor ovfl(overflow_l,c_l[8],c_l[7]);
mux2_1_1 ovf_mux(overflow_u,overflow_l,carryin,overflow);

endmodule

module csa64(output[63:0] out, output carryout, input[63:0] opA, input[63:0] opB, input carryin);
wire[8:0] carry;
wire[7:0] ovf;

//Carryin to this module is provided for possible use in subtraction. Always hardware to 1'b0 when mult.

//Yes, this looks like something to be done with a generate.
//I wanted to use genvar * 8 as arguments for indexing operands but
//apparently in place multiplication of indicies is not accepted.
workgroup8 group0(out[7:0], carry[1], opA[7:0], opB[7:0], carry[0], ovf[0]);
workgroup8 group1(out[15:8], carry[2], opA[15:8], opB[15:8], carry[1], ovf[1]);
workgroup8 group2(out[23:16], carry[3], opA[23:16], opB[23:16], carry[2], ovf[2]);
workgroup8 group3(out[31:24], carry[4], opA[31:24], opB[31:24], carry[3], ovf[3]);
workgroup8 group4(out[39:32], carry[5], opA[39:32], opB[39:32], carry[4], ovf[4]);
workgroup8 group5(out[47:40], carry[6], opA[47:40], opB[47:40], carry[5], ovf[5]);
workgroup8 group6(out[55:48], carry[7], opA[55:48], opB[55:48], carry[6], ovf[6]);
workgroup8 group7(out[63:56], carry[8], opA[63:56], opB[63:56], carry[7], ovf[7]);


assign carry[0]=carryin;
assign carryout=carry[8];
endmodule

module csa24(output[23:0] out, output carryout, output overflow, input[23:0] opA, input[23:0] opB, input carryin);
wire[3:0] carry;
wire[2:0] ovf;
workgroup8 group0(out[7:0], carry[1], opA[7:0], opB[7:0], carry[0], ovf[0]);
workgroup8 group1(out[15:8], carry[2], opA[15:8], opB[15:8], carry[1], ovf[1]);
workgroup8 group2(out[23:16], carry[3], opA[23:16], opB[23:16], carry[2], ovf[2]);
assign carry[0]=carryin;
assign carryout=carry[3];
assign overflow=ovf[2];
endmodule

module csa32(output[31:0] out, output carryout, input[31:0] opA, input[31:0] opB, input carryin, output overflow);
wire[4:0] carry;
wire[3:0] ovf;
//32 bits version of the abpve. Still in groups of 8 because I don't want to write another workgroup module.
workgroup8 group0(out[7:0], carry[1], opA[7:0], opB[7:0], carry[0],ovf[0]);
workgroup8 group1(out[15:8], carry[2], opA[15:8], opB[15:8], carry[1],ovf[1]);
workgroup8 group2(out[23:16], carry[3], opA[23:16], opB[23:16], carry[2],ovf[2]);
workgroup8 group3(out[31:24], carry[4], opA[31:24], opB[31:24], carry[3],ovf[3]);

xor ovrf(overflow,carry[3],carry[4]);
assign carry[0]=carryin;
assign carryout=carry[4];
endmodule


module test_adder();
reg[63:0] opA;
reg[63:0] opB;
reg[31:0] opA32;
reg[31:0] opB32;
reg[7:0] opA8;
reg[7:0] opB8;
wire[63:0] out;
wire[7:0] out8;
wire[31:0] out32;
wire carryout;
wire carryout8;
wire carryout32;
wire ovf;
wire ovf8;

csa64 adder64(out, carryout, opA, opB, 1'b0);
csa32 adder32(out32, carryout32, opA32, opB32, 1'b0,ovf);
workgroup8 adder8(out8,carryout8,opA8,opB8,1'b0,ovf8);
initial begin

opA=64'd1947858; opB=64'd213484;
opA8=8'b01111111; opB8=8'b01111111;
opA32=32'hfffffffe; opB32=32'h1; #1000
$display("opA=%d, opB = %d",opA,opB);
$display("Result= %d, carryout = %b",out,carryout);
$display("opA=%b, opB = %b",opA32,opB32);
$display("Result= %b, carryout = %b",out32,carryout32);
$display("EXPECTED: Result= %b",opA32+opB32);
$display("Result= %b, carryout = %b, overflow = %b",out8,carryout8,ovf8);
$display("EXPECTED: Result= %b",opA8+opB8);
end
endmodule
