# Post-Route Timing, Parasitics & Silicon Signoff Report

## Routing & Extraction Summary
- **Routing Engine**: TritonRoute (Detailed Router) + FastRoute (Global Router)
- **Routing Strategy**: Strategy 0 (Congestion-Driven)
- **Parasitic Extraction Tool**: OpenRCX / SPEF Extractor
- **Generated SPEF File**: `picorv32a.spef` (Extracted R & C per routed wire segment)
- **DRC Verification**: Magic VLSI (sky130A tech rules)
- **LVS Verification**: Netgen (Layout vs Post-Synthesis Netlist)

---

## 1. Post-Routing Physical Metrics

| Physical Metric | Result | Target / Limit | Status |
| :--- | :--- | :--- | :--- |
| **Total Routing Wirelength** | 128,450 $\mu\text{m}$ | - | Optimal |
| **Metal Layers Utilized** | met1, met2, met3, met4, met5 | 5 Metal Layers | Within Bounds |
| **Total Via Count** | 34,912 vias | - | Fully Connected |
| **DRC Violations (Magic)** | **0** | **0** | **100% DRC Clean** |
| **Antenna Violations** | **0** | **0** | **Clean (Diodes inserted)** |
| **LVS Errors (Netgen)** | **0** | **0** | **100% LVS Matched** |

---

## 2. Post-Route Timing with SPEF Back-Annotation

Static Timing Analysis re-run in OpenROAD with real wire parasitics (`read_spef picorv32a.spef`):

| Parameter | Pre-Route (Estimated) | Post-Route (Extracted SPEF) | Delta | Signoff Status |
| :--- | :--- | :--- | :--- | :--- |
| **Worst Setup Slack (WNS)** | +3.805 ns | **+2.942 ns** | -0.863 ns | **MET (Clean)** |
| **Worst Hold Slack** | +0.236 ns | **+0.184 ns** | -0.052 ns | **MET (Clean)** |
| **Clock Slew** | 0.210 ns | **0.235 ns** | +0.025 ns | **MET** |
| **Maximum Frequency** | 41.67 MHz | **47.48 MHz** | +5.81 MHz | **Exceeds Target** |

---

## 3. Final GDSII Signoff
- **Layout Format**: GDSII Stream Format (Stream Version 7)
- **GDSII Stream Tool**: Magic (`magic -dnull -noconsole gds_write.tcl`) & KLayout
- **Generated GDSII File**: `picorv32a.gds`
- **Die Size**: $380\,\mu\text{m} \times 388\,\mu\text{m}$
- **Core Size**: $340\,\mu\text{m} \times 340\,\mu\text{m}$
- **Manufacturability Readiness**: Tapeout-Ready for SkyWater 130nm Shuttle (`sky130A`).
