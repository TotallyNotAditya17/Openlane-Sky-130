# Digital VLSI SoC Design and Planning: Complete RTL-to-GDSII Flow

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![PDK: SkyWater 130nm](https://img.shields.io/badge/PDK-SkyWater_130nm-green.svg)](https://github.com/google/skywater-pdk)
[![Flow: OpenLANE](https://img.shields.io/badge/Flow-OpenLANE-orange.svg)](https://github.com/The-OpenROAD-Project/OpenLane)
[![Target Core: picorv32a](https://img.shields.io/badge/Core-RISC--V_picorv32a-red.svg)](https://github.com/cliffordwolf/picorv32)
[![DRC/LVS: Clean](https://img.shields.io/badge/Signoff-DRC%20%26%20LVS%20Clean-brightgreen.svg)](#)

> Complete physical design implementation and signoff of the 32-bit RISC-V `picorv32a` core using the **OpenLANE** automated ASIC flow and the **SkyWater 130nm (sky130A)** open-source Process Design Kit. Conducted as part of the **VSD (VLSI System Design)** and **NASSCOM FutureSkills Prime** SoC Design & Planning workshop.

---

## 📋 Table of Contents
1. [Overview & Silicon Architecture](#-overview--silicon-architecture)
2. [5-Day Physical Design Flow Summary](#-5-day-physical-design-flow-summary)
   - [Day 1: Inception of Open-Source EDA, OpenLANE & Sky130 PDK](#day-1-inception-of-open-source-eda-openlane--sky130-pdk)
   - [Day 2: Floorplanning & Standard Cell Placement](#day-2-floorplanning--standard-cell-placement)
   - [Day 3: Standard Cell Design & ngspice Characterization](#day-3-standard-cell-design--ngspice-characterization)
   - [Day 4: Custom Cell Integration, OpenSTA & Clock Tree Synthesis](#day-4-custom-cell-integration-opensta--clock-tree-synthesis)
   - [Day 5: Power Planning, TritonRoute Routing & GDSII Signoff](#day-5-power-planning-tritonroute-routing--gdsii-signoff)
3. [Final Physical & Timing Signoff Metrics](#-final-physical--timing-signoff-metrics)
4. [Repository File Hierarchy](#-repository-file-hierarchy)
5. [Reproducing the Flow](#-reproducing-the-flow)
6. [Acknowledgements & References](#-acknowledgements--references)

---

## 🏛 Overview & Silicon Architecture

The objective of this project is to take a high-performance 32-bit RISC-V microprocessor (`picorv32a`) from synthesizable Verilog RTL all the way to a tapeout-ready, DRC/LVS-clean GDSII stream file using a completely open-source semiconductor toolchain.

```
       +-------------------------------------------------------------+
       |                  picorv32a Verilog RTL                      |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Logic Synthesis: Yosys + ABC (Mapping to sky130_fd_sc_hd)   |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Floorplanning & Power Mesh: OpenROAD (50% Util, Aspect 1.0) |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Standard Cell Placement: RePlAce (Global) + OpenDP (Legal)  |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Custom Inverter Integration: sky130_vsdinv (LEF/LIB)        |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Clock Tree Synthesis: TritonCTS (H-Tree, 110 ps Skew)       |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Power Distribution Network: gen_pdn (VDD/VSS Rings & Straps)|
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Global & Detailed Routing: FastRoute + TritonRoute (met1-5) |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Parasitic Extraction & STA: OpenRCX (SPEF) + OpenSTA        |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | Physical Verification & Streaming: Magic DRC & GDSII Stream |
       +-------------------------------------------------------------+
```

---

## 📅 5-Day Physical Design Flow Summary

Detailed day-by-day technical lab guides, theory, and step-by-step instructions are available in the [`days/`](days/) directory:

### Day 1: Inception of Open-Source EDA, OpenLANE & Sky130 PDK
*Read the full Day 1 documentation: [DAY1_INCEPTION_OPENLANE_SKY130.md](days/DAY1_INCEPTION_OPENLANE_SKY130.md)*

- **Software to Hardware Hierarchy**: From application code to RISC-V instructions, register-transfer logic, and physical transistors.
- **Package, Die, Core & Pads**: Structural understanding of wire bonding, core logic regions, foundry IPs (PLL, SRAM), and digital macros.
- **OpenLANE Execution**: Launched OpenLANE interactive container session via `./flow.tcl -interactive` and prepared `picorv32a` with `prep -design picorv32a`.
- **Synthesis Analysis & Flop Ratio**:
  - Total standard cell count: **15,762 cells**
  - Sequential flip-flop count (`sky130_fd_sc_hd__dfxtp_2`): **1,613 flops**
  - **Flop Ratio**:
    $$\text{Flop Ratio} = \frac{1613}{15762} = 0.1023 \approx \mathbf{10.23\%}$$

---

### Day 2: Floorplanning & Standard Cell Placement
*Read the full Day 2 documentation: [DAY2_FLOORPLAN_AND_PLACEMENT.md](days/DAY2_FLOORPLAN_AND_PLACEMENT.md)*

- **Core & Die Configuration**: Set core utilization to $50\%$ and aspect ratio to $1.0$ (square die) to ensure symmetrical delay profiles.
- **Decoupling Capacitors & Tap Cells**: Decoupling capacitors placed adjacent to switching boundaries to prevent ground bounce ($L \cdot \frac{di}{dt}$); well-tap cells inserted at regular intervals to prevent CMOS latchup.
- **Power Planning**: Configured power rings encircling the core on upper metals with orthogonal power mesh straps.
- **Floorplan & Placement Execution**:
  - `run_floorplan`: Generated `picorv32a.floorplan.def` and verified pad pin locations and blockage borders in Magic.
  - `run_placement`: Performed global wirelength optimization and legalized cell placement with zero overlaps.

---

### Day 3: Standard Cell Design & ngspice Characterization
*Read the full Day 3 documentation: [DAY3_LIBRARY_CELL_MAGIC_NGSPICE.md](days/DAY3_LIBRARY_CELL_MAGIC_NGSPICE.md)*

- **CMOS Inverter Sizing**: Sized PMOS width ($W_p = 0.37\,\mu\text{m}$) larger than NMOS width ($W_n = 0.35\,\mu\text{m}$) to compensate for carrier mobility asymmetry ($\mu_n \approx 2.5\mu_p$).
- **16-Mask CMOS Fabrication Sequence**: Studied active region creation, well implants, gate oxide deposition, LDD formation, silicidation, and metallization.
- **DRC Rule Correction**: Identified and rectified the `poly.9` spacing violation in the Magic `sky130A.tech` file for sub-$0.48\,\mu\text{m}$ poly-to-contact spacing.
- **SPICE Extraction & Transient Simulation**:
  - Extracted parasitic capacitances using `extract all` and `ext2spice`.
  - Ran transient simulation (`tran 10p 2.5n`) in ngspice using [`scripts_and_configs/sky130_inv.spice`](scripts_and_configs/sky130_inv.spice).
- **Dynamic Timing Characterization**:
  - **Rise Transition Time ($\tau_r$, 20% to 80%)**: **$64\,\text{ps}$**
  - **Fall Transition Time ($\tau_f$, 80% to 20%)**: **$42\,\text{ps}$**
  - **Propagation Delay $t_{pHL}$**: **$22\,\text{ps}$**
  - **Propagation Delay $t_{pLH}$**: **$64\,\text{ps}$**

---

### Day 4: Custom Cell Integration, OpenSTA & Clock Tree Synthesis
*Read the full Day 4 documentation: [DAY4_STA_TIMING_AND_CTS.md](days/DAY4_STA_TIMING_AND_CTS.md)*

- **Physical Grid Alignment & LEF Extraction**: Aligned standard cell ports to routing grid track intersections (`tracks.info` pitch of $0.46\,\mu\text{m} \times 0.34\,\mu\text{m}$) and exported [`scripts_and_configs/sky130_vsdinv.lef`](scripts_and_configs/sky130_vsdinv.lef).
- **OpenLANE Flow Integration**: Modified [`scripts_and_configs/config.tcl`](scripts_and_configs/config.tcl) to link custom LEF and Liberty files into `picorv32a`, verifying seamless cell placement and abutment in Magic.
- **Pre-CTS Static Timing Analysis**:
  - Analyzed baseline setup violations ($\text{WNS} = -23.89\,\text{ns}$) caused by high fanout nets.
  - Applied fanout constraints (`SYNTH_MAX_FANOUT 4`) and buffer sizing, achieving **$0.00\,\text{ns}$ WNS (timing clean)**.
- **Clock Tree Synthesis (TritonCTS)**:
  - Built an H-Tree clock distribution network with balanced buffer chains (`run_cts`).
  - Executed post-CTS OpenROAD analysis with propagated clocks (`set_propagated_clock [all_clocks]`).
  - Achieved clock skew of **$110\,\text{ps}$** and positive slack on all endpoints.

---

### Day 5: Power Planning, TritonRoute Routing & GDSII Signoff
*Read the full Day 5 documentation: [DAY5_ROUTING_SPEF_GDSII_SIGNOFF.md](days/DAY5_ROUTING_SPEF_GDSII_SIGNOFF.md)*

- **Power Distribution Grid Synthesis**: Synthesized orthogonal power mesh straps and standard cell rails with `gen_pdn`.
- **Global & Detailed Routing**:
  - FastRoute generated routing congestion guides.
  - TritonRoute routed all signal interconnects across metal layers `met1` through `met5` with automated antenna diode insertion.
- **Parasitic Extraction (SPEF)**: Extracted full interconnect resistance and capacitance per wire segment with OpenRCX to generate `picorv32a.spef`.
- **Post-Route STA Signoff**: Verified final timing with extracted parasitics in OpenSTA:
  - **Worst Setup Slack**: **$+2.942\,\text{ns}$ (MET)**
  - **Worst Hold Slack**: **$+0.184\,\text{ns}$ (MET)**
  - **Maximum Frequency**: **$47.48\,\text{MHz}$**
- **Physical Signoff**: Verified zero Magic DRC violations, verified LVS with Netgen, and streamed out the final tapeout layout: `picorv32a.gds`.

---

## 📊 Final Physical & Timing Signoff Metrics

| Metric / Parameter | Value | Signoff Target | Status |
| :--- | :--- | :--- | :--- |
| **Technology Node** | SkyWater 130nm (`sky130A`) | 130nm Standard | Supported |
| **Die Dimensions** | $380\,\mu\text{m} \times 388\,\mu\text{m}$ | $< 400\,\mu\text{m} \times 400\,\mu\text{m}$ | **Passed** |
| **Core Dimensions** | $340\,\mu\text{m} \times 340\,\mu\text{m}$ | - | **Passed** |
| **Total Standard Cells** | 15,762 cells | - | Verified |
| **Sequential Flip-Flops** | 1,613 flops | - | Verified |
| **Flop Ratio** | 10.23% | 10.0% - 15.0% | **Optimal** |
| **Target Clock Period** | 24.00 ns (41.67 MHz) | 24.00 ns | **Met** |
| **Post-Route Setup Slack (WNS)** | **+2.942 ns** | $\ge 0.00\,\text{ns}$ | **Passed (Clean)** |
| **Post-Route Hold Slack** | **+0.184 ns** | $\ge 0.00\,\text{ns}$ | **Passed (Clean)** |
| **Clock Skew** | **110 ps** | $< 250\,\text{ps}$ | **Passed** |
| **Magic DRC Violations** | **0** | 0 | **100% Clean** |
| **Netgen LVS Mismatches** | **0** | 0 | **100% Matched** |
| **Final Layout Stream** | `picorv32a.gds` | GDSII Stream Format | **Tapeout Ready** |

---

## 📂 Repository File Hierarchy

```
soc-design-and-planning-vsd/
├── README.md                           # Master Project Overview (This Document)
│
├── days/                               # In-Depth Day-by-Day Lab Modules
│   ├── DAY1_INCEPTION_OPENLANE_SKY130.md   # OpenLANE flow, Docker setup, synthesis & flop ratio
│   ├── DAY2_FLOORPLAN_AND_PLACEMENT.md     # Core utilization, decaps, power mesh, cell placement
│   ├── DAY3_LIBRARY_CELL_MAGIC_NGSPICE.md  # Custom inverter layout, DRC fixes, ngspice characterization
│   ├── DAY4_STA_TIMING_AND_CTS.md          # LEF generation, OpenSTA timing optimization, TritonCTS
│   └── DAY5_ROUTING_SPEF_GDSII_SIGNOFF.md  # PDN, TritonRoute routing, SPEF extraction, GDSII signoff
│
├── scripts_and_configs/                # Execution Scripts & EDA Configuration Files
│   ├── config.tcl                      # Modified OpenLANE design configuration deck
│   ├── sky130_inv.spice                # Transient simulation SPICE deck for ngspice
│   ├── sky130_vsdinv.lef               # Physical standard cell LEF definition
│   ├── pre_sta.conf                    # OpenSTA configuration file for pre-CTS timing analysis
│   ├── my_base.sdc                     # Synopsys Design Constraints (SDC) file
│   └── post_route_sta.conf             # Post-route OpenSTA configuration file with SPEF
│
├── reports_and_results/                # Synthesis, CTS, and Routing Signoff Summaries
│   ├── synthesis_metrics.md            # Detailed cell gate counts and area breakdown
│   ├── pre_cts_sta_report.md           # Pre-CTS slack optimization and fanout report
│   ├── post_cts_sta_report.md          # Clock tree skew, insertion delay, and buffer counts
│   └── post_route_timing_summary.md    # Post-route SPEF back-annotated timing signoff
│
└── images/                             # Lab Execution Screenshots & Silicon Layout Images
    ├── 01_syn.png ... 04_syn3.png      # Day 1: OpenLANE invocation and synthesis reports
    ├── 05_floorplan.png ... 14_placement3.png # Day 2: Floorplan and placement layouts
    ├── 15_day3.png ... 54_sky18.png    # Day 3: Magic inverter layout, DRC fixes, ngspice plots
    ├── 55_day4.1.png ... 82_cts6.png   # Day 4: LEF generation, OpenSTA, TritonCTS results
    └── 83_rout1.png ... 86_rout4.png   # Day 5: PDN generation, routing logs, routed layout
```

---

## ⚡ Reproducing the Flow

To reproduce this complete physical design run from scratch inside the OpenLANE Docker environment:

```bash
# 1. Mount OpenLANE Docker container
cd /OpenLane
make mount

# 2. Launch interactive flow
./flow.tcl -interactive
package require openlane 1.0.2

# 3. Prepare picorv32a design
prep -design picorv32a

# 4. Integrate custom LEF
set lefs [glob $::env(DESIGN_DIR)/src/*.lef]
add_lefs -src $lefs

# 5. Execute Logic Synthesis
run_synthesis

# 6. Execute Floorplanning
run_floorplan

# 7. Execute Standard Cell Placement
run_placement

# 8. Execute Clock Tree Synthesis
run_cts

# 9. Generate Power Distribution Network
gen_pdn

# 10. Execute Detailed Routing
run_routing

# 11. Stream Out Final GDSII Layout
run_magic
```

---

## 🤝 Acknowledgements & References

- **Kunal Ghosh** — Co-founder, VLSI System Design (VSD) Corp. Pvt. Ltd., for instructor guidance throughout the workshop.
- **Nickson P Jose** — Physical Design Engineer, Intel, for the `vsdstdcelldesign` reference standard cell layout.
- **NASSCOM FutureSkills Prime** — For facilitating this open-source semiconductor physical design initiative.
- [OpenLANE Flow Documentation](https://openlane.readthedocs.io/)
- [SkyWater 130nm PDK Documentation](https://skywater-pdk.readthedocs.io/)
- [The OpenROAD Project](https://theopenroadproject.org/)
- [Magic VLSI Layout Tool](http://opencircuitdesign.com/magic/)
- [PicoRV32 RISC-V Core](https://github.com/cliffordwolf/picorv32)
