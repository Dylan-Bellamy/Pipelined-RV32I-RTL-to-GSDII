/*
    Data Memory
    - Stores data
    - Inputs and Outputs
        - address: Given by program counter to get instruction at memory location
        - instruction: Instruction at pc address
*/
module data_memory(
	input wire clk, wen,
	input wire [31:0] addr,
	input wire [31:0] data_in,
	output wire [31:0] data_out
);
	reg [31:0] memory [4095:0];
	
	integer i;
	initial begin
		for(i = 0; i < 4095; i = i + 1) begin
			memory[i] = 32'b0;
		end
	end
	
	always @(posedge clk) begin
		memory[addr[31:2]] <= wen ? data_in : 32'b0;
	end
	
	assign data_out = memory[addr[31:2]];
endmodule