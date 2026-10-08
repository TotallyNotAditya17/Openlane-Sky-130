# Day 1: Inception of Open-Source EDA, OpenLANE & Sky130 PDK

---

## 1. Theoretical Foundations

### 1.1 The Software-to-Hardware Execution Hierarchy
Every software application executing on a physical chip must pass through multiple layers of abstraction before it can be represented as physical electrical transitions on silicon:

```
+-------------------------------------------------------+
| Application Code (C / C++ / Python)                  |
+-------------------------------------------------------+
                           |
                           v  (Compiler: GCC / Clang)
+-------------------------------------------------------+
| Target ISA Assembly (RISC-V RV32I / RV64I)            |
+-------------------------------------------------------+
                           |
                           v  (Assembler & Linker)
+-------------------------------------------------------+
| Machine Code (Binary Bitstreams: 32-bit Words)       |
+-------------------------------------------------------+
                           |
                           v  (Hardware Execution)
+-------------------------------------------------------+
| Hardware Description Language (RTL: Verilog / VHDL)   |
+-------------------------------------------------------+
                           |
                           v  (Logic Synthesis: Yosys + ABC)
+-------------------------------------------------------+
| Gate-Level Netlist (Mapped to Standard Cells)         |
+-------------------------------------------------------+
                           |
                           v  (Physical Design: OpenLANE / PnR)
+-------------------------------------------------------+
| Physical Silicon Layout (GDSII Stream File)           |
+-------------------------------------------------------+
```

1. **Instruction Set Architecture (ISA)**: The functional contract defining instruction encoding, register files, and execution semantics (e.g., RISC-V RV32I).
2. **Register Transfer Level (RTL)**: Digital hardware description specifying data registers and combinational transfers between clock edges.
3. **PDK (Process Design Kit)**: The technological foundation containing foundry-specific device models, DRC/LVS rules, SPICE simulation files, and standard cell physical LEF/LIB data.

---

### 1.2 Package, Die, Core, and I/O Pads
When observing a physical semiconductor device on a printed circuit board (PCB):
- **Package**: The protective plastic or ceramic encapsulation (e.g., QFN-48) preventing environmental degradation and facilitating board mounting.
- **Bond Wires**: Microscopic gold or copper wires connecting physical package pins to the on-die pads.
- **Pads**: The peripheral metal landing pads that buffer external signals entering or leaving the silicon.
- **Core**: The internal rectangular bounding area where digital standard cells, clock trees, and macros reside.
- **Die**: The complete continuous silicon block comprising the core, power rings, and peripheral I/O pad ring.
- **Foundry IPs vs. Macros**:
  - *Foundry IPs*: Specialized mixed-signal or analog silicon blocks that require foundry fabrication know-how (e.g., PLL, ADC/DAC, SRAM).
  - *Macros*: Reusable, purely digital synthesis blocks (e.g., SPI controller, UART block, RISC-V core).

---

### 1.3 OpenLANE Architecture & Toolchain Flow
OpenLANE is an automated open-source RTL-to-GDSII flow developed by Efabless that orchestrates multiple independent EDA tools:

| Design Stage | Tool Implemented | Purpose / Output |
| :--- | :--- | :--- |
| **Logic Synthesis** | Yosys + ABC | Translates RTL into gate-level netlist; optimizes logic |
| **Floorplanning & PDN**| OpenROAD | Defines core/die dimensions, pin locations, and power grid |
| **Placement** | OpenROAD (RePlAce, OpenDP)| Global placement & detailed legalization of standard cells |
| **Clock Tree (CTS)** | TritonCTS | Synthesizes balanced clock distribution tree |
| **Global Routing** | FastRoute | Estimates routing congestion and generates routing guides |
| **Detailed Routing** | TritonRoute | Performs DRC-clean metal wire and via assignments |
| **SPEF Extraction** | OpenRCX | Extracts parasitic resistance and capacitance from wires |
| **Timing Signoff** | OpenSTA | Static timing analysis under multiple PVT corners |
| **Physical Signoff** | Magic & KLayout | GDSII layout generation and DRC rule verification |
| **Electrical Signoff**| Netgen | Layout Versus Schematic (LVS) verification |

---

## 2. Lab Execution: Invoking OpenLANE & Synthesizing `picorv32a`

### 2.1 Launching the Interactive Docker Environment
OpenLANE operates within a pre-configured Docker container containing all EDA tool binaries and the SkyWater 130nm PDK.

```bash
# Navigate to the OpenLANE root directory
cd /OpenLane

# Mount the working container
make mount

# Launch OpenLANE in interactive shell mode
./flow.tcl -interactive

# Load the required OpenLANE package
package require openlane 1.0.2
```

---

### 2.2 Design Preparation
Before logic synthesis, the design workspace must be created, and standard cell library LEF files merged:

```tcl
# Prepare the picorv32a design workspace
prep -design picorv32a
```

This creates a dedicated timestamped run folder under `designs/picorv32a/runs/` and produces the consolidated `merged.nom.lef` technology file.

---

### 2.3 Executing Logic Synthesis
Logic synthesis is triggered using:

```tcl
run_synthesis
```

During this stage:
1. `Yosys` elaborates the Verilog RTL.
2. Logic is technology-mapped to the SkyWater 130nm High-Density (`sky130_fd_sc_hd`) standard cell library via `ABC`.
3. An initial static timing estimate is reported.

---

## 3. Results Analysis & Metric Characterization

From the synthesis log file (`runs/<run_tag>/reports/synthesis/1-yosys_4.stat.rpt`):

### 3.1 Flop Ratio Calculation
The **Flop Ratio** quantifies the sequential cell density relative to total gates:

$$\text{Flop Ratio} = \frac{\text{Number of D Flip-Flops}}{\text{Total Standard Cell Count}}$$

From the synthesis output report:
- **D Flip-Flop Count (`sky130_fd_sc_hd__dfxtp_2`)**: 1,613
- **Total Standard Cell Count**: 15,762

$$\text{Flop Ratio} = \frac{1613}{15762} = 0.1023 \implies \mathbf{10.23\%}$$

### 3.2 Cell Area Summary
- **Total Silicon Gate Area**: $147,712.83\,\mu\text{m}^2$
- **Buffer Count**: 1,650
- **Combinational Gate Count**: 14,149
- **Synthesis Slack**: Clean timing within initial synthesis constraints.
