`timescale 1ns / 1ps

module tb_datapath();

    // ---------------------------------------------------------
    // Signal Declarations
    // ---------------------------------------------------------
    logic Clk;
    logic reset;
    
    // Pipelined Control Signals
    logic       PCSrcE;
    logic       RegWriteW;
    logic       MemWriteM;
    logic       ALUSrcE;
    logic [1:0] ImmSrcD;
    logic [1:0] ResultSrcW;
    logic [2:0] ALUControlE;
    
    // Decode Stage Outputs
    logic [6:0] op;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       ZeroE;

    // ---------------------------------------------------------
    // Device Under Test (DUT)
    // ---------------------------------------------------------
    // The instruction_memory is already instantiated inside this datapath!
    datapath dut (
        .Clk(Clk), .reset(reset),
        .PCSrcE(PCSrcE), .RegWriteW(RegWriteW), .MemWriteM(MemWriteM),
        .ALUSrcE(ALUSrcE), .ImmSrcD(ImmSrcD), .ResultSrcW(ResultSrcW),
        .ALUControlE(ALUControlE),
        .op(op), .funct3(funct3), .funct7_5(funct7_5), .ZeroE(ZeroE)
    );

    // ---------------------------------------------------------
    // Clock Generation (10ns period)
    // ---------------------------------------------------------
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk; 
    end

    // ---------------------------------------------------------
    // Pipelined Stimulus Sequence for all 16 Instructions
    // ---------------------------------------------------------
    initial begin
        // Initialize all control signals to 0
        reset = 1; PCSrcE = 0; RegWriteW = 0; MemWriteM = 0; 
        ALUSrcE = 0; ImmSrcD = 0; ResultSrcW = 0; ALUControlE = 0;

        #15; 
        reset = 0; // Release reset. PC = 0.

        // CYCLE 1: FETCH Instr 0 (ADD)
        #10; 

        // CYCLE 2: FETCH Instr 1 (SUB), DECODE Instr 0 (ADD)
        #10;

        // CYCLE 3: FETCH 2(AND), DECODE 1(SUB), EXECUTE 0(ADD)
        ALUSrcE     = 1'b0;   // ADD uses Reg2
        ALUControlE = 3'b000; // ADD Op
        #10;

        // CYCLE 4: FETCH 3(OR), DECODE 2(AND), EXECUTE 1(SUB), MEMORY 0(ADD)
        ALUSrcE     = 1'b0;   // SUB uses Reg2
        ALUControlE = 3'b001; // SUB Op
        MemWriteM   = 1'b0;   // ADD no memory write
        #10;

        // CYCLE 5: FETCH 4(XOR), DECODE 3(OR), EXECUTE 2(AND), MEMORY 1(SUB), WRITEBACK 0(ADD)
        ALUSrcE     = 1'b0;   // AND uses Reg2
        ALUControlE = 3'b010; // AND Op
        MemWriteM   = 1'b0;   // SUB no memory write
        RegWriteW   = 1'b1;   // ADD writes to reg
        ResultSrcW  = 2'b00;  // ADD uses ALU result
        #10;

        // CYCLE 6: FETCH 5(SLL), DECODE 4(XOR), EXECUTE 3(OR), MEMORY 2(AND), WB 1(SUB)
        ALUControlE = 3'b011; // OR Op
        RegWriteW   = 1'b1;   // SUB writes to reg
        #10;

        // CYCLE 7: FETCH 6(SRL), DECODE 5(SLL), EXECUTE 4(XOR), MEMORY 3(OR), WB 2(AND)
        ALUControlE = 3'b100; // XOR Op
        RegWriteW   = 1'b1;   // AND writes to reg
        #10;

        // CYCLE 8: FETCH 7(SRA), DECODE 6(SRL), EXECUTE 5(SLL), MEMORY 4(XOR), WB 3(OR)
        ALUControlE = 3'b101; // SLL Op
        RegWriteW   = 1'b1;   // OR writes to reg
        #10;

        // CYCLE 9: FETCH 8(ADDI), DECODE 7(SRA), EXECUTE 6(SRL), MEMORY 5(SLL), WB 4(XOR)
        ALUControlE = 3'b110; // SRL Op
        RegWriteW   = 1'b1;   // XOR writes to reg
        #10;

        // CYCLE 10: FETCH 9(XORI), DECODE 8(ADDI), EXECUTE 7(SRA), MEMORY 6(SRL), WB 5(SLL)
        ImmSrcD     = 2'b00;  // ADDI is I-Type
        ALUControlE = 3'b111; // SRA Op
        RegWriteW   = 1'b1;   // SLL writes to reg
        #10;

        // CYCLE 11: FETCH 10(ORI), DECODE 9(XORI), EXECUTE 8(ADDI), MEMORY 7(SRA), WB 6(SRL)
        ImmSrcD     = 2'b00;  // XORI is I-Type
        ALUSrcE     = 1'b1;   // ADDI uses Immediate
        ALUControlE = 3'b000; // ADDI uses ADD Op
        RegWriteW   = 1'b1;   // SRL writes to reg
        #10;

        // CYCLE 12: FETCH 11(LW), DECODE 10(ORI), EXECUTE 9(XORI), MEMORY 8(ADDI), WB 7(SRA)
        ImmSrcD     = 2'b00;  // ORI is I-Type
        ALUSrcE     = 1'b1;   // XORI uses Immediate
        ALUControlE = 3'b100; // XORI uses XOR Op
        RegWriteW   = 1'b1;   // SRA writes to reg
        #10;

        // CYCLE 13: FETCH 12(SW), DECODE 11(LW), EXECUTE 10(ORI), MEMORY 9(XORI), WB 8(ADDI)
        ImmSrcD     = 2'b00;  // LW is I-Type
        ALUSrcE     = 1'b1;   // ORI uses Immediate
        ALUControlE = 3'b011; // ORI uses OR Op
        RegWriteW   = 1'b1;   // ADDI writes to reg
        #10;

        // CYCLE 14: FETCH 13(BEQ), DECODE 12(SW), EXECUTE 11(LW), MEMORY 10(ORI), WB 9(XORI)
        ImmSrcD     = 2'b01;  // SW is S-Type!
        ALUSrcE     = 1'b1;   // LW uses Immediate for address calc
        ALUControlE = 3'b000; // LW uses ADD Op
        RegWriteW   = 1'b1;   // XORI writes to reg
        #10;

        // CYCLE 15: FETCH 14(BNE), DECODE 13(BEQ), EXECUTE 12(SW), MEMORY 11(LW), WB 10(ORI)
        ImmSrcD     = 2'b10;  // BEQ is B-Type!
        ALUSrcE     = 1'b1;   // SW uses Immediate for address calc
        ALUControlE = 3'b000; // SW uses ADD Op
        MemWriteM   = 1'b0;   // LW no memory write
        RegWriteW   = 1'b1;   // ORI writes to reg
        #10;

        // CYCLE 16: FETCH 15(JAL), DECODE 14(BNE), EXECUTE 13(BEQ), MEMORY 12(SW), WB 11(LW)
        ImmSrcD     = 2'b10;  // BNE is B-Type
        ALUSrcE     = 1'b0;   // BEQ uses Reg2 to compare
        ALUControlE = 3'b001; // BEQ uses SUB to compare
        MemWriteM   = 1'b1;   // SW WRITES TO MEMORY!
        RegWriteW   = 1'b1;   // LW writes to reg
        ResultSrcW  = 2'b01;  // LW uses MemData, not ALU!
        #10;

        // CYCLE 17: FETCH none, DECODE 15(JAL), EXECUTE 14(BNE), MEMORY 13(BEQ), WB 12(SW)
        ImmSrcD     = 2'b11;  // JAL is J-Type
        ALUSrcE     = 1'b0;   // BNE uses Reg2
        ALUControlE = 3'b001; // BNE uses SUB
        MemWriteM   = 1'b0;   // BEQ no memory write
        RegWriteW   = 1'b0;   // SW does NOT write to reg
        #10;

        // CYCLE 18: FETCH none, DECODE none, EXECUTE 15(JAL), MEMORY 14(BNE), WB 13(BEQ)
        MemWriteM   = 1'b0;   // BNE no memory write
        RegWriteW   = 1'b0;   // BEQ does NOT write to reg
        #10;

        // CYCLE 19: FETCH none, DECODE none, EXECUTE none, MEMORY 15(JAL), WB 14(BNE)
        MemWriteM   = 1'b0;   // JAL no memory write
        RegWriteW   = 1'b0;   // BNE does NOT write to reg
        #10;

        // CYCLE 20: FETCH none, DECODE none, EXECUTE none, MEMORY none, WB 15(JAL)
        RegWriteW   = 1'b1;   // JAL writes PC+4 to reg!
        ResultSrcW  = 2'b10;  // JAL selects PC+4
        #10;

        // Drain pipeline
        RegWriteW = 1'b0; 
        #50;

        $display("Pipeline integration simulation complete. All 16 instructions executed.");
        $finish;
    end

    // ---------------------------------------------------------
    // Signal Monitoring
    // ---------------------------------------------------------
    initial begin
        $display("Time | Rst | Opcode  | F3  | F7_5 | ZeroE");
        $display("-------------------------------------------");
        $monitor("%4t |  %b  | %b | %b |  %b   |   %b", 
                 $time, reset, op, funct3, funct7_5, ZeroE);
    end

    // Dump waves to verify internal signals 
    initial begin
        $dumpfile("datapath.vcd");
        $dumpvars(0, tb_datapath);
    end

endmodule