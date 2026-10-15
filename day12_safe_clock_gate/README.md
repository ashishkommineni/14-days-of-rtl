# Day 12 — Safe Clock-Gating Controller

## Problem this block solves

Clock trees switch every cycle and consume substantial dynamic power even when the logic they drive is idle. Clock gating stops those unnecessary transitions. A raw expression such as `gated_clk = clk & enable` is unsafe because `enable` can change while the clock is high and create a shortened pulse. This project captures the gate request only on the falling edge, so it remains constant throughout the next high phase.

## Specification

- `enable` requests functional clock activity.
- `scan_enable` forces the clock on for scan/test operation.
- The combined request is sampled on the falling edge of `clk`.
- `gated_clk = clk & gate_latched`.
- A request arriving during a high phase affects only the next complete pulse.
- Reset forces the gate closed.

The behavioral RTL models the safety rule. In an ASIC flow, synthesis should map it to a characterized integrated clock-gating (ICG) cell. In an FPGA, use the vendor clock-enable resources; do not route a fabric AND gate as a new clock.

## Internal timing intuition

The gate control is permitted to change only while the source clock is low. By the time the next rising edge arrives, the control is stable. The output can therefore contain either the whole high pulse or no pulse; it cannot contain only part of that pulse.

```text
clk          ___/‾‾‾\___/‾‾‾\___
enable       _____/‾‾‾‾‾‾‾\_____
gate_latched ________/‾‾‾‾\_____
gated_clk    __________/‾‾\_____
```

The exact drawn spacing is illustrative: the key point is that `gate_latched` changes at a falling edge and `gated_clk` changes only with source-clock edges.

## Verification strategy

The test deliberately changes functional and scan enables during the clock-high phase, then checks the request at the safe falling edge. An event monitor rejects any gated rising edge that occurs while the source is low. Directed cases cover enable, disable, scan override and mid-cycle changes. SVA checks that a source falling edge drives the gated clock low and that the captured request controls the following pulse.

```bash
make day DAY=12
```

## Industry use

ICG cells are used throughout CPUs, GPUs, DSPs, NoCs, peripheral clusters and always-on power-management logic. Industrial flows also run clock-gating checks, scan insertion checks, generated-clock constraints, minimum-pulse-width analysis, and power-aware verification.

## Common mistakes

The largest mistake is using a combinational AND gate with an unconstrained enable. Others are creating gated clocks in FPGA fabric, forgetting scan override, gating the clock that must release reset, treating a gated clock as ordinary data in timing constraints, and claiming power savings without switching-activity evidence.

## Ten interview questions and answers

1. **Why does clock gating save power?** Dynamic power is proportional to switching activity; stopping clock transitions prevents repeated charging of the clock tree and downstream registers.
2. **Why is `clk & enable` unsafe?** An enable transition during the high phase can produce a glitch or a pulse shorter than the library’s minimum width.
3. **How does an ICG cell avoid glitches?** It latches the enable while the clock is low and combines that stable value with the clock.
4. **Why include scan enable?** Scan shifting needs predictable clocks even when functional logic requests sleep.
5. **Should RTL instantiate a library cell?** Flows vary. Some code behavioral intent and infer gating; others instantiate a technology wrapper. The mapping must be reviewed.
6. **Is a gated clock a CDC?** It is related-clock behavior, but stopped/restarted clocks still need proper timing, reset and clock-control analysis.
7. **Why not use this structure directly on an FPGA?** FPGA clock networks provide dedicated buffers/enables; fabric-generated clocks can have skew and routing problems.
8. **What assertions are useful?** No gated high while source low, full-pulse behavior, stable gate control during high phase, and scan override coverage.
9. **How is power benefit measured?** Use realistic activity, post-synthesis/implementation capacitance, and a defined workload; do not infer savings only from RTL.
10. **What is the reset risk?** If reset release logic depends on a stopped clock, the domain may never initialize; reset and gate sequencing must be designed together.

## Spoken interview answer

“Clock gating reduces switching power, but a combinational AND can create runt pulses. I capture functional enable OR scan enable on the falling edge, so the control is fixed for the entire next high phase. In silicon I would map this behavior to an ICG cell and verify pulse integrity, test override, timing constraints and reset sequencing.”
