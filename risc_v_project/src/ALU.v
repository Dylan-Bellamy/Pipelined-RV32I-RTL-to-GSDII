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
    input wire sub_flag,
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [31:0] result,
    output wire zero_flag
);
    wire signed [31:0] signed_A = A;
    wire signed [31:0] signed_B = B;
    always @(*) begin
        case(opcode) 
            3'b000: result = sub_flag ? (A - B) : (A + B);          // 0x0: SUB (if sub_flag=1) or ADD/ADDI (if 0)
            3'b001: result = A << B[4:0];                           // 0x1: SLL / SLLI (Uses lower 5 bits of B for shift amount)
            
            // Comparison Operations
            3'b010: begin                                           // 0x2: SLT / SLTI (Signed comparison)
                result = (signed_A < signed_B) ? 32'b1 : 32'b0;
            end         
            3'b011: result = (A < B) ? 32'b1 : 32'b0;               // 0x3: SLTU / SLTIU (Unsigned comparison)
            
            3'b100: result = A ^ B;                                 // 0x4: XOR / XORI
            3'b101: result = sub_flag ? (signed_A >>> B[4:0])       // 0x5: SRA/SRAI (Signed) vs SRL/SRLI (Unsigned)
                                        : (A >> B[4:0]); 
            3'b110: result = A | B;                                 // 0x6: OR / ORI
            3'b111: result = A & B;                                 // 0x7: AND / ANDI
            
            default: result = 32'b0;
        endcase
    end
    // If result is equal to zero, return 1 else 0
    assign zero_flag = (result == 32'b0) ? 1'b1 : 1'b0;   
endmodule
    