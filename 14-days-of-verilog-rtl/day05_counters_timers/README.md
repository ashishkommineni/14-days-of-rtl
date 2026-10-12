# Day 05 — Counters, Timers and Frequency Dividers

## Problem and motivation
A modulo-N timer measures enabled source-clock edges, generates periodic event pulses, and optionally toggles an observed square-wave output. Counters appear in UART baud generators, watchdogs, retry engines, packet timers and FSM timeouts. Keeping a slow **enable** in the original clock domain is normally preferable to fabric-generated clocks.

## Mathematical design
A modulo-N counter visits 0 through N-1: it has **N** states, not N+1. The minimum width is max(1,ceil(log2(N))). For a 100 MHz input and a 1 ms interval, N=100000 and 17 counter bits suffice. An event pulse every N clocks has event rate f_clk/N, whereas toggling a square wave every N clocks gives f_clk/(2N).

## Behavioral contract
- Active-low asynchronous reset clears counter, tick, square output.
- restart takes precedence over enable and clears phase.
- enable=0 pauses phase; tick clears on the next source-clock edge.
- period_cycles=0 and =1 both mean tick each enabled edge.
- period changes apply immediately. Using >= on terminal count prevents a shortened period stranding a counter beyond its new terminal count.
- Outputs are registered; tick is one source-clock cycle wide.
- period_cycles is synchronous. square_out is **not** intended as a clock.

## Files
- [rtl/programmable_timer.sv](rtl/programmable_timer.sv) — synthesizable implementation.
- [tb/tb_programmable_timer.sv](tb/tb_programmable_timer.sv) — directed and random self-checking testbench.

## Exact waveform expectation (period 4)
After a restart, successive enabled rising edges produce:
| Edge | Count after edge | Tick | Square |
|---|---:|---:|---:|
| 1 | 1 | 0 | 0 |
| 2 | 2 | 0 | 0 |
| 3 | 3 | 0 | 0 |
| 4 | 0 | 1 | 1 |
| 5 | 1 | 0 | 1 |
| 8 | 0 | 1 | 0 |

## Verification and coverage
The bench drives inputs at negedge and compares after posedge plus 1 ps (after NBA), using a reference count and square-phase model. Directed cases include restart, pause/resume, period 0, period 1, and asynchronous reset; randomized cases vary period/enable/restart. Additional coverage goals: count near max, dynamic period shrink/grow, pause at terminal minus one, reset after a tick. SVA properties should check: terminal event implies tick next sampled edge, disable implies stable phase next sampled edge, and each tick returns count to zero.

## Interview checklist
1. Explain modulo-N and $clog2 corner N=1: use max(1,$clog2(N)).
2. Code an enabled decade counter: compare old count with 9.
3. Derive 1 ms from 100 MHz: 100000 cycles, terminal 99999.
4. Explain why toggle divider divides by 2N.
5. Handle dynamic period shrink: compare >= terminal.
6. Debug N+1 period: inspect old count and terminal comparison.
7. Choose clock enable over generated clock: avoid CDC and clock tree risks.
8. Verify tick exact edge and all period boundaries with independent scoreboard.
9. Explain wrap vs saturate vs event counters; upper carry does not indicate signed overflow.
10. Architect SoC timer: prescaler, shadow configuration, interrupt status, low-power clocking.

## Review traps
Do not use N as terminal count, assume a toggling output frequency of f/N, compare outputs before NBA, or treat a counter bit as a distributed clock.

## Verification status
This testbench and RTL are **not** claimed simulator-verified here; run with a SystemVerilog simulator before using the result for sign-off.
