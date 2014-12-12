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

module workgroup8(output[7:0] out, output carryout, input[7:0] opA, input[7:0] opB, input carryin);
//Building block of carry select adder with 8 adders as the unit.
wire[8:0] c_u;
wire[8:0] c_l;
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

endmodule

module csa64(output[63:0] out, output carryout, input[63:0] opA, input[63:0] opB, input carryin);
wire[8:0] carry;
//Carryin to this module is provided for possible use in subtraction. Always hardware to 1'b0 when mult.

//Yes, this looks like something to be done with a generate.
//I wanted to use genvar * 8 as arguments for indexing operands but
//apparently in place multiplication of indicies is not accepted.
workgroup8 group0(out[7:0], carry[1], opA[7:0], opB[7:0], carry[0]);
workgroup8 group1(out[15:8], carry[2], opA[15:8], opB[15:8], carry[1]);
workgroup8 group2(out[23:16], carry[3], opA[23:16], opB[23:16], carry[2]);
workgroup8 group3(out[31:24], carry[4], opA[31:24], opB[31:24], carry[3]);
workgroup8 group4(out[39:32], carry[5], opA[39:32], opB[39:32], carry[4]);
workgroup8 group5(out[47:40], carry[6], opA[47:40], opB[47:40], carry[5]);
workgroup8 group6(out[55:48], carry[7], opA[55:48], opB[55:48], carry[6]);
workgroup8 group7(out[63:56], carry[8], opA[63:56], opB[63:56], carry[7]);


assign carry[0]=carryin;
assign carryout=carry[8];
endmodule

module mux2_1_1(input in0,input in1,input sel,output out);
wire arr[1:0];
assign arr[0]=in0;
assign arr[1]=in1;
assign out=arr[sel];
endmodule

module test_adder();
reg[63:0] opA;
reg[63:0] opB;
wire[63:0] out;
wire carryout;

csa64 adder(out, carryout, opA, opB);
initial begin

opA=63'd1947858; opB=63'd213484; #1000
$display("opA=%d, opB = %d",opA,opB);
$display("Result= %d, carryout = %b",out,carryout);
end

endmodule