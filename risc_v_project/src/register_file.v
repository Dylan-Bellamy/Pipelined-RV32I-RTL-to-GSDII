/*
    Register File
    - A Component that holds 32 Registers that each contain 32 bits of data
    - Inputs and Outputs
        - Clock: 0->1 changes the pc counter to the next instruction
        - Reset: Resets program counter to zero
        - Read_Reg1: Address of Register 1
        - Read_Reg1: Address of Register 2
        - Write_Reg: Address of Register that's written to
        - Write_Enable: Allows register file to write data into a register
        - Write_Data: The data that is written to a chosen register 
        - Data1: The data from Register 1 that's used by the ALU
        - Data2: The data from Register 2 that's used by the ALU
*/
module register_file(
    input wire clk,
    input wire reset,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire write_enable,
    input wire [31:0] write_data,
    output wire [31:0] data1,
    output wire [31:0] data2
);
    // Four bytes of data in 32 memory locations
    reg [31:0] reg_data [31:0];

    integer i;
    
    always @(posedge clk) begin
        // if reset is HIGH, loads and overwrites registers with set values
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_data[i] <= 32'b0;
            end
        // if write_enable is HIGH, register at address write_reg is loaded with data from input write_data
        end else if (write_enable && (write_reg != 5'b0)) begin
            reg_data[write_reg] <= write_data;
        end
    end

    // Write-through bypass handles same-cycle WB->ID hazards
    assign data1 = (write_enable && (write_reg != 5'b0) && (write_reg == read_reg1)) ? write_data : reg_data[read_reg1];
    assign data2 = (write_enable && (write_reg != 5'b0) && (write_reg == read_reg2)) ? write_data : reg_data[read_reg2];
endmodule 