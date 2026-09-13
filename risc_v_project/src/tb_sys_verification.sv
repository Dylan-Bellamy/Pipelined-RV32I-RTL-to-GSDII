`timescale 1ns / 1ps

module tb_cpu_verification;

    logic clk;
    logic reset;

    wire [31:0] pc;
    wire [31:0] instr;
    wire reg_write_en;
    wire mem_write_en;
    wire [4:0] reg_write_addr;
    wire [31:0] reg_write_data;
    wire [31:0] mem_write_addr;
    wire [31:0] mem_write_data;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .reg_write_en(reg_write_en),
        .mem_write_en(mem_write_en),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),
        .mem_write_addr(mem_write_addr),
        .mem_write_data(mem_write_data)
    );

    always #5 clk = ~clk;

    function automatic [31:0] encode_r(
        input [6:0] funct7,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd,
        input [6:0] opcode
    );
        encode_r = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    function automatic [31:0] encode_i(
        input [11:0] imm,
        input [4:0] rs1,
        input [2:0] funct3,
        input [4:0] rd,
        input [6:0] opcode
    );
        encode_i = {imm, rs1, funct3, rd, opcode};
    endfunction

    function automatic [31:0] encode_s(
        input [11:0] imm,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3,
        input [6:0] opcode
    );
        encode_s = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    endfunction

    function automatic [31:0] encode_b(
        input integer byte_offset,
        input [4:0] rs2,
        input [4:0] rs1,
        input [2:0] funct3,
        input [6:0] opcode
    );
        logic [12:0] imm;
        begin
            imm = byte_offset[12:0];
            encode_b = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
        end
    endfunction

    task automatic expect_eq(
        input string name,
        input logic [31:0] got,
        input logic [31:0] expected
    );
        if (got !== expected) begin
            $fatal(1, "%s mismatch: got=%08h expected=%08h", name, got, expected);
        end
    endtask

    task automatic preload_program;
        int i;
        begin
            for (i = 0; i < 256; i++) begin
                dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[i] = 32'h00000013;
            end

            for (i = 0; i < 16; i++) begin
                dut.data_pipeline.dataMem.u_dmem_sram.internal_memory_array[i] = 32'h00000000;
            end

            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[0] = encode_i(12'd5,  5'd0, 3'b000, 5'd1, 7'b0010011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[1] = encode_i(12'd7,  5'd0, 3'b000, 5'd2, 7'b0010011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[2] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[3] = encode_s(12'd0,  5'd3, 5'd0, 3'b010, 7'b0100011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[4] = encode_i(12'd0,  5'd0, 3'b010, 5'd4, 7'b0000011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[5] = encode_r(7'b0000000, 5'd4, 5'd1, 3'b000, 5'd5, 7'b0110011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[6] = encode_b(8, 5'd3, 5'd4, 3'b000, 7'b1100011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[7] = encode_i(12'd99, 5'd0, 3'b000, 5'd6, 7'b0010011);
            dut.data_pipeline.instrMem.u_imem_sram.internal_memory_array[8] = encode_i(12'd9,  5'd0, 3'b000, 5'd7, 7'b0010011);
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        preload_program();

        repeat (2) @(posedge clk);
        reset = 1'b0;

        repeat (18) @(posedge clk);
        #1;

        expect_eq("x1", dut.data_pipeline.regFile.reg_data[1], 32'd5);
        expect_eq("x2", dut.data_pipeline.regFile.reg_data[2], 32'd7);
        expect_eq("x3", dut.data_pipeline.regFile.reg_data[3], 32'd12);
        expect_eq("x4", dut.data_pipeline.regFile.reg_data[4], 32'd12);
        expect_eq("x5", dut.data_pipeline.regFile.reg_data[5], 32'd17);
        expect_eq("x6", dut.data_pipeline.regFile.reg_data[6], 32'd0);
        expect_eq("x7", dut.data_pipeline.regFile.reg_data[7], 32'd9);
        expect_eq("mem[0]", dut.data_pipeline.dataMem.u_dmem_sram.internal_memory_array[0], 32'd12);

        $display("CPU smoke test passed.");
        $finish;
    end

    initial begin
        $display("Time | reset | pc       | instr    | regW | memW | rd | wdata    | maddr    | mdata");
        $monitor("%4t |   %b   | %08h | %08h |  %b   |  %b   | %02d | %08h | %08h | %08h",
                 $time, reset, pc, instr, reg_write_en, mem_write_en, reg_write_addr,
                 reg_write_data, mem_write_addr, mem_write_data);
    end

    // Dump waves and monitor internal datapath signals for triage
    initial begin
        $dumpfile("tb_cpu_verification.vcd");
        $dumpvars(0, tb_cpu_verification);
    end

    always @(posedge clk) begin
    #1; // sample after registers update
    $display("--------------------------------------------------------------------------------\n",
             "Time = %0t\n", $time,
             "--- Program Counter & Instruction ---\n",
             "  pc_in   = %08h | pc_out  = %08h | pc4     = %08h\n", dut.data_pipeline.pc_in, dut.data_pipeline.pc_out, dut.data_pipeline.pc_out4,
             "  pcE     = %08h | instrD  = %08h\n", dut.data_pipeline.pcE, dut.data_pipeline.instr_out1,
             "--- Hazards & Forwarding ---\n",
             "  stallF  = %b       | fA      = %b       | fB      = %b\n", dut.data_pipeline.stallF, dut.forwardAE, dut.forwardBE,
             "--- Control Signals (Execute) ---\n",
             "  op      = %b       | funct3  = %b       | f7_5    = %b\n", dut.data_pipeline.op, dut.data_pipeline.funct3, dut.data_pipeline.funct7_5,
             "  negE    = %b       | ALUSrcE = %b       | ALUSrcAE= %b\n", dut.data_pipeline.negE, dut.data_pipeline.ALUSrcE, dut.data_pipeline.ALUSrcAE,
             "  ALUCtrl = %b\n", dut.data_pipeline.ALUControlE,
             "--- Registers & ALU Data ---\n",
             "  rs1E    = %0d      | rs2E    = %0d      | rdE     = %0d\n", dut.rs1E, dut.rs2E, dut.rdE,
             "  dataA   = %08h | dataB   = %08h | ALUres  = %08h\n", dut.data_pipeline.dataA, dut.data_pipeline.dataB, dut.data_pipeline.ALUresult,
             "--- Writeback & Memory ---\n",
             "  RegW(M) = %b       | RegW(W) = %b       | ResSrcW = %b\n", dut.RegWriteM, dut.data_pipeline.RegWriteWout, dut.data_pipeline.ResultSrcW,
             "  wr_regE = %0d      | wr_regM = %0d      | wr_regW = %0d\n", dut.data_pipeline.write_regEout, dut.data_pipeline.write_regMout, dut.data_pipeline.write_regWout,
             "  readW   = %08h | ALUResW = %08h | resultW = %08h\n", dut.data_pipeline.readDataW, dut.data_pipeline.ALUResultW, dut.data_pipeline.resultW,
             "--------------------------------------------------------------------------------");
end

endmodule