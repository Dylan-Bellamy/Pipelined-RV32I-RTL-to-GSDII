# Fully Synthesizable 5-Stage Pipelined RISC-V (RV32I) Processor

A 32-bit, 5-stage pipelined RISC-V CPU written in Verilog/SystemVerilog and built in Xilinx Vivado. The design is fully synthesizable and was taken through synthesis and implementation with timing constraints (SDC) and static timing analysis (STA) to find and fix critical-path violations.

**Tools:** Verilog · SystemVerilog · Vivado (XSim, Synthesis, Implementation) · SDC/TCL · Linux/Unix

---

## Highlights

- **Classic 5-stage pipeline:** Fetch → Decode → Execute → Memory → Writeback, with a pipeline register between every stage.
- **Hazard handling in hardware:** data forwarding, load-use stalling, and control-flow flushing, all driven by a dedicated hazard unit.
- **Synthesizable RTL:** the datapath, control, and hazard logic are written for synthesis, with memories structured so they can be swapped for SRAM macros.
- **Timing-driven design:** SDC constraints define the clock, clock uncertainty, and I/O delays, and critical paths from STA reports were used to guide optimization.
- **In-depth Testbenches:** full CPU  only (datapath & control haven't been updated yet).

---

## Microarchitecture

```
        ┌────────┐   ┌────────┐   ┌─────────┐   ┌────────┐   ┌─────────┐
  PC ──►│ Fetch  │──►│ Decode │──►│ Execute │──►│ Memory │──►│Writeback│
        │  IF    │   │   ID   │   │   EX    │   │  MEM   │   │   WB    │
        └────────┘   └────────┘   └─────────┘   └────────┘   └─────────┘
          fetch_reg    decode_reg   execute_reg   memory_write_reg
                          ▲            ▲  │              │
                          │            │  └─ forwarding ─┘
                          └── hazard unit (stall / flush / forward)
```

| Stage | What happens | Key modules |
|---|---|---|
| **Fetch** | PC selects the next instruction (PC+4 or branch/jump target) and reads instruction memory | `program_counter`, `instruction_memory`, `adder`, `mux2to1` |
| **Decode** | Instruction is decoded, registers are read, and the immediate is generated | `control`, `register_file`, `immediate_extend_unit` |
| **Execute** | ALU operation, branch condition evaluation, and branch/jump target calculation | `ALU`, `mux4to1` (forwarding), `adder` |
| **Memory** | Load/store access to data memory | `data_memory` |
| **Writeback** | Result mux selects ALU result, loaded data, or PC+4 and writes it back to the register file | `mux4to1`, `register_file` |

### Hazard handling (`hazard.v`)

- **Data forwarding:** Results from the Memory and Writeback stages are forwarded to the Execute stage's ALU operand muxes, so dependent back-to-back instructions don't need to wait for the register file. Writes to `x0` are never forwarded.
- **Register file write-through:** The register file bypasses write data to its read ports when a read and a write hit the same register in the same cycle, covering the Writeback→Decode case.
- **Load-use stall:** If an instruction in Decode needs the result of a load currently in Execute, the PC and fetch/decode register are stalled and a bubble is inserted into Execute.
- **Control hazards:** Branches and jumps are resolved in Execute. When one is taken, the Fetch/Decode and Decode/Execute registers are flushed so wrong-path instructions never commit.

### Supported instructions

| Type | Instructions |
|---|---|
| R-type | `ADD` `SUB` `SLL` `SLT` `SLTU` `XOR` `SRL` `SRA` `OR` `AND` |
| I-type (ALU) | `ADDI` `SLTI` `SLTIU` `XORI` `ORI` `ANDI` `SLLI` `SRLI` `SRAI` |
| Load / Store | `LW` `SW` |
| Branch | `BEQ` `BNE` `BLT` `BGE` `BLTU` `BGEU` |
| Jump | `JAL` |
| Upper immediate | `LUI` `AUIPC` |

### Current limitations

- `JALR` is not implemented yet.
- Loads and stores are word-wide only (`LW`/`SW`); byte and halfword accesses (`LB`/`LH`/`LBU`/`LHU`/`SB`/`SH`) are not implemented.
- No `FENCE`, `ECALL`/`EBREAK`, or CSR support.

---

## Repository layout

```
.
├── src/
│   ├── cpu.v                    # Top level: control + datapath + hazard unit
│   ├── datapath.v               # 5-stage datapath and pipeline wiring
│   ├── control.v                # Main control / ALU control decode
│   ├── hazard.v                 # Forwarding, stall, and flush logic
│   ├── ALU.v
│   ├── register_file.v
│   ├── immediate_extend_unit.v
│   ├── program_counter.v
│   ├── fetch_reg.v              # IF/ID pipeline register
│   ├── decode_reg.v             # ID/EX pipeline register
│   ├── execute_reg.v            # EX/MEM pipeline register
│   ├── memory_write_reg.v       # MEM/WB pipeline register
│   ├── instruction_memory.v     # 256 x 32 instruction memory
│   ├── data_memory.v            # 4096 x 32 data memory (must modify slightly for simulation ONLY)
│   ├── adder.v, mux2to1.v, mux4to1.v
│   ├── tb_sys_verification.sv   # Full-CPU program test
│   └── riscv32i.xpr             # Vivado project
├── constrs/RV32I.out.sdc      # Timing constraints
└── README.md
```

---

## Getting started

### Requirements

- Xilinx Vivado (project targets an Artix-7 `xc7a100t`)
- Linux/Unix or Windows shell

### Simulate

1. Open `src/riscv32i.xpr` in Vivado.
2. In the Simulation Sources, set the testbench as the top level entity (`tb_sys_verification.sv`).
3. In the data_memory, comment out all logic except wires and uncomment sram_4096x32 instantiation and module (Only do this for simulation)  
4. Run **Simulation → Run Behavioral Simulation**.

The full-CPU testbench preloads a short program into instruction memory (immediate and register arithmetic, a store followed by a load, and a taken branch that skips an instruction), runs it through the pipeline, then checks the final register and memory contents. It prints `CPU smoke test passed.` on success and calls `$fatal` on any mismatch.

To load a program from a file instead, define `SIMULATION` and provide `program_code.txt` (hex words, one per line), which `instruction_memory.v` reads with `$readmemh`.

### Synthesize and implement

1. Open `src/riscv32i.xpr`.
2. Make sure the SDC file under `riscv32i.srcs/constrs_1` is the active constraint set.
3. Run **Synthesis**, then **Implementation**, then open the timing summary.

Or from the Vivado TCL console / batch mode:

```tcl
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1
report_timing_summary
```

---

## Timing constraints and STA

Constraints live in the SDC files under `/constrs/` and cover:

- A single `sys_clk` clock created on the `clk` port
- Setup and hold clock uncertainty
- Input delay on `reset`
- Output delays and load on the CPU's observation outputs
- False paths on the debug/verification output ports, so they don't dominate timing closure

Timing closure was driven by reading Vivado's routed timing summary, finding the worst-slack paths, and restructuring the RTL (and adjusting constraints and synthesis settings) to shorten them.

---

## Design notes

- **Memories:** Instruction and data memories are behavioral arrays. `instruction_memory.v` already wraps its array in an `sram_256x32` module, and `data_memory.v` has a commented-out `sram_4096x32` instantiation, so either can be swapped for a memory-compiler SRAM macro.
- **Observation ports:** The `cpu` top module exposes `pc`, `instr`, register-write and memory-write signals so testbenches and waveform viewers can monitor retirement without reaching into the hierarchy.

---

## Future work

- `JALR` and sub-word loads/stores for full RV32I coverage
- Branch prediction to reduce the taken-branch penalty
- Run the official `riscv-tests` / `riscv-arch-test` suites
- Eventually start physical design via either openlane flow (opensource) or cadence/synopsys (license required)
