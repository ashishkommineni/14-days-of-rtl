# 14 Days of Verilog/RTL — Concepts and Interview Series

This **14-day concept-and-interview series** lives separately from the seven independent RTL project builds at the repository root.

| Day | Topic | GitHub publication |
|---:|---|---|
| 01 | RTL/module and synthesizable foundations | Pending |
| 02 | Blocking vs nonblocking assignments and races | Pending |
| 03 | Combinational logic and latch avoidance | Pending |
| 04 | Flip-flops, reset and clock enables | Pending |
| 05 | [Counters, timers, frequency dividers](day05_counters_timers/) | **RTL + self-checking TB + chapter summary** |
| 06 | [FSM design and verification](day06_fsm_design/) | **RTL + self-checking TB + SVA + chapter summary** |
| 07 | Parameters, generate blocks and reusable RTL | Pending |
| 08 | [Signed arithmetic and pipelined MAC](day08_signed_mac/) | **RTL + self-checking TB + SVA + chapter summary** |
| 09 | Memories, register files and byte enables | Pending |
| 10 | Ready/valid, skid buffers and synchronous FIFO | Pending |
| 11 | Priority and round-robin arbitration | Pending |
| 12 | CDC, pulse synchronizers, Gray code and asynchronous FIFO | Pending |
| 13 | Self-checking TB, assertions and functional coverage | Pending |
| 14 | Capstone RTL and verification interview round | Pending |

## Key files
- [Day 05 RTL timer](day05_counters_timers/rtl/programmable_timer.sv)
- [Day 05 self-checking testbench](day05_counters_timers/tb/tb_programmable_timer.sv)
- [Day 06 RTL FSM](day06_fsm_design/rtl/command_controller.sv)
- [Day 06 self-checking testbench](day06_fsm_design/tb/tb_command_controller.sv)
- [Day 06 assertions](day06_fsm_design/assertions/command_controller_sva.sv)
- [Day 08 signed pipelined MAC](day08_signed_mac/rtl/pipelined_signed_mac.sv)
- [Day 08 self-checking testbench](day08_signed_mac/tb/tb_pipelined_signed_mac.sv)
- [Day 08 assertions](day08_signed_mac/assertions/pipelined_mac_sva.sv)
- [Verification and publication status](docs/verification_status.md)

## Scope and honesty
The chat contains detailed long-form articles and ten answered interview questions for Days 05, 06, and 08, but the committed chapter READMEs are condensed, not full transcripts. A complete 14-day portfolio **has not yet been published**. Do not claim the HDL is regression-verified without simulator output. The associated existing seven-project repository has separate regression evidence, which does not verify these newly added files.

The intended finished standard for each day is a detailed conceptual article, engineering spec, synthesizable RTL, self-checking testbench, SVA, functional coverage, expected output, and exactly 10 fully answered interview questions.
