# Verification report

## Latest recorded hosted result

- Date: 2026-10-16
- Environment: GitHub Actions, Ubuntu 24.04, Verilator 5.020
- Compile mode: SystemVerilog, timing enabled, assertions enabled, `-Wall`
- Repository commit: `886a073a8c41be22c6016974c41e5577b4dad7e9`
- Result: all fourteen projects passed; no assertion failure or simulation fatal was reported
- Evidence: [RTL regression run 38949766952](https://github.com/ashishkommineni/14-days-of-rtl/actions/runs/38949766952)

| Day | Recorded PASS evidence |
|---:|---|
| 1 | `11 NYC clock checks, including both DST boundaries` |
| 2 | `52 arbitration checks; safety SVA and rotating-priority model active` |
| 3 | `64 register-file transactions with byte bypass` |
| 4 | `86 cycles, accepted=28 delivered=28, no loss/reorder` |
| 5 | `6 source events crossed unrelated clocks exactly once` |
| 6 | `59 pipeline cycles, final signed accumulator=7568` |
| 7 | `112 cycles, 69 packets routed without loss/reorder` |
| 8 | `8 APB checks; read/write/error/IRQ/W1C coverage closed` |
| 9 | `4 reads; clean/corrected/parity/double-error coverage closed` |
| 10 | `54 vectors preserved through elastic INT8 pipeline` |
| 11 | `17 64-bit beats became 34 ordered 32-bit beats` |
| 12 | `7 full gated pulses; functional and scan requests covered` |
| 13 | `89 predictor updates; all state/outcome transitions covered` |
| 14 | `12-word DMA transfer preserved address/data/order under backpressure` |

Randomized totals are deterministic for this recorded simulator build but may change when another simulator uses a different random-number stream. Correctness does not depend on a particular random total: each run recomputes its reference result and checks ordering, latency, or conservation as appropriate.

## What this evidence proves

The hosted run proves that the fourteen checked-in RTL/testbench combinations compiled under the stated Verilator version and completed their self-checks. It exercises the SVA subset supported by that flow and the portable coverage gates implemented by Days 08–14.

It does **not** prove synthesis, timing closure, CDC/RDC sign-off, formal proof, protocol certification, code-coverage closure, or silicon readiness. The Xcelium command is present for users with a licensed installation, but no Xcelium or IMC result is claimed until its logs and coverage database are captured.

## Historical debugging notes

The original Day-7 directed sequence incorrectly expected input zero to win after an earlier transfer had already changed arbitration history. Moving the reset-priority check before that transfer made the test match the specified state machine. An early CI run also exposed a Verilator 5.020 portability limitation for one temporal cover sequence; the cover was reduced to a supported event while the cycle-accurate scoreboard continued to check latency.

Day 1 explicitly uses a signed intermediate for the UTC offset and a Sunday-zero Gregorian day-of-week convention. Those details prevent hour underflow and one-day DST boundary errors.

## Reproduce

```bash
make clean
make regression
```

Expected final line:

```text
[REGRESSION] PASS: selected RTL projects completed without assertion failures
```

Record the tool version, seed, commit, command, and logs when adding a new result. A documented command is not execution evidence.
