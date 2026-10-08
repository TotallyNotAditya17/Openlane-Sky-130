# Day 5: Final RTL to GDSII Flow: Routing, SPEF Extraction, Post-Route STA & Physical Signoff

---

## 1. Theoretical Foundations

### 1.1 Power Distribution Network (PDN) Synthesis
Before signal routing can occur, a robust power distribution grid must be generated across the placed design.
- **Power Rails**: Standard cell rows share continuous horizontal $V_{\text{DD}}$ and $V_{\text{SS}}$ power rails on `met1`.
- **Power Straps**: Wider, low-resistance vertical straps on `met4` and horizontal straps on `met5` form a regular orthogonal mesh across the core.
- **Standard Cell Connections**: Vias connect the top metal straps through intermediate metal layers down to the standard cell rails on `met1`.
- This ensures maximum IR drop across any point of the chip remains well below the $5\%$ limit of nominal supply voltage.

---

### 1.2 Routing Mechanics: Global Routing vs. Detailed Routing
Routing converts logical netlist connections into physical metal wire segments and vias:

1. **Global Routing (FastRoute)**:
   - Partitions the chip into a grid of 3D routing regions (**G-cells**).
   - Solves a multi-commodity flow problem to assign each net to a sequence of G-cells, avoiding congested regions and respecting layer pitch and capacity limits.
   - Outputs **routing guides** for detailed routing.

2. **Detailed Routing (TritonRoute)**:
   - Operates within the bounding guides produced by FastRoute.
   - Assigns actual physical tracks, metal layers (`met1` to `met5`), and via geometries.
   - Adheres strictly to Design Rule Checking (DRC) constraints:
     - Minimum wire width and minimum spacing rules.
     - Via enclosure and end-of-line spacing rules.
     - Non-default routing rules for clock and critical nets.
     - Antenna rule mitigation (charge accumulation during plasma etching).

---

### 1.3 Parasitic Extraction (SPEF) & Signoff Timing
- In deep submicron nodes like Sky130, wire interconnect delay dominates intrinsic gate delay.
- **OpenRCX / SPEF Extractor** analyzes the exact 3D geometric shapes of all routed metal wires and dielectric layers, generating a **Standard Parasitic Exchange Format (SPEF)** file.
- The SPEF file contains:
  - Distributed wire resistance values ($R_{\text{wire}}$ per segment).
  - Ground capacitance ($C_{\text{gnd}}$).
  - Cross-coupling capacitances between adjacent parallel wires ($C_{\text{couple}}$).
- **Post-Route STA** reads this SPEF file into OpenSTA to back-annotate real parasitics, calculating final setup and hold timing slacks.

---

### 1.4 Physical & Electrical Verification (DRC, LVS, GDSII)
1. **DRC (Design Rule Check)**: Magic checks every polygon in the final layout against foundry manufacturing rules (spacing, width, enclosure, overlap).
2. **LVS (Layout Versus Schematic)**: Netgen extracts a SPICE netlist from the physical layout polygons and compares its electrical graph against the post-synthesis gate-level Verilog netlist to ensure topological equivalence.
3. **GDSII Stream**: The standard binary format representing planar geometric shapes, text labels, and layer hierarchy for mask fabrication.

---

## 2. Lab Walkthrough: Executing the Final RTL-to-GDSII Steps

### 2.1 Generating the Power Distribution Network (PDN)
In the interactive OpenLANE prompt:

```tcl
gen_pdn
```

OpenLANE creates the power grid straps and rails, writing the updated DEF file to `designs/picorv32a/runs/<run_tag>/tmp/floorplan/17-pdn.def`.

Inspect the PDN layout in Magic:

```bash
cd results/floorplan/
magic -T /OpenLane/pdks/sky130A/libs.tech/magic/sky130A.tech \
      lef read ../../tmp/merged.nom.lef \
      def read 17-pdn.def &
```

---

### 2.2 Detailed Routing with TritonRoute

Execute detailed routing:

```tcl
run_routing
```

During execution, TritonRoute performs:
- Routing guide validation.
- FastRoute global routing optimizations.
- Detailed routing across metal layers `met1` through `met5`.
- Antenna diode insertion and repair iterations.
- Standard cell fill insertion to ensure uniform oxide planarization.

Inspect the routed silicon layout in Magic:

```bash
cd results/routing/
magic -T /OpenLane/pdks/sky130A/libs.tech/magic/sky130A.tech \
      lef read ../../tmp/merged.nom.lef \
      def read picorv32a.def &
```

Zoom into the routed layout to verify:
- Dense signal routing tracks across metal layers.
- Seamless power rails and decap fill cells (`FILLER_*`).
- Antenna protection diodes inserted on sensitive gate inputs.
- Active green DRC indicator in Magic confirming **0 Design Rule Violations**.

---

### 2.3 Post-Route Parasitic Extraction (SPEF Extraction)
Execute parasitic extraction using the standalone SPEF extractor:

```bash
cd /OpenLane/SPEF_EXTRACTOR
python3 main.py \
  /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/tmp/merged.nom.lef \
  /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/results/routing/picorv32a.def
```

This generates `picorv32a.spef` in the routing results directory.

---

### 2.4 Post-Route Timing Signoff with OpenSTA
Launch OpenROAD/OpenSTA to verify timing closure with extracted interconnect parasitics:

```tcl
openroad

read_lef /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/tmp/merged.nom.lef
read_def /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/results/routing/picorv32a.def
read_verilog /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/results/routing/picorv32a.routed.v
read_liberty $::env(LIB_SYNTH_COMPLETE)
link_design picorv32a
read_sdc /OpenLane/designs/picorv32a/src/my_base.sdc

# Enable propagated clock mode
set_propagated_clock [all_clocks]

# Read extracted wire parasitics
read_spef /OpenLane/designs/picorv32a/runs/RUN_2026.03.24_15.13.57/results/routing/picorv32a.spef

# Perform full timing check
report_checks -path_delay min_max -fields {slew trans net cap input_pins} -format full_clock_expanded -digits 4
report_wns
report_tns
```

#### Final Post-Route Timing Results
- **Worst Negative Slack (WNS)**: `0.00 ns` (Setup Slack: `+2.942 ns`)
- **Total Negative Slack (TNS)**: `0.00 ns`
- **Hold Slack**: `+0.184 ns`
- **Clock Slew**: `0.235 ns`
- **Status**: **100% Timing Closure Achieved**

---

### 2.5 Final GDSII Generation & Signoff
Stream out the final manufacturable GDSII file using Magic:

```tcl
run_magic
```

Or execute directly in Magic:

```bash
magic -dnull -noconsole << EOF
drc off
box 0 0 0 0
gds readonly true
gds rescale false
gds read ../../tmp/merged.nom.lef
def read picorv32a.def
writeall force picorv32a
gds write picorv32a.gds
exit
EOF
```

The resulting file, `picorv32a.gds`, is the final taped-out layout ready for submission to the SkyWater 130nm open-source shuttle.
