/*
    Instruction Memory (Program Memory)
    - Stores instructions
    - Inputs and Outputs
        - address: Given by program counter to get instruction at memory location
        - instruction: Instruction at pc address
*/
module instruction_memory(
    input [31:0] address,
    output [31:0] instruction
);
    // Four bytes of addressable memory with 256 locations
    reg [31:0] memory [255:0]; 

	 integer i;
    // Initializing instructions in memory
    initial begin
        // instruction set eq. {funct7, rs2, rs1, funct3, rd, opcode}
        memory[0]  = {7'b0000000, 5'b00010, 5'b00001, 3'b000, 5'b00011, 7'b0110011}; // add x3, x1, x2
        memory[1]  = {7'b0100000, 5'b00100, 5'b00011, 3'b000, 5'b01001, 7'b0110011}; // sub x9, x3, x4
        memory[2]  = {7'b0000000, 5'b00110, 5'b00101, 3'b111, 5'b00111, 7'b0110011}; // and x7, x5, x6
        memory[3]  = {7'b0000000, 5'b01000, 5'b00111, 3'b110, 5'b01000, 7'b0110011}; // or  x8, x7, x8
        memory[4]  = {7'b0000000, 5'b01001, 5'b01000, 3'b100, 5'b01010, 7'b0110011}; // xor x10, x8, x9
        memory[5]  = {7'b0000000, 5'b01010, 5'b01001, 3'b001, 5'b01011, 7'b0110011}; // sll x11, x9, x10
        memory[6]  = {7'b0000000, 5'b01100, 5'b01010, 3'b101, 5'b01101, 7'b0110011}; // srl x13, x10, x12
        memory[7]  = {7'b0100000, 5'b01101, 5'b01011, 3'b101, 5'b01110, 7'b0110011}; // sra x14, x11, x13
        memory[8]  = {12'b000000000101, 5'b00100, 3'b000, 5'b00101, 7'b0010011}; // addi x5, x4, 5
        memory[9]  = {12'b000000000111, 5'b00101, 3'b100, 5'b00110, 7'b0010011}; // xori x6, x5, 7
        memory[10] = {12'b000000001000, 5'b00110, 3'b110, 5'b00111, 7'b0010011}; // ori x7, x6, 8
        memory[11] = {12'b000000001100, 5'b01000, 3'b010, 5'b01001, 7'b0000011}; // lw x9, 12(x8)
        memory[12] = {7'b0000000, 5'b01001, 5'b01010, 3'b010, 5'b01100, 7'b0100011}; // sw x9, 12(x10)
        memory[13] = {7'b0000000, 5'b01011, 5'b01100, 3'b000, 5'b00000, 7'b1100011}; // beq x11, x12, 0
        memory[14] = {7'b0000000, 5'b01101, 5'b01110, 3'b001, 5'b00000, 7'b1100011}; // bne x13, x14, 0
        memory[15] = {20'b00000000000000000001, 5'b00001, 7'b1101111}; // jal x1, 1
        // Note: more instructions can be added up
		  for(i = 16; i < 256; i = i + 1) begin
			   memory[i] = 32'b0;
		  end
    end

    /*  
        instruction @ pc address location
        lower two bits of address can be truncated 
        because program counter increments by 4 
    */
    assign instruction = {memory[address[9:2]]};
endmodule