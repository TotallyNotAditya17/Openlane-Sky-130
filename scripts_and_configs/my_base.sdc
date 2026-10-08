# ==============================================================================
# Synopsys Design Constraints (SDC): picorv32a
# Process: Sky130 PDK | Target Frequency: ~41.66 MHz (Period: 24.0 ns)
# ==============================================================================

current_design picorv32a

# Create primary system clock
create_clock [get_ports clk] -name clk -period 24.0000 -waveform {0.0000 12.0000}

# Clock Uncertainty (Jitter + Margin)
set_clock_uncertainty 0.2500 [get_clocks clk]

# Clock Transition (Slew on clock tree root)
set_clock_transition 0.1500 [get_clocks clk]

# Input Delays relative to clk
set_input_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports resetn]
set_input_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_ready]
set_input_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_rdata*]

# Output Delays relative to clk
set_output_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_valid]
set_output_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_instr]
set_output_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_addr*]
set_output_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_wdata*]
set_output_delay -clock [get_clocks clk] -add_delay 4.0000 [get_ports mem_wstrb*]

# Driving Cell for Inputs
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin Y [all_inputs]

# Maximum Output Load Capacitance
set_load -pin_load 0.0334 [all_outputs]

# Maximum Fanout Limit
set_max_fanout 4 [current_design]
set_max_transition 1.5 [current_design]
