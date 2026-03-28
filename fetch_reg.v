/*
	Instruction Fetch Pipeline Register
*/

module fetch_reg(
	input wire clk,
   input wire reset,
   // Inputs from Fetch Stage
   input wire [31:0] instr_f,
   input wire [31:0] pc_f,
   input wire [31:0] pc_plus4_f,
    
   // Outputs to Decode Stage
   output reg [31:0] instr_d,
   output reg [31:0] pc_d,
   output reg [31:0] pc_plus4_d
);	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			instr_d <= 32'h0;
			pc_d <= 32'h0;
			pc_plus4_d <= 32'h0;
		end else begin
			instr_d <= instr_f;
			pc_d <= pc_f;
			pc_plus4_d <= pc_plus4_f;
		end
	end
endmodule		