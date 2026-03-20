/*
    Immediate Extend Unit (Extend Unit)
    - 
    - Inputs and Outputs
        - address: Given by program counter to get instruction at memory location
        - instruction: Instruction at pc address
*/
module immediate_extend_unit(
    input [31:7] imm,
    input [1:0] imm_sel,
    output [31:0] imm_output
);
    // Immeidate Output based on Instruction Format 
    always @(*) begin   
        case(imm_sel) 
            // I-Type Instruction Format 
            2'b00: imm_output = { {20 {imm[31] } }, imm{31:20} };
            // S-Type Instruction Format
            2'b01: imm_output = { {20 {imm[31] } }, imm{31:25}, imm{11:7} };
            // B-Type Instruction Format
            2'b10: imm_output = { {20 {imm[31] } };
            // J-Type Instruction Format
            2'b11:
            default: imm_output = 32'bx;
        endcase
    end
endmodule 