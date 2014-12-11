module barrel_shifter32(input[4:0] shamt, input dir, input[31:0] dataIn, output[31:0] dataOut);
//For shifting A and B operands, one module that can do left or right!
wire[31:0] tmp_shift[1:0];

assign tmp_shift[0]=dataIn<<shamt;
assign tmp_shift[1]=dataIn>>shamt;
assign dataOut=tmp_shift[dir];
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module barrel_shifter64(input[4:0] shamt, input dir, input[63:0] dataIn, output[63:0] dataOut);
//For shifting A, needs to extend.
wire[63:0] tmp_shift[1:0];

assign tmp_shift[0]=dataIn<<shamt;
assign tmp_shift[1]=dataIn<<shamt;
assign dataOut=tmp_shift[dir];

endmodule
/////////////////////////////////////////////////////////////////////////////////////
module sign_extend_u(input[31:0] operand, output[63:0] out);
//For sign extending 32bit into 64bits for the adder/accumulator. Unsigned.
assign out={32'b0,operand};
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module sign_extend_s(input[31:0] operand, output[63:0] out);
//For sign extending signed numbers.
wire[63:0] ext[1:0];
assign ext[0]={32'b0,operand};
assign ext[1]={32'b1,operand};
assign out=ext[operand[31]];
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module upcounter(input clk, input reset, output reg[4:0] cval);
//For keeping track of the shift amount, and what cycle we're on.
reg[4:0] count;
initial count=5'b0;
always @(posedge clk) begin
    if (count<'d31)
        count=count+5'b1;

    if (reset)
        count=5'b0;
        
    cval=count;
end
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module adder64(input[63:0] opA, input [63:0] opB, output[63:0] res);
//Accumlator of shifted multiplies.
assign res=opA+opB;

endmodule
/////////////////////////////////////////////////////////////////////////////////////
module reg64(input clk, input[63:0] dataIn, output reg[63:0] dataOut, input reset);
//Holds the answer for the multiplication
    initial dataOut=63'b0;
    always @(posedge clk) begin
        dataOut=dataIn;
        if (reset)
            dataOut=63'b0;
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////////
module and64(input[63:0] dataIn, input compare, output[63:0] dataOut);
    genvar i;
    generate
    for (i = 0; i < 64; i = i + 1) begin: and_gen
        and abit(dataOut[i],compare,dataIn[i]);
    end
    endgenerate
endmodule