/*
	Datapath (IF/ID/EX/MEM/WB)
*/
module datapath(
	input wire Clk,
	input wire reset,
	
	input wire PCSrcE,
	input wire RegWriteW, 
	input wire MemWriteM,
	input wire ALUSrcE, 
	input wire [1:0] ImmSrcD,
	input wire [1:0] ResultSrcW,
	input wire [2:0] ALUControlE,
	
	output reg [6:0] op,
	output reg [2:0] funct3,
	output reg funct7_5,
	output reg ZeroE,
	
	// Verification Output Signals
	output reg [31:0] pc_out1,       // Current PC
   output reg [31:0] instr_out1,    // Fetched Instruction
   output reg [31:0] result,      // Data being written to Register File
   output reg [4:0]  write_to_reg,   // Register being written to
   output reg [31:0] ALUResult,   // Address for Data Memory
   output reg [31:0] writeData    // Data being written to Data Memory
);
	wire [31:0] PCTargetE;
	wire [31:0] pc_in, pc_out, pc_out4;
	wire [31:0] instr_out;
	wire [31:0] instrD, pc_d, pc_plus4_d;
	
	wire zero_flag;
	wire [31:0] regData1, regData2;
	wire [31:0] immExtD, immExtE;
	wire [31:0] regData1E, regData2E;
	wire [31:0] pcE, pc_plus4_E, pc_plus4_M, pc_plus4_W;
	wire [4:0] write_regE, write_regM, write_regW;
	
	wire [31:0] dataInB;
	wire [31:0] ALUresult;
	wire [31:0] ALUResultM, ALUResultW;
	wire [31:0] writeDataM;
	
	wire [31:0] readData, readDataW;
	wire [31:0] resultW;
	

	mux2to1 pcMux ( .a(pc_out4), .b(PCTargetE), .s(PCSrcE), .f(pc_in) );
	program_counter pc ( .clk(Clk), .reset(reset), .d(pc_in), .q(pc_out), .q_add_4(pc_out4) );
	instruction_memory instrMem ( .address(pc_out), .instruction(instr_out) );
	
	fetch_reg fetchtodecode ( .clk(Clk), .reset(reset), .instr_f(instr_out), .pc_f(pc_out), .pc_plus4_f(pc_out4),
										.instr_d(instrD), .pc_d(pc_d), .pc_plus4_d(pc_plus4_d) );
										
	register_file regFile ( .clk(Clk), .reset(reset), .read_reg1(instrD[19:15]), .read_reg2(instrD[24:20]), 
									.write_reg(write_regW), .write_enable(RegWriteW), .write_data(resultW),
									.data1(regData1), .data2(regData2) );
	
	immediate_extend_unit extend ( .imm(instrD[31:7]), .imm_sel(ImmSrcD), .imm_output(immExtD) );
	
	decode_reg decodetoexecute ( .clk(Clk), .reset(reset), .data1(regData1), .data2(regData2), .pc_d(pc_d), 
											.pc_plus4_d(pc_plus4_d), .write_regD(instrD[11:7]), .immExtD(immExtD),
											.data1E(regData1E), .data2E(regData2E), .pcE(pcE), .pc_plus4E(pc_plus4_E),
											.write_regE(write_regE), .immExtE(immExtE) );

	mux2to1 aluMux ( .a(regData2E), .b(immExtE), .s(ALUSrcE), .f(dataInB) );										
			
	ALU alu ( .opcode(ALUControlE), .A(regData1E), .B(dataInB), .result(ALUresult), .zero_flag(zero_flag) );
	
	adder addPCImm ( .a(pcE), .b(immExtE), .sum(PCTargetE) );
	
	execute_reg executetomemory ( .clk(Clk), .reset(reset), .ALUResultE(ALUresult), .writeDataE(regData2E), 
											.pc_plus4E(pc_plus4_E), .write_regE(write_regE), .ALUResultM(ALUResultM), 
											.writeDataM(writeDataM), .pc_plus4M(pc_plus4_M), .write_regM(write_regM) );
	
	data_memory dataMem ( .clk(Clk), .wen(MemWriteM), .addr(ALUResultM), .data_in(writeDataM), .data_out(readData) );
	
	memory_write_reg memorytowriteback ( .clk(Clk), .reset(reset), .ALUResultM(ALUResultM), .readDataM(readData), 
													.pc_plus4M(pc_plus4_M), .write_regM(write_regM), .ALUResultW(ALUResultW), 
													.readDataW(readDataW), .pc_plus4W(pc_plus4_W), .write_regW(write_regW));
	
	mux4to1 resultMux ( .a(ALUResultM), .b(readDataW), .c(pc_plus4_W), .d(32'b0), .s(ResultSrcW), .f(resultW) );
	
	always @(*) begin
		op = instrD[6:0];
		funct3 = instrD[14:12];
		funct7_5 = instrD[30];
		ZeroE = zero_flag;
		
		pc_out1 = pc_out;
		instr_out1 = instr_out;
		result = resultW;
		write_to_reg = write_regW;
		ALUResult = ALUResultM;
		writeData = writeDataM;
	end
endmodule