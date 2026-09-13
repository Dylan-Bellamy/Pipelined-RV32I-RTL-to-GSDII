/*
	Instruction Memory Pipeline Register
*/

module memory_write_reg(
	input wire clk,
   	input wire reset,
	
	input wire RegWriteM,
	input wire [1:0] ResultSrcM,

	output reg RegWriteW,
	output reg [1:0] ResultSrcW,

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
			// Data Signals
			ALUResultW <= 32'h0;
			readDataW <= 32'h0;
			pc_plus4W <= 32'h0;
			write_regW <= 5'h0;

			// Control Signals
			RegWriteW <= 1'b0;
			ResultSrcW <= 2'b00;
		end else begin
			// Data Signals
			ALUResultW <= ALUResultM;
			readDataW <= readDataM;
			pc_plus4W <= pc_plus4M;
			write_regW <= write_regM;

			// Control Signals
			RegWriteW <= RegWriteM;
			ResultSrcW <= ResultSrcM;
		end
	end
endmodule