/*
    ALU (Arithmetic Logic Unit)
    - Performs both arithmetic and logical operations
    - Inputs and Outputs
        - Opcode: Tells the ALU what operation to do
        - A: The data from register at rs1 address
        - B: The data from register at rs2 address
        - Result: The data result of the operation performed
        - Zero Flag: Becomes HIGH when the result is equal to zero
*/
module ALU(
    input wire [2:0] opcode,
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [31:0] result,
    output wire zero_flag
);
    always @(*) begin
        case(opcode) 
            3'b000: result = A + B;             // Addition
            3'b001: result = A - B;             // Subtraction
            3'b010: result = A | B;             // OR Gate
            3'b011: result = A & B;             // AND Gate
            3'b100: result = A << B;            // Shift Logical Left
            3'b101: result = A >> B;            // Shift Logical Right
            3'b110: result = A ^ B;             // XOR Gate
            3'b111: result = (A < B) ? 32'b1 : 32'b0;   // A less than B?
        endcase
    end
    // If result is equal to zero, return 1 else 0
    assign zero_flag = (result == 32'b0) ? 1'b1 : 1'b0;   
endmodule
    