# RISC-V-Microprocessor

## Tools Used
[Gowin IDE](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-Doc/install-the-ide.html):
While there are many great IDE's out there such as Vivado and Quartus, I choose to use Gowin's IDE as I wish to eventually implement the RISC-V microprocessor onto a [Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) and it's an easily setup making it very beginner friendly. If you wish to install or buy a Tang Nano 9K FPGA, I've attached links that you'd find helpful.

## Phase 1: RTL Design (Current Phase)
Write a fully functional RTL Design of a 5 Cycle Pipelined RV32I CPU in Verilog. 
# Component TODO List
- [x] Program Counter
- [x] Instruction Memory
- [x] Register File
- [x] Extend Unit
- [x] Data Memory
- [x] Control Unit
- [x] IF/ID Register
- [x] ID/EX Register
- [x] EX/MEM Register
- [x] MEM/WB Register
- [ ] Datapath
- [ ] Hazard Detection
- [ ] Flush Logic
- [ ] Full RV32I Implementation

## Phase 2: Digital Verification 
Verify the functionality of the RTL Design (Phase 1) via SystemVerilog Testbenches  
# Component TODO List
- [ ] Program Counter
- [ ] Instruction Memory
- [ ] Register File
- [ ] Extend Unit
- [ ] Data Memory
- [x] Control Unit
- [ ] IF/ID Register
- [ ] ID/EX Register
- [ ] EX/MEM Register
- [ ] MEM/WB Register
- [ ] Datapath
- [ ] Hazard Detection
- [ ] Flush Logic
- [ ] Full RV32I Implementation

## Phase 3: Formal Verification
Write mathematical rules (assertions) in SVA


