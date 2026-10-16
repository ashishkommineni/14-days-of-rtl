# 14 Days of RTL

[![14-day RTL regression](https://github.com/ashishkommineni/14-days-of-rtl/actions/workflows/rtl-regression.yml/badge.svg)](https://github.com/ashishkommineni/14-days-of-rtl/actions/workflows/rtl-regression.yml)

Fourteen self-contained RTL projects that progress from control and storage fundamentals to CDC, streaming, reliability, low power, AI arithmetic, processor prediction, and a DMA capstone. Every day contains a behavioral contract, synthesizable SystemVerilog, a self-checking testbench, executable assertions/coverage goals, expected output, engineering explanation, common failures, and ten interview questions with answers.

This is a project series, not a collection of copied syntax snippets. The verification rule is simple: a project passes only when its testbench can decide correctness without manual waveform inspection and the full hosted regression is green.

## Project path

| Day | Project | Engineering focus | Verification focus |
|---:|---|---|---|
| 01 | [New York clock with DST](day01_nyc_clock) | Calendar arithmetic and daylight-saving boundaries | Transition dates, leap-year borrow, invalid input |
| 02 | [Parameterized round-robin arbiter](day02_round_robin_arbiter) | Fair rotating priority | Sparse/full contention, one-hot grants, fairness |
| 03 | [Byte-enable register file](day03_byte_enable_register_file) | Partial writes and forwarding | Per-byte merge, two read ports, random model |
| 04 | [One-entry ready/valid elastic buffer](day04_ready_valid_skid_buffer) | Elastic flow control | Stall stability, no loss or reordering |
| 05 | [CDC pulse synchronizer](day05_cdc_pulse_synchronizer) | Toggle-based event transfer | Unrelated clocks and event conservation |
| 06 | [Signed pipelined MAC](day06_pipelined_mac) | Valid tracking and sign extension | Bubbles, signed corners, flush and arithmetic model |
| 07 | [Buffered 2×2 packet router](day07_two_by_two_router) | Arbitration plus output buffering | Contention, backpressure and packet conservation |
| 08 | [APB interrupt controller](day08_apb_interrupt_controller) | Sticky events, W1C ordering and register decode | APB phase checks, errors, set-dominant clear race |
| 09 | [SECDED-protected memory](day09_secded_memory) | Hamming ECC and overall parity | Clean, corrected single, parity and double-error cases |
| 10 | [Elastic INT8 dot-product engine](day10_int8_dot_product) | Edge-AI arithmetic and pipeline elasticity | Signed reference model, bubbles, stalls and conservation |
| 11 | [AXI-Stream 64-to-32 converter](day11_axis_width_converter) | Stream width adaptation | Word order, `last`, backpressure and 2:1 beat accounting |
| 12 | [Safe clock-gating controller](day12_safe_clock_gate) | Low-power clock control and scan override | Full pulses, mid-cycle enable changes, gated-edge checks |
| 13 | [Two-bit branch predictor](day13_branch_predictor) | Saturating counters and hysteresis | All state/outcome transitions and prediction cross |
| 14 | [Backpressure-safe micro-DMA](day14_micro_dma) | Request/response separation and stream delivery | Variable latency, two stall points, errors and end-to-end order |

## Standard inside every day

```text
dayNN_project/
├── rtl/                  # synthesizable design
├── tb/                   # self-checking testbench and reference model
├── assertions/           # separate SVA checker on Days 08–14 (inline before that)
├── coverage/             # Xcelium covergroup on Days 08–14 (portable gates before that)
├── README.md             # specification, flow, use, traps and 10 Q&A
└── expected_output.md    # observable pass signature
```

Days 01–07 keep assertions in the RTL and prove scenario coverage through directed checks, reference models, and conservation counters in the testbench. Days 08–14 add dedicated assertion modules, Xcelium covergroups, and explicit portable end-of-test coverage gates. The [coverage plan](docs/coverage_plan.md) states the exact evidence available for each day.

## Run the complete regression

### Verilator / hosted CI

```bash
make regression
```

Run one project:

```bash
make day DAY=10
```

The script compiles with timing and assertions enabled. Build products and logs stay below ignored `build/` and `logs/` directories.

### Cadence Xcelium

```bash
make xcelium
```

The Xcelium path includes the dedicated covergroups and enables functional/assertion/code coverage. Use IMC or your team’s vManager flow to inspect and merge the generated databases. A command is documentation—not proof—until an actual run record is captured.

## Verification philosophy

1. Define acceptance and observable behavior before writing stimulus.
2. Drive inputs away from active sampling edges.
3. Predict results with an independent behavioral model.
4. Use SVA for continuous temporal rules and scoreboards for end-to-end data correctness.
5. Force corner cases explicitly; random stimulus supplements, not replaces, requirement tests.
6. Check conservation: accepted work must equal delivered work unless the specification defines a flush/error path.
7. Keep simulation sign-off separate from synthesis, CDC, STA, DFT and physical sign-off.

See [the cross-project coverage plan](docs/coverage_plan.md) and [the recorded regression evidence](docs/verification_report.md).

## Repository scope

These are educational but reviewable blocks. They demonstrate engineering decisions and verification discipline; they are not drop-in production IP. Technology-specific memory macros, ICG cells, CDC constraints, protocol compliance suites, security policy, synthesis constraints, and physical sign-off must be added for a target chip.

## License

Released under the [MIT License](LICENSE).
