/*
	Instruction Execute Pipeline Register
*/

module execute_reg(
	input wire clk,
   	input wire reset,

	input wire RegWriteE,
	input wire MemWriteE,
	input wire [1:0] ResultSrcE,

	output reg RegWriteM,
	output reg MemWriteM,
	output reg [1:0] ResultSrcM,

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
			// Data Signals
			ALUResultM <= 32'h0;
			writeDataM <= 32'h0;
			pc_plus4M <= 32'h0;
			write_regM <= 5'h0;

			// Control Signals
			RegWriteM <= 1'b0;
			MemWriteM <= 1'b0;
			ResultSrcM <= 2'b00;
		end else begin
			// Data Signals
			ALUResultM <= ALUResultE;
			writeDataM <= writeDataE;
			pc_plus4M <= pc_plus4E;
			write_regM <= write_regE;

			// Control Signals
			RegWriteM <= RegWriteE;
			MemWriteM <= MemWriteE;
			ResultSrcM <= ResultSrcE;
		end
	end
endmodule