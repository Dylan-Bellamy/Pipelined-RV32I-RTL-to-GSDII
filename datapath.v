/*

*/
module datapath(
	input wire Clk,
	input wire reset,
	
	input wire PCSrcE,
	input wire PCTargetE,
	input wire RegWriteW, 
	input wire MemWriteM,
	input wire ALUSrcE, 
	input wire [1:0] ImmSrcD,
	input wire [1:0] ResultSrcW,
	input wire [2:0] ALUControlE,
	
	output reg [6:0] op,
	output reg [2:0] funct3,
	output reg funct7_5,
	output reg ZeroE
);
	wire pc_in, pc_out, pc_out4;
	wire instr_out;
	wire instrD, pc_d, pc_plus4_d;
	
	wire regData1, regData2


	mux2to1 pcMux ( .a(pc_out4), .b(PCTargetE), .s(PCSrcE), .f(pc_in) );
	program_counter pc ( .clk(Clk), .reset(reset), .d(pc_in), .q(pc_out), .q_add_4(pc_out4) );
	instruction_memory instrMem ( .address(pc_out), .instruction(instr_out) );
	
	fetch_reg fetchtodecode ( .clk(Clk), .reset(reset), .instr_f(instr_out), .pc_f(pc_out), .pc_plus4_f(pc_out4),
										.instr_d(instrD), .pc_d(pc_d), .pc_plus4_d(pc_plus4_d) );
										
	register_file regFile ( .clk(Clk), .reset(reset), .read_reg1(instrD[19:15]), .read_reg2(instrD[24:20]), 
									.write_reg(write_regW), .write_enable(RegWriteW), .data1(regData1), .data2(regData2) );
	
endmodule