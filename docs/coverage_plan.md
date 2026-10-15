# Cross-project coverage plan

Coverage is tied to named requirements rather than an unexplained percentage. Each project combines directed corners, randomized/reference-model comparison where useful, continuous assertions, and end-of-test coverage gates. Days 08–14 additionally provide Xcelium covergroups.

| Day | Required scenario coverage | Continuous checking | End-to-end proof |
|---:|---|---|---|
| 01 | EST/EDT boundaries, leap/year borrow, invalid date | Calendar/time range invariants | Exact vector comparison |
| 02 | Full/sparse/single/idle requests | One-hot grant and request/grant legality | Rotating-priority model |
| 03 | Full/partial writes and dual-port bypass | Enabled-byte forwarding | Byte-merge memory model |
| 04 | Empty load, stall, pop+push, drain | Stable output under stall | Accepted/delivered conservation |
| 05 | Events at unrelated clock phases | One-cycle destination pulse | Sent/received event equality |
| 06 | Signed corners, bubbles and flush | Valid/result legality | Cycle-aligned arithmetic model |
| 07 | Independent paths, contention and backpressure | Stable outputs and single winner | Per-output packet ordering/conservation |
| 08 | Read, write, decode/alignment/RO error, IRQ, clear+set | APB setup/access contract | Register/IRQ expected values |
| 09 | Clean, payload/parity single error, double error | Read response and exclusive flags | Known-data ECC decode comparison |
| 10 | Positive, negative, zero, bubble, output stall | Stable valid/result during stall | Accepted/delivered dot-product queue |
| 11 | Low/high halves, last/non-last, output stall | Stable stream payload and legal last | Exactly two ordered outputs per input |
| 12 | Functional enable, disable, scan override, high-phase change | Gated clock follows only legal source edges | Counted full pulses, no runt-edge event |
| 13 | Every state×outcome transition and prediction×actual pair | Saturating behavior through reference checks | Independent BHT state model |
| 14 | Request/output stalls, two config errors, last/done | Stable request/output under backpressure | Address/data/order and count conservation |

## Coverage closure rule

A PASS line is printed only after all required directed bins are marked and every scoreboard/conservation check succeeds. Random stimulus is not accepted as evidence that a corner probably occurred; required corners are forced explicitly or checked by a coverage gate.

## Tool-specific evidence

Verilator CI proves compilation, SVA execution supported by the chosen tool, directed/random test completion and coverage-gate closure. Xcelium can additionally collect covergroup, assertion and code coverage. Record the simulator version, seed, command, merged database scope, exclusions and uncovered rationale before quoting a numerical percentage.
