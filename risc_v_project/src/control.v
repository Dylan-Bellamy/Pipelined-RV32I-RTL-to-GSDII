/*
    Control Unit
    - Decodes instructions into control signals to manage the flow of data throught the datapath
    - Inputs and Outputs
        - Funct7: Bits of funct7 found in the instruction 
        - Funct3: Bits of funct3 found in the instruction 
        - Opcode: Operation code found in the instruction
        - ALUControlD: ALU's operation code
        - RegWriteW: Allows register file to write data into a Memory
        - MemWriteM: Allows ALU to write to Memory register
*/
module control(
	input wire clk,
	input wire [6:0] op,
	input wire [2:0] funct3,
	input wire funct7_5,
	input wire ZeroE,
	output reg PCSrcE,
	output reg RegWriteW, 
	output reg MemWriteM,
	output reg ALUSrcE, 
	output reg [1:0] ImmSrcD,
	output reg [1:0] ResultSrcW,
	output reg [2:0] ALUControlE
);
	reg RegWriteD, RegWriteE, RegWriteM;
	reg MemWriteD, MemWriteE;
	reg BranchD, BranchE;
	reg JumpD, JumpE;
	reg ALUSrcD;
	reg [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
	reg [2:0] ALUControlD;
	
	always @(*) begin
		RegWriteD = 1'b0;
		MemWriteD = 1'b0;
		BranchD   = 1'b0;
		JumpD     = 1'b0;
		ALUSrcD   = 1'b0;
		ImmSrcD   = 2'b00;
		ResultSrcD= 2'b00;
		ALUControlD = 3'b000;

		case(op) 
			// Load (I)
			7'b0000011 : begin
				RegWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ImmSrcD = 2'b00;
				ResultSrcD = 2'b01; // Route Mem to Reg
				ALUControlD = 3'b000; // ADD for address calculation
			end
			// Store (S)
			7'b0100011 : begin
				MemWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ImmSrcD = 2'b01;
				ALUControlD = 3'b000; // ADD for address calculation
			end
			// Immediate (I)
			7'b0010011 : begin
				RegWriteD = 1'b1; 
				ALUSrcD = 1'b1;
				ImmSrcD = 2'b00;
				ResultSrcD = 2'b00;
				// Basic ALU decoding for I-type (simplified)
				case(funct3)
					3'h0: ALUControlD = 3'b000; // ADDI
					3'h6: ALUControlD = 3'b010; // ORI
					3'h7: ALUControlD = 3'b011; // ANDI
					default: ALUControlD = 3'b000;
				endcase
			end
			// Arithmetic & Logical (R)
			7'b0110011 : begin
				RegWriteD = 1'b1;   
				ALUSrcD = 1'b0;     
				ResultSrcD = 2'b00; // Route ALU to Reg
				case(funct3) 
					3'h0: ALUControlD = (funct7_5 == 0) ? 3'b000 : 3'b001; // ADD/SUB
					3'h6: ALUControlD = 3'b010; // OR
					3'h7: ALUControlD = 3'b011; // AND
					3'h1: ALUControlD = 3'b100; // SLL 
					3'h5: ALUControlD = 3'b101; // SLR 
					3'h4: ALUControlD = 3'b110; // XOR
					3'h2: ALUControlD = 3'b111; // SLT 
					default: ALUControlD = (funct7_5 == 0) ? 3'b000 : 3'b001; // ADD/SUB
				endcase
			end
			// Branch (B)
			7'b1100011 : begin
				BranchD = 1'b1;
				ALUSrcD = 1'b0;     
				ImmSrcD = 2'b10;
				ALUControlD = 3'b001; // SUB for comparison
			end
			// Jump (J)
			7'b1101111 : begin
				RegWriteD = 1'b1;
				JumpD = 1'b1;
				ImmSrcD = 2'b11;
				ResultSrcD = 2'b10; // Usually routes PC+4
			end
			default: begin
				RegWriteD = 1'b0;
				MemWriteD = 1'b0;
				BranchD   = 1'b0;
				JumpD     = 1'b0;
				ALUSrcD   = 1'b0;
				ImmSrcD   = 2'b00;
				ResultSrcD= 2'b00;
				ALUControlD = 3'b000;
			end
		endcase
	end
	
	always @(*) PCSrcE = JumpE || (BranchE && ZeroE);
	
	always @(posedge clk) begin
		// ID/EX Registers
		RegWriteE <= RegWriteD;
		MemWriteE <= MemWriteD;
		BranchE <= BranchD;
		JumpE <= JumpD;
		ALUSrcE <= ALUSrcD;
		ALUControlE <= ALUControlD;
		ResultSrcE <= ResultSrcD;
		
		// EX/MEM Registers
		RegWriteM <= RegWriteE;
		MemWriteM <= MemWriteE;
		ResultSrcM <= ResultSrcE;
		
		// MEM/WB Registers
		RegWriteW <= RegWriteM;
		ResultSrcW <= ResultSrcM;
	end
endmodule