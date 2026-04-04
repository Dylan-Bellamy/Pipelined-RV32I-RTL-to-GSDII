/*
    Program Counter
    - Register that holds the memory address for the next instruction
    - Inputs and Outputs
        - Clock: 0->1 changes the pc counter to the next instruction
        - Reset: Resets program counter to zero
		  - d: Instruction address
        - q: The address of the current instruction
		  - q_add_4: The address of the next instruction
*/
module program_counter(
    input wire clk,
    input wire reset,
	 input wire [31:0] d,
	 output reg [31:0] q,
    output reg [31:0] q_add_4
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 32'h0;
				q_add_4 <= 32'h0;
        end else begin
				q <= d;
            q_add_4 <= d + 4;
        end
    end
endmodule 