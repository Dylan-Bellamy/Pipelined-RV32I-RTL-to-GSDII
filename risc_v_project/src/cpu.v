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
	wire RegWriteD; 
    wire MemWriteD;
    wire BranchD;
    wire JumpD;
    wire ALUSrcD; 
	wire [1:0] ALUSrcAD;
	wire [2:0] ImmSrcD;
    wire [1:0] ResultSrcD;
    wire [2:0] ALUControlD;

	wire negD;
	wire PCSrc;
	wire RegWriteW; 
	wire MemWrite;
	
	// Control -> Hazard
	wire RegWriteM;
	wire [1:0] ResultSrcEHaz;
	
	// Datapath -> Control
	wire [6:0] op;
	wire [2:0] funct3;
	wire funct7_5;
	wire Zero;
	
	// Datapath -> Hazard
	wire [4:0] rs1E;
    wire [4:0] rs2E;
    wire [4:0] rdE;
    wire [4:0] write_regM;
    wire [4:0] write_regW;
    wire [4:0] rs1D;
    wire [4:0] rs2D;

	// Hazard -> Datapath
	wire [1:0] forwardAE;
	wire [1:0] forwardBE;
	wire stallF, stallD;
	wire flushD, flushE;
	
	control control_unit ( .op(op), .funct3(funct3), 
							  .funct7_5(funct7_5),
						      .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .BranchD(BranchD), .JumpD(JumpD),
							  .ALUSrcD(ALUSrcD), .ALUSrcAD(ALUSrcAD), .ImmSrcD(ImmSrcD), .ResultSrcD(ResultSrcD), .ALUControlD(ALUControlD), .negD(negD) );
									
	// Initialize Datapath
	datapath data_pipeline ( .Clk(clk), .reset(reset), .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), 
                            .BranchD(BranchD), .JumpD(JumpD), .ALUSrcD(ALUSrcD), .negD(negD), 
                            .ALUSrcAD(ALUSrcAD), .ImmSrcD(ImmSrcD), .ResultSrcD(ResultSrcD), .ALUControlD(ALUControlD),
                            .RegWriteMout(RegWriteM), .RegWriteWout(RegWriteW), .ResultSrcEHaz(ResultSrcEHaz), .PCSrcEout(PCSrc),
                            .op(op), .funct3(funct3), .funct7_5(funct7_5), .ZeroE(Zero), .forwardAE(forwardAE), // <-- Added .funct7_5(funct7_5) here
                            .forwardBE(forwardBE), .stallF(stallF), .stallD(stallD), .flushD(flushD), .flushE(flushE),
                            .rs1E(rs1E), .rs2E(rs2E), .write_regEout(rdE), .write_regMout(write_regM), .write_regWout(write_regW),
                            .rs1D(rs1D), .rs2D(rs2D), .pc_out1(pc), .instr_out1(instr), .result(reg_write_data), 
                            .write_to_reg(reg_write_addr), .ALUResult(mem_write_addr) , .writeData(mem_write_data), .MemWrite(MemWrite) 
);
						
	// Initialize Hazard Unit
	hazard hazard_unit ( .rs1E(rs1E), .rs2E(rs2E), .RegWriteM(RegWriteM), .write_regM(write_regM), .RegWriteW(RegWriteW), 
	                                  .write_regW(write_regW), .forwardAE(forwardAE), .forwardBE(forwardBE), .rs1D(rs1D), 
	                                  .rs2D(rs2D), .rdE(rdE), .ResultSrcE(ResultSrcEHaz), .stallF(stallF), .stallD(stallD), 
	                                  .PCSrcE(PCSrc), .flushD(flushD), .flushE(flushE) );					
										
	assign reg_write_en = RegWriteW;
	assign mem_write_en = MemWrite;
endmodule