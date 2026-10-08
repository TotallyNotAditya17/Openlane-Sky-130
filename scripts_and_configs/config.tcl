# ==============================================================================
# OpenLANE Configuration for picorv32a with Custom Inverter Integration
# Design: picorv32a
# Process: SkyWater 130nm (sky130A)
# ==============================================================================

set ::env(DESIGN_NAME) "picorv32a"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock Configuration
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(CLOCK_PERIOD) "24.0"

# Synthesis Optimization & Strategies
set ::env(SYNTH_STRATEGY) "DELAY 3"
set ::env(SYNTH_SIZING) 1
set ::env(SYNTH_MAX_FANOUT) 4
set ::env(SYNTH_BUFFERING) 1

# Floorplan & Density Targets
set ::env(FP_CORE_UTIL) 50
set ::env(FP_ASPECT_RATIO) 1
set ::env(FP_IO_VMETAL) 3
set ::env(FP_IO_HMETAL) 4

# Placement Strategies
set ::env(PL_TARGET_DENSITY) 0.55
set ::env(PL_BASIC_PLACEMENT) 0

# Custom Standard Cell Integration (sky130_vsdinv)
set ::env(LIB_SYNTH)   "$::env(OPENLANE_ROOT)/designs/picorv32a/src/sky130_fd_sc_hd__typical.lib"
set ::env(LIB_FASTEST) "$::env(OPENLANE_ROOT)/designs/picorv32a/src/sky130_fd_sc_hd__fast.lib"
set ::env(LIB_SLOWEST) "$::env(OPENLANE_ROOT)/designs/picorv32a/src/sky130_fd_sc_hd__slow.lib"
set ::env(LIB_TYPICAL) "$::env(OPENLANE_ROOT)/designs/picorv32a/src/sky130_fd_sc_hd__typical.lib"

# Include custom LEF file from design src directory
set ::env(EXTRA_LEFS)  [glob $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/src/*.lef]

# CTS Configuration
set ::env(CTS_ROOT_BUFFER) "sky130_fd_sc_hd__clkbuf_16"
set ::env(CTS_CLK_BUFFERS) "sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"

# Routing Configuration
set ::env(ROUTING_STRATEGY) 0
set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(DIODE_INSERTION_STRATEGY) 3
