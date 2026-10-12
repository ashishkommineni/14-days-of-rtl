# Verification and publication status

The original `7-days-of-rtl` repository contains a separately documented seven-project regression. Do **not** transfer those results to this 14-day learning series.

## Current series
| Day | GitHub files | Simulator run | Status |
|---|---|---|---|
| 01–04 | Not published in this folder | Not run | Pending |
| 05 | RTL, self-checking TB, chapter README | Not run | Draft implementation |
| 06 | RTL, self-checking TB, external SVA, chapter README | Not run | Draft implementation |
| 07 | Not published | Not run | Pending |
| 08 | RTL, self-checking TB, external SVA, chapter README | Not run | Draft implementation |
| 09–14 | Not published | Not run | Pending |

The SystemVerilog simulator (Verilator/Icarus) is not installed in the working container at the time of these commits. Uploaded files are not yet regression-validated. Code and testbench review is not a substitute for simulation; perform lint, compile, directed/random regression, assertion execution and coverage collection before declaring any day verified.

## Example simulator commands
From the repository root with Verilator 5.x:
```bash
verilator --binary --timing --sv -Wall -Wno-fatal --top-module tb_programmable_timer \
  14-days-of-verilog-rtl/day05_counters_timers/rtl/programmable_timer.sv \
  14-days-of-verilog-rtl/day05_counters_timers/tb/tb_programmable_timer.sv
./obj_dir/Vtb_programmable_timer

verilator --binary --timing --sv -Wall -Wno-fatal --top-module tb_command_controller \
  14-days-of-verilog-rtl/day06_fsm_design/rtl/command_controller.sv \
  14-days-of-verilog-rtl/day06_fsm_design/tb/tb_command_controller.sv
./obj_dir/Vtb_command_controller

verilator --binary --timing --sv -Wall -Wno-fatal --top-module tb_pipelined_signed_mac \
  14-days-of-verilog-rtl/day08_signed_mac/rtl/pipelined_signed_mac.sv \
  14-days-of-verilog-rtl/day08_signed_mac/tb/tb_pipelined_signed_mac.sv
./obj_dir/Vtb_pipelined_signed_mac
```
