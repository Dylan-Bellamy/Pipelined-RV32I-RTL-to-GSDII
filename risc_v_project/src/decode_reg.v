/*
	Instruction Decode Pipeline Register
*/

module decode_reg(
	input wire clk,
   input wire reset,
	
	// Inputs from Decode Stage
	input wire [31:0] data1,
	input wire [31:0] data2,
	input wire [31:0] pc_d,
	input wire [31:0] pc_plus4_d,
	input wire [4:0] write_regD,
	input wire [31:0] immExtD,
	
	// Outputs from Execute Stage
	output reg [31:0] data1E,
	output reg [31:0] data2E,
	output reg [31:0] pcE,
	output reg [31:0] pc_plus4E,
	output reg [4:0] write_regE,
	output reg [31:0] immExtE
);
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			data1E <= 32'h0;
			data2E <= 32'h0;
			pcE <= 32'h0;
			pc_plus4E <= 32'h0;
			write_regE <= 5'h0;
			immExtE <= 32'h0;
		end else begin
			data1E <= data1;
			data2E <= data2;
			pcE <= pc_d;
			pc_plus4E <= pc_plus4_d;
			write_regE <= write_regD;
			immExtE <= immExtD;
		end
	end
endmodule