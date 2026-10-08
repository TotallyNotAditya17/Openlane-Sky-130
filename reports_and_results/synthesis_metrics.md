# Synthesis Metrics & Design Statistics Report

## Design Overview
- **Design Name**: `picorv32a` (RISC-V 32-bit Integer Processor Core)
- **Technology Node**: SkyWater 130nm (`sky130A`)
- **Standard Cell Library**: `sky130_fd_sc_hd` (High Density)
- **Target Clock Period**: 24.0 ns (Frequency: 41.67 MHz)
- **Synthesis Tool**: Yosys 0.9 + ABC

---

## 1. Gate-Level Cell Distribution

| Metric / Cell Category | Count | Percentage of Total Cells |
| :--- | :--- | :--- |
| **Total Number of Cells** | **14,876** | 100.00% |
| Sequential Cells (`dfxtp_2`) | 1,613 | 10.84% |
| Combinational Logic Gates | 13,263 | 89.16% |
| Buffers & Inverters | 2,145 | 14.42% |
| Logic AND / OR / XOR Gates | 7,890 | 53.04% |
| Complex AOI / OAI Cells | 3,228 | 21.70% |

---

## 2. Flop Ratio Calculation

The **Flop Ratio** is a key sanity indicator in digital SoC physical design that represents the sequential density of the synthesized logic:

$$\text{Flop Ratio} = \frac{\text{Total Sequential Cells (D Flip-Flops)}}{\text{Total Cell Count}}$$

Substituting synthesis results:

$$\text{Flop Ratio} = \frac{1,613}{14,876} \approx 0.1084 \quad (\mathbf{10.84\%})$$

*(For typical RISC-V compute cores with single-cycle/multi-cycle pipelines, a flop ratio between 10% and 15% is standard).*

---

## 3. Physical Area Breakdown

| Area Parameter | Synthesized Metric | Unit |
| :--- | :--- | :--- |
| Chip Core Area | 147,712.83 | $\mu\text{m}^2$ |
| Cell Logic Area | 93,654.12 | $\mu\text{m}^2$ |
| Core Utilization Target | 50.0 | % |
| Actual Post-Synth Utilization | 63.4 | % |
| Aspect Ratio ($H/W$) | 1.0 (Square Die) | - |
