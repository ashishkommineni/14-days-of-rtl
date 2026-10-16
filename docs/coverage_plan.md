# Cross-project coverage plan

Coverage is tied to named requirements rather than an unexplained percentage. Each project combines directed corners, randomized/reference-model comparison where useful, and continuous assertions. Days 01–07 demonstrate scenario closure through exact test checks, scoreboards, or conservation counters. Days 08–14 additionally provide explicit portable end-of-test coverage gates and Xcelium covergroups.

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

For Days 01–07, a PASS line is printed only after the listed directed checks and any scoreboard/conservation checks succeed. For Days 08–14, the testbench also requires every named portable coverage flag before printing PASS. Random stimulus is not accepted as evidence that a corner probably occurred; required corners are forced explicitly.

## Tool-specific evidence

Verilator CI proves compilation, execution of the supported inline/concurrent assertions, and completion of the self-checking tests. It also proves portable coverage-gate closure where those gates exist (Days 08–14). Xcelium can additionally collect covergroup, assertion and code coverage. Record the simulator version, seed, command, merged database scope, exclusions and uncovered rationale before quoting a numerical percentage. No Xcelium coverage percentage is claimed in this repository yet.
