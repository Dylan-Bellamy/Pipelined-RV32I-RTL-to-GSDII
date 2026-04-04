/*
	RISC-V CPU
*/
module cpu(
	input wire clk, 
	input wire reset,
	
	// Verification Outputs
	output wire [31:0] pc,
   output wire [31:0] instr,
   output wire reg_write_en,
	output wire mem_write_en,
   output wire [4:0] reg_write_addr,
   output wire [31:0] reg_write_data,
   output wire [31:0] mem_write_addr,
   output wire [31:0] mem_write_data
);
	// Control -> Datapath 
	wire PCSrc;
	wire ALUSrc; 
	wire RegWrite; 
	wire MemWrite;
	wire [1:0] ImmSrc;
	wire [1:0] ResultSrc;
	wire [2:0] ALUControl;
	
	// Datapath -> Control
	wire [6:0] op;
	wire [2:0] funct3;
	wire funct7_5;
	wire Zero;
	
	// Initialize Control Unit
	control control_unit ( .clk(clk), .op(op), .funct3(funct3), .funct7_5(funct7_5), .ZeroE(Zero),
									.PCSrcE(PCSrc), .RegWriteW(RegWrite), .MemWriteM(MemWrite), .ALUSrcE(ALUSrc),
									.ImmSrcD(ImmSrc), .ResultSrcW(ResultSrc), .ALUControlE(ALUControl) );
									
	// Initialize Datapath
	datapath data_pipeline ( .Clk(clk), .reset(reset), .PCSrcE(PCSrc), .RegWriteW(RegWrite), .MemWriteM(MemWrite), 
										.ALUSrcE(ALUSrc), .ImmSrcD(ImmSrc), .ResultSrcW(ResultSrc), .ALUControlE(ALUControl),
										.op(op), .funct3(funct3), .funct7_5(funct7_5), .ZeroE(Zero), .pc_out1(pc),
										.instr_out1(instr), .result(reg_write_data), .write_to_reg(reg_write_addr), 
										.ALUResult(mem_write_addr) , .writeData(mem_write_data) );
										
	assign reg_write_en = RegWrite;
	assign mem_write_en = MemWrite;
endmodule