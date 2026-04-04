/*
	Instruction Memory Pipeline Register
*/

module memory_write_reg(
	input wire clk,
   input wire reset,
	
	// Inputs from Memory Stage
	input wire [31:0] ALUResultM,
	input wire [31:0] readDataM,
	input wire [31:0] pc_plus4M,
	input wire [4:0] write_regM,
	
	// Outputs from Writeback Stage
	output reg [31:0] ALUResultW,
	output reg [31:0] readDataW,
	output reg [31:0] pc_plus4W,
	output reg [4:0] write_regW
);
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			ALUResultW <= 32'h0;
			readDataW <= 32'h0;
			pc_plus4W <= 32'h0;
			write_regW <= 5'h0;
		end else begin
			ALUResultW <= ALUResultM;
			readDataW <= readDataM;
			pc_plus4W <= pc_plus4M;
			write_regW <= write_regM;
		end
	end
endmodule