/*
	Instruction Decode Pipeline Register
*/

module decode_reg(
	input wire clk,
    input wire reset,
	input wire flush,
	
	input wire RegWriteD,
	input wire MemWriteD,
	input wire BranchD,
	input wire JumpD,
	input wire ALUSrcD,
	input wire [1:0] ALUSrcAD,
	input wire [1:0] ResultSrcD,
	input wire [2:0] ALUControlD,
	input wire negD,
	input wire [2:0] funct3D,

	output reg RegWriteE,
	output reg MemWriteE,
	output reg BranchE,
	output reg JumpE,
	output reg ALUSrcE,
	output reg [1:0] ALUSrcAE,
	output reg [1:0] ResultSrcE,
	output reg [2:0] ALUControlE,
	output reg negE,
	output reg [2:0] funct3E,

	// Inputs from Decode Stage
	input wire [31:0] data1,
	input wire [31:0] data2,
	input wire [31:0] pc_d,
	input wire [31:0] pc_plus4_d,
	input wire [4:0] rs1D,
	input wire [4:0] rs2D,
	input wire [4:0] write_regD,
	input wire [31:0] immExtD,
	
	// Outputs from Execute Stage
	output reg [31:0] data1E,
	output reg [31:0] data2E,
	output reg [31:0] pcE,
	output reg [31:0] pc_plus4E,
	output reg [4:0] rs1E,
	output reg [4:0] rs2E,
	output reg [4:0] write_regE,
	output reg [31:0] immExtE
);
	always @(posedge clk or posedge reset) begin
		if (reset || flush) begin
            // Data Signals
            data1E <= 32'h0;
            data2E <= 32'h0;
            pcE <= 32'h0;
            pc_plus4E <= 32'h0;
            rs1E <= 5'h0;
            rs2E <= 5'h0;
            write_regE <= 5'h0;
            immExtE <= 32'h0;
    
            // Control Signals
            RegWriteE <= 1'b0;
            MemWriteE <= 1'b0;
            BranchE <= 1'b0;
            JumpE <= 1'b0;
            ALUSrcE <= 1'b0;
			ALUSrcAE <= 2'b00;
            ALUControlE <= 3'b000;
            ResultSrcE <= 2'b00;
		    negE <= 1'b0;
			funct3E <= 3'b000;

		end else begin
			// Data Signals
			data1E <= data1;
			data2E <= data2;
			pcE <= pc_d;
			pc_plus4E <= pc_plus4_d;
			rs1E <= rs1D;
			rs2E <= rs2D;
			write_regE <= write_regD;
			immExtE <= immExtD;

			// Control Signals
			RegWriteE <= RegWriteD;
			MemWriteE <= MemWriteD;
			BranchE <= BranchD;
			JumpE <= JumpD;
			ALUSrcE <= ALUSrcD;
			ALUSrcAE <= ALUSrcAD;
			ALUControlE <= ALUControlD;
			ResultSrcE <= ResultSrcD;
			negE <= negD;
			funct3E <= funct3D;
		end
	end
endmodule