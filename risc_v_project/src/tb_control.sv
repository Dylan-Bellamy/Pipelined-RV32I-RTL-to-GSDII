`timescale 1ns / 1ps

module tb_control();

    // 1. Declare signals
    logic clk;
    logic [6:0] op;
    logic [2:0] funct3;
    logic funct7_5;
    logic ZeroE;

    wire RegWriteW;
    wire MemWriteM;
    wire PCSrcE;
    wire ALUSrcE;
    wire [1:0] ImmSrcD;
    wire [1:0] ResultSrcW;
    wire [2:0] ALUControlE;

    // 2. Instantiate the Control Unit (UUT)
    control uut (
        .clk(clk),
        .op(op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ZeroE(ZeroE),
        .RegWriteW(RegWriteW),
        .MemWriteM(MemWriteM),
        .PCSrcE(PCSrcE),
        .ALUSrcE(ALUSrcE),
        .ImmSrcD(ImmSrcD),
        .ResultSrcW(ResultSrcW),
        .ALUControlE(ALUControlE)
    );

    // 3. Clock Generation (10ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 4. Stimulus Process
    initial begin
        // Initialize Inputs
        op = 7'b0000000;
        funct3 = 3'b000;
        funct7_5 = 0;
        ZeroE = 0;

        // Wait for pipeline to settle
        #15;

        $display("-------------------------------------------------------------------------------------------------");
        $display("Time | op      | f3  | f7 | Z || ImmD | ALUSrcE | ALUOpE | MemWM | RegWW | ResSW | PCSrcE");
        $display("-------------------------------------------------------------------------------------------------");

        // Test 1: Load Instruction (I-Type)
        // Expected: ImmD=00 immediately. ALUSrcE=1 next cycle. MemWM=0 in 2 cycles. RegWW=1 in 3 cycles.
        op = 7'b0000011; funct3 = 3'b010; funct7_5 = 0; ZeroE = 0;
        @(posedge clk); #1; 

        // Test 2: Arithmetic (R-Type) - ADD
        op = 7'b0110011; funct3 = 3'b000; funct7_5 = 0; ZeroE = 0;
        @(posedge clk); #1;

        // Test 3: Store Instruction (S-Type)
        op = 7'b0100011; funct3 = 3'b010; funct7_5 = 0; ZeroE = 0;
        @(posedge clk); #1;

        // Test 4: Branch (BEQ) - Not Taken
        op = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; ZeroE = 0; 
        @(posedge clk); #1;

        // Test 5: Branch (BEQ) - Taken
        op = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; ZeroE = 1; 
        @(posedge clk); #1;

        // Flush pipeline with NOPs to let the last instructions finish
        op = 7'b0000000;
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

        $display("-------------------------------------------------------------------------------------------------");
        $finish;
    end

    // 5. Monitor changes at every clock edge
    always @(posedge clk) begin
        // #1 delay ensures we read the updated register values after the clock edge
        #1 $display("%4t | %b | %b |  %b | %b ||  %b  |    %b    |   %b  |   %b   |   %b   |   %b  |   %b",
                    $time, op, funct3, funct7_5, ZeroE,
                    ImmSrcD, ALUSrcE, ALUControlE, MemWriteM, RegWriteW, ResultSrcW, PCSrcE);
    end

endmodule