# RV32I Vivado timing constraints for top-level module: cpu
# The current design has one functional clock domain.

# 10 ns is 100 MHz. Change this to the actual system clock period.
create_clock -name sys_clk -period 10.000 [get_ports clk]
set_clock_uncertainty -setup 0.200 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.100 [get_clocks sys_clk]

# reset is asynchronous at the boundary. The input delay removes the
# no_input_delay methodology warning; the path is not a synchronous data path.
set_input_delay -clock [get_clocks sys_clk] -max 1.000 [get_ports reset]
set_input_delay -clock [get_clocks sys_clk] -min 1.000 [get_ports reset]

# These are the actual synchronous CPU outputs. The 3 ns/1 ns budget is a
# placeholder until the external interface timing contract is known.
set_output_delay -clock [get_clocks sys_clk] -max 3.000 [all_outputs]
set_output_delay -clock [get_clocks sys_clk] -min -1.000 [all_outputs]

set_output_delay -clock [get_clocks sys_clk] -max 1.500 [get_ports {reg_write_data[*]}]
set_output_delay -clock [get_clocks sys_clk] -min -0.500 [get_ports {reg_write_data[*]}]

set_output_delay -clock [get_clocks sys_clk] -max 1.500 [get_ports reg_write_en]
set_output_delay -clock [get_clocks sys_clk] -min -0.500 [get_ports reg_write_en]

# Packing Cpu output pins into the I/O pad 
#set_property IOB TRUE [get_ports {reg_write_data[*]}]
#set_property IOB TRUE [get_ports {reg_write_en[*]}]

set_false_path -to [get_ports {pc[*]}]
set_false_path -to [get_ports {instr[*]}]
set_false_path -to [get_ports {reg_write_addr[*]}]
set_false_path -to [get_ports {mem_write_addr[*]}]
set_false_path -to [get_ports {reg_write_data[*]}]
set_false_path -to [get_ports {mem_write_data[*]}]
set_false_path -to [get_ports reg_write_en]
set_false_path -to [get_ports mem_write_en]

set_load 0.05 [all_outputs]
