# Verification report

## Latest recorded hosted result

- Date: 2026-10-19
- Environment: GitHub Actions, Ubuntu 24.04.5 LTS, Verilator 5.020 (Debian 5.020-1)
- Command: `make regression`
- Compile mode: SystemVerilog, timing enabled, assertions enabled, `-Wall`
- RTL/testbench source revision: `07baa6c626fc746658492413ec5178eeebe0bc76`
- Pull-request test merge revision: `6b082742b97985637f7aa78ae8e432803102e936`
- Result: the structure gate and all fourteen simulations passed; no assertion failure or simulation fatal was reported
- Workflow evidence: [RTL regression run 39269482956](https://github.com/ashishkommineni/14-days-of-rtl/actions/runs/39269482956)
- Saved logs: [rtl-regression-logs artifact 12195032484](https://github.com/ashishkommineni/14-days-of-rtl/actions/runs/39269482956/artifacts/12195032484), 28 files, ZIP SHA-256 `29c4b55c1b522f3d319c71c3ece2c4d2d0183f8e4b2c51327ba2942eed36c3ff`

| Day | Recorded PASS evidence |
|---:|---|
| 1 | `11 NYC clock checks, including both DST boundaries` |
| 2 | `52 arbitration checks; safety SVA and rotating-priority model active` |
| 3 | `64 register-file transactions with byte bypass` |
| 4 | `86 cycles, accepted=30 delivered=30, no loss/reorder` |
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

The hosted run proves that the fourteen checked-in RTL/testbench combinations at the cited source revision compiled under the stated Verilator version and completed their self-checks. It exercises the SVA subset supported by that flow and the portable functional-coverage gates implemented in the repository. The workflow also proved the structural contract: exactly fourteen canonical root projects, with RTL, testbench, expected output, executable checking, coverage evidence, and ten interview Q&A entries per project.

It does **not** prove synthesis, timing closure, CDC/RDC sign-off, formal proof, protocol certification, code-coverage closure, or silicon readiness. The Xcelium command is present for users with a licensed installation, but no Xcelium or IMC result is claimed until its logs and coverage database are captured.

## Historical debugging notes

The Day-4 producer now retains `valid` and `data` while `ready` is low. An environment-side SVA property checks that ready/valid requirement, while the queue scoreboard checks conservation and ordering.

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

Record the tool version, seed, source revision, command, and logs when adding a new result. A documented command is not execution evidence.
