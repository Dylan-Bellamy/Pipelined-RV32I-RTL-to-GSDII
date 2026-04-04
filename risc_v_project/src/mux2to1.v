/*
	2 to 1 Multiplexer
	- Selects 1 out of the 2 inputs 
		- a, b: Two 32-Bit Inputs
		- s: Selector
		- f: 32-Bit Output
*/
module mux2to1(
	input [31:0] a, b,
	input s,
	output reg [31:0] f
);
	always @(*) begin
		case(s)
			1'b0: f = a;
			1'b1: f = b;
			default: f = 32'b0;
		endcase
	end
endmodule 	
	