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
	input wire [6:0] op,
	input wire [2:0] funct3,
	input wire funct7_5,
	
	// Outputs to the Decode Stage (D)
    output reg RegWriteD, 
    output reg MemWriteD,
    output reg BranchD, 
    output reg JumpD,
    output reg ALUSrcD, 
    output reg [1:0] ALUSrcAD,
    output reg [2:0] ImmSrcD,
    output reg [1:0] ResultSrcD,
    output reg [2:0] ALUControlD,
    output reg negD
);
	always @(*) begin
		RegWriteD = 1'b0;
		MemWriteD = 1'b0;
		BranchD   = 1'b0;
		JumpD     = 1'b0;
		ALUSrcD   = 1'b0;
		ALUSrcAD  = 2'b00;
		ImmSrcD   = 3'b000;
		ResultSrcD= 2'b00;
		ALUControlD = 3'b000;
		negD = 1'b0;

		case(op) 
			// Load (I)
			7'b0000011 : begin
				RegWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ImmSrcD = 3'b000;
				ResultSrcD = 2'b01; // Route Mem to Reg
				ALUControlD = 3'b000; // ADD for address calculation
			end
			// Store (S)
			7'b0100011 : begin
				MemWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ImmSrcD = 3'b001;
				ALUControlD = 3'b000; // ADD for address calculation
			end
			// Immediate (I)
			7'b0010011 : begin
				RegWriteD = 1'b1; 
				ALUSrcD = 1'b1;
				ImmSrcD = 3'b000;
				ResultSrcD = 2'b00;
				ALUSrcAD = 2'b00;
				// Decode the immediate ALU operation.
				case(funct3)
					3'h0: ALUControlD = 3'b000; // ADDI
					3'h1: ALUControlD = 3'b001; // SLLI
					3'h2: ALUControlD = 3'b010; // SLTI
					3'h3: ALUControlD = 3'b011; // SLTIU (treated like SLT in this ALU)
					3'h4: ALUControlD = 3'b100; // XORI
					3'h5: begin
						ALUControlD = 3'b101; // SRLI/SRAI
						negD = funct7_5;
					end
					3'h6: ALUControlD = 3'b110; // ORI
					3'h7: ALUControlD = 3'b111; // ANDI
                    default: ALUControlD = 3'b000;
				endcase
			end
			// Arithmetic & Logical (R)
			7'b0110011 : begin
				RegWriteD = 1'b1;   
				ALUSrcD = 1'b0;     
				ResultSrcD = 2'b00; // Route ALU to Reg
				ALUSrcAD = 2'b00;
				case(funct3) 
					3'h0: begin
						ALUControlD = 3'b000; // ADD / SUB
						negD = funct7_5;
					end
                    3'h1: ALUControlD = 3'b001; // SLL
                    3'h2: ALUControlD = 3'b010; // SLT   (Signed)
                    3'h3: ALUControlD = 3'b011; // SLTU  (Unsigned)
                    3'h4: ALUControlD = 3'b100; // XOR
					3'h5: begin
						ALUControlD = 3'b101; // SRL / SRA
						negD = funct7_5;
					end
                    3'h6: ALUControlD = 3'b110; // OR
                    3'h7: ALUControlD = 3'b111; // AND
                    default: ALUControlD = 3'b000;
				endcase
			end
			// LUI
			7'b0110111 : begin
				RegWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ALUSrcAD = 2'b10;
				ImmSrcD = 3'b100;
				ResultSrcD = 2'b00;
				ALUControlD = 3'b000;
			end
			// AUIPC
			7'b0010111 : begin
				RegWriteD = 1'b1;
				ALUSrcD = 1'b1;
				ALUSrcAD = 2'b01;
				ImmSrcD = 3'b100;
				ResultSrcD = 2'b00;
				ALUControlD = 3'b000;
			end
			// Branch (B)
			7'b1100011 : begin
				BranchD = 1'b1;
				ALUSrcD = 1'b0;
				ALUSrcAD = 2'b00;
				ImmSrcD = 3'b010;
				ALUControlD = 3'b000; // compare handled in datapath
			end
			// Jump (J)
			7'b1101111 : begin
				RegWriteD = 1'b1;
				JumpD = 1'b1;
				ImmSrcD = 3'b011;
				ResultSrcD = 2'b10; // Usually routes PC+4
			end
			default: begin
				RegWriteD = 1'b0;
				MemWriteD = 1'b0;
				BranchD   = 1'b0;
				JumpD     = 1'b0;
				ALUSrcD   = 1'b0;
				ALUSrcAD  = 2'b00;
				ImmSrcD   = 3'b000;
				ResultSrcD= 2'b00;
				ALUControlD = 3'b000;
				negD = 1'b0;
			end
		endcase
	end
endmodule