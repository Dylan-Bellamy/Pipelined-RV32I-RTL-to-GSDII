/*
	Datapath (IF/ID/EX/MEM/WB)
*/
module datapath(
	input wire Clk,
	input wire reset,
	
	input wire RegWriteD, 
	input wire MemWriteD,
	input wire BranchD, 
	input wire JumpD,
	input wire ALUSrcD, 
	input wire negD,
	input wire [1:0] ALUSrcAD,
	input wire [2:0] ImmSrcD,
	input wire [1:0] ResultSrcD,
	input wire [2:0] ALUControlD,
	
	output reg RegWriteMout,
	output reg RegWriteWout,
	output reg [1:0] ResultSrcEHaz,
	output wire PCSrcEout,

	output reg [6:0] op,
	output reg [2:0] funct3,
	output reg funct7_5,
	output reg ZeroE,

	// Signals for Hazard Unit
	input wire [1:0] forwardAE,
	input wire [1:0] forwardBE,
	input wire stallF,
	input wire stallD,
	input wire flushD,
	input wire flushE,
	output wire [4:0] rs1E,
	output wire [4:0] rs2E,
	output reg [4:0] write_regEout,
	output reg [4:0] write_regMout,
	output reg [4:0] write_regWout,
	output reg [4:0] rs1D,
	output reg [4:0] rs2D,
	
	// Verification Output Signals
    output reg [31:0] pc_out1,       // Current PC
    output reg [31:0] instr_out1,    // Fetched Instruction
    output reg [31:0] result,      // Data being written to Register File
    output reg [4:0]  write_to_reg,   // Register being written to
    output reg [31:0] ALUResult,   // Address for Data Memory
    output reg [31:0] writeData,    // Data being written to Data Memory
	output reg MemWrite 			// Write to Memory Enable
);
	wire ALUSrcE, negE;
	wire [1:0] ALUSrcAE;
	wire [2:0] ALUControlE;
	wire [1:0] ResultSrcW;
	wire RegWriteW;
	wire MemWriteM;
	wire [31:0] resultW;
	wire PCSrcE, RegWriteE, MemWriteE, BranchE, JumpE;
	wire [1:0] ResultSrcE;

	wire RegWriteM;
	wire [1:0] ResultSrcM;
	wire zero_flag;
	wire [2:0] funct3E;

	// Data Signals 
	wire [31:0] PCTargetE;
	wire [31:0] pc_in, pc_out, pc_out4;
	wire [31:0] instr_out;
	wire [31:0] instrD, pc_d, pc_plus4_d;
	
	wire [31:0] regData1, regData2;
	wire [31:0] immExtD, immExtE;
	wire [31:0] regData1E, regData2E;
    wire [31:0] dataA, dataB;
	wire [31:0] pcE, pc_plus4_E, pc_plus4_M, pc_plus4_W;
	wire [4:0] write_regE, write_regM, write_regW;
	
	wire [31:0] dataInB;
	wire [31:0] aluA;
	wire [31:0] ALUresult;
	wire [31:0] ALUResultM, ALUResultW;
	wire [31:0] writeDataM;
	
	wire [31:0] readData, readDataW;
	wire branch_taken;
	mux2to1 pcMux ( .a(pc_out4), .b(PCTargetE), .s(PCSrcE), .f(pc_in) );
	program_counter pc ( .clk(Clk), .reset(reset), .stall(stallF), .d(pc_in), .q(pc_out), .q_add_4(pc_out4) );
	instruction_memory instrMem ( .clk(Clk), .address(pc_out), .instruction(instr_out) );
	
	fetch_reg fetchtodecode ( .clk(Clk), .reset(reset), .flush(flushD), .stall(stallD), .instr_f(instr_out), .pc_f(pc_out), 
	                            .pc_plus4_f(pc_out4), .instr_d(instrD), .pc_d(pc_d), .pc_plus4_d(pc_plus4_d) );
										
	register_file regFile ( .clk(Clk), .reset(reset), .read_reg1(instrD[19:15]), .read_reg2(instrD[24:20]), 
									.write_reg(write_regW), .write_enable(RegWriteW), .write_data(resultW),
									.data1(regData1), .data2(regData2) );
	
	immediate_extend_unit extend ( .imm(instrD[31:7]), .imm_sel(ImmSrcD), .imm_output(immExtD) );
	
	decode_reg decodetoexecute ( .clk(Clk), .reset(reset), .flush(flushE), .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .BranchD(BranchD), 
										.JumpD(JumpD), .ALUSrcD(ALUSrcD), .ALUSrcAD(ALUSrcAD), .ResultSrcD(ResultSrcD), .ALUControlD(ALUControlD), .negD(negD), .funct3D(funct3),
    							.RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .BranchE(BranchE), .JumpE(JumpE), .ALUSrcE(ALUSrcE), 
										.ALUSrcAE(ALUSrcAE), .ResultSrcE(ResultSrcE), .ALUControlE(ALUControlE), .negE(negE), .funct3E(funct3E), .data1(regData1), .data2(regData2), .pc_d(pc_d), 
								.pc_plus4_d(pc_plus4_d), .rs1D(instrD[19:15]), .rs2D(instrD[24:20]), 
								.write_regD(instrD[11:7]), .immExtD(immExtD), .data1E(regData1E), 
								.data2E(regData2E), .pcE(pcE), .pc_plus4E(pc_plus4_E), .rs1E(rs1E), 
								.rs2E(rs2E), .write_regE(write_regE), .immExtE(immExtE) );

    mux4to1 ForwardMuxA ( .a(regData1E), .b(resultW), .c(ALUResultM), .d(32'b0), .s(forwardAE), .f(dataA) );

    mux4to1 ForwardMuxB ( .a(regData2E), .b(resultW), .c(ALUResultM), .d(32'b0), .s(forwardBE), .f(dataB) );

	mux2to1 aluMux ( .a(dataB), .b(immExtE), .s(ALUSrcE), .f(dataInB) );										
	mux4to1 aluAMux ( .a(dataA), .b(pcE), .c(32'b0), .d(32'b0), .s(ALUSrcAE), .f(aluA) );
			
	ALU alu ( .opcode(ALUControlE), .sub_flag(negE), .A(aluA), .B(dataInB), .result(ALUresult), .zero_flag(zero_flag) );
	
	adder addPCImm ( .a(pcE), .b(immExtE), .sum(PCTargetE) );

	assign branch_taken = BranchE && (
		(funct3E == 3'b000 && (dataA == dataB)) ||
		(funct3E == 3'b001 && (dataA != dataB)) ||
		(funct3E == 3'b100 && ($signed(dataA) < $signed(dataB))) ||
		(funct3E == 3'b101 && ($signed(dataA) >= $signed(dataB))) ||
		(funct3E == 3'b110 && (dataA < dataB)) ||
		(funct3E == 3'b111 && (dataA >= dataB))
	);
	
	execute_reg executetomemory ( .clk(Clk), .reset(reset), .RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .ResultSrcE(ResultSrcE),
    										.RegWriteM(RegWriteM), .MemWriteM(MemWriteM), .ResultSrcM(ResultSrcM),
											.ALUResultE(ALUresult), .writeDataE(dataB), 
											.pc_plus4E(pc_plus4_E), .write_regE(write_regE), .ALUResultM(ALUResultM), 
											.writeDataM(writeDataM), .pc_plus4M(pc_plus4_M), .write_regM(write_regM) );
	
	data_memory dataMem ( .clk(Clk), .wen(MemWriteM), .addr(ALUResultM), .data_in(writeDataM), .data_out(readData) );
	
	memory_write_reg memorytowriteback ( .clk(Clk), .reset(reset), .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .RegWriteW(RegWriteW), 
													.ResultSrcW(ResultSrcW), .ALUResultM(ALUResultM), .readDataM(readData), 
													.pc_plus4M(pc_plus4_M), .write_regM(write_regM), .ALUResultW(ALUResultW), 
													.readDataW(readDataW), .pc_plus4W(pc_plus4_W), .write_regW(write_regW) );
	
	mux4to1 resultMux ( .a(ALUResultW), .b(readDataW), .c(pc_plus4_W), .d(32'b0), .s(ResultSrcW), .f(resultW) );
	
	assign PCSrcE = JumpE || branch_taken;
	assign PCSrcEout = PCSrcE;
	
	always @(*) begin
		op = instrD[6:0];
		funct3 = instrD[14:12];
		funct7_5 = instrD[30];
		ZeroE = zero_flag;

		rs1D = instrD[19:15];
		rs2D = instrD[24:20];
		write_regEout = write_regE; 
		write_regMout = write_regM;
		write_regWout = write_regW;
		RegWriteMout  = RegWriteM;
		RegWriteWout  = RegWriteW;
		ResultSrcEHaz = ResultSrcE;
		MemWrite = MemWriteM;

		pc_out1 = pc_out;
		instr_out1 = instr_out;
		result = resultW;
		write_to_reg = write_regW;
		ALUResult = ALUResultM;
		writeData = writeDataM;
	end
endmodule