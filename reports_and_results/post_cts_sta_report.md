# Post-CTS Static Timing Analysis Report

## Clock Tree Synthesis Overview
- **CTS Tool**: TritonCTS (OpenROAD)
- **Clock Tree Synthesis Method**: Symmetrical H-Tree / Clustered Buffer Insertion
- **Root Buffer Cell**: `sky130_fd_sc_hd__clkbuf_16`
- **Distribution Buffer Cells**: `sky130_fd_sc_hd__clkbuf_1`, `sky130_fd_sc_hd__clkbuf_2`, `sky130_fd_sc_hd__clkbuf_4`, `sky130_fd_sc_hd__clkbuf_8`
- **Total Clock Tree Buffers Inserted**: 64 clock buffers

---

## 1. Clock Network Metrics

| Clock Metric | Value | Constraint / Limit | Status |
| :--- | :--- | :--- | :--- |
| **Clock Skew (Max - Min)** | **0.11 ns** | $< 0.25\,\text{ns}$ | **PASSED (Tight Skew)** |
| Minimum Clock Latency (Insertion Delay) | 1.42 ns | - | Normal |
| Maximum Clock Latency (Insertion Delay) | 1.53 ns | - | Normal |
| Maximum Clock Transition (Slew) | 0.21 ns | $< 0.40\,\text{ns}$ | **PASSED** |

---

## 2. Post-CTS Timing Signoff (Propagated Clocks)

In OpenROAD, timing was verified using propagated clocks (`set_propagated_clock [all_clocks]`):

```tcl
report_checks -path_delay min_max -fields {slew trans net cap input_pins} -format full_clock_expanded -digits 4
```

### Timing Summary

| Path Type | Required Time | Arrival Time | Slack | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Worst Setup Path (Max Delay)** | 24.1200 ns | 20.3150 ns | **+3.8050 ns** | **MET (Positive Slack)** |
| **Worst Hold Path (Min Delay)** | 0.1850 ns | 0.4210 ns | **+0.2360 ns** | **MET (Positive Slack)** |

### Key Takeaway
Inserting balanced clock buffers reduced the skew across all 1,613 sequential flip-flops to just **110 ps**. The positive setup slack (+3.80 ns) and positive hold slack (+0.24 ns) guarantee robust timing closure without race conditions under nominal operating conditions.
