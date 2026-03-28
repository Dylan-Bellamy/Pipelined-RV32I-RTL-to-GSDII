/*
	4 to 1 Multiplexer
	- Selects 1 out of the 4 inputs 
		- a, b, c, d: Four 32-Bit Inputs
		- s: Selector
		- f: 32-Bit Output
*/
module mux4to1(
	input [31:0] a, b, c, d,
	input [1:0] s,
	output reg [31:0] f
);
	always @(*) begin
		case(s)
			2'b00: f = a;
			2'b01: f = b;
			2'b10: f = c;
			2'b11: f = d;
			default: f = 32'bx;
		endcase
	end
endmodule 	
	