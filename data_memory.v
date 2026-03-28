/*
    Data Memory
    - Stores data
    - Inputs and Outputs
        - address: Given by program counter to get instruction at memory location
        - instruction: Instruction at pc address
*/
module data_memory(
	input wire clk,
	input wire [7:0] addr,
	input wire [31:0] data_in,
	input wire en, wen,
	output reg [31:0] data_out
);
	reg [31:0] memory [0:255];
	
	integer i;
	initial begin
		for(i = 0; i < 256; i = i + 1) begin
			memory[i] = 32'b0;
		end
	end
	
	always @(negedge clk) begin
		case(!en) 
			1'b0: begin
				data_out <= wen ? 32'b0 : memory[addr];
				memory[addr] <= wen ? data_in : memory[addr];
			end
			1'b1: data_out <= 32'b0;
		endcase
	end
endmodule