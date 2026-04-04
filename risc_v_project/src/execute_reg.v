/*
	Instruction Execute Pipeline Register
*/

module execute_reg(
	input wire clk,
   input wire reset,
	
	// Inputs from Execute Stage
	input wire [31:0] ALUResultE,
	input wire [31:0] writeDataE,
	input wire [31:0] pc_plus4E,
	input wire [4:0] write_regE,
	
	// Outputs from Memory Stage
	output reg [31:0] ALUResultM,
	output reg [31:0] writeDataM,
	output reg [31:0] pc_plus4M,
	output reg [4:0] write_regM
);
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			ALUResultM <= 32'h0;
			writeDataM <= 32'h0;
			pc_plus4M <= 32'h0;
			write_regM <= 5'h0;
		end else begin
			ALUResultM <= ALUResultE;
			writeDataM <= writeDataE;
			pc_plus4M <= pc_plus4E;
			write_regM <= write_regE;
		end
	end
endmodule