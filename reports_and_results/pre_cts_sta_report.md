# Pre-CTS Static Timing Analysis Report

## Analysis Conditions
- **Analysis Tool**: OpenSTA (v2.3)
- **Target Design**: `picorv32a`
- **Timing Libraries**:
  - Slow Corner: `sky130_fd_sc_hd__slow.lib` (1.62V, 100°C)
  - Fast Corner: `sky130_fd_sc_hd__fast.lib` (1.98V, -40°C)
- **Target Clock Period**: 24.00 ns
- **Clock Uncertainty**: 0.25 ns

---

## 1. Baseline Pre-CTS Timing Results (Initial Run)

Prior to timing optimization, high fanout nets and large buffer chains resulted in negative slack:

| Parameter | Baseline Value | Status |
| :--- | :--- | :--- |
| **Worst Negative Slack (WNS)** | **-23.89 ns** | Violation (Setup Fail) |
| **Total Negative Slack (TNS)** | **-711.59 ns** | Violation |
| **Violating Endpoint Count** | 58 paths | Needs Optimization |
| **Worst Data Arrival Time** | 47.64 ns | Exceeds clock period |
| **Worst Data Required Time** | 23.75 ns | Target window |

---

## 2. Root Cause Analysis
1. **High Fanout Nets**: Certain internal control signals had fanouts exceeding 32, degrading input pin slews (transitions $> 2.8\,\text{ns}$).
2. **Suboptimal Cell Sizing**: High-load combinational gates were mapped to size-1 drive strength (`_1`), resulting in excessive gate delays.
3. **Capacitive Loading on Critical Datapath**: Register write-enable logic had cumulative capacitive load beyond optimal drive capability.

---

## 3. Timing Optimization Strategies Applied
To eliminate negative slack before Clock Tree Synthesis:
1. `set ::env(SYNTH_STRATEGY) "DELAY 3"`: Enforced delay-priority mapping in ABC synthesis.
2. `set ::env(SYNTH_SIZING) 1`: Enabled automatic standard cell up-sizing for high-load nets.
3. `set ::env(SYNTH_MAX_FANOUT) 4`: Constrained fanout to 4, forcing buffer tree insertion on high-fanout signals.

### Optimized Pre-CTS Results

| Parameter | Optimized Value | Status | Improvement |
| :--- | :--- | :--- | :--- |
| **Worst Negative Slack (WNS)** | **0.00 ns** | **MET (Clean)** | +23.89 ns |
| **Total Negative Slack (TNS)** | **0.00 ns** | **MET (Clean)** | +711.59 ns |
| **Violating Endpoints** | 0 | **PASSED** | 100% resolved |
