# Fourteen-project completion matrix

This document maps each root project to the evidence checked into the repository. The canonical series is the fourteen root `dayNN_*` directories; the earlier partial nested draft has been retired.

| Day | Project | RTL and self-check | Continuous checking | Coverage / closure | Recorded hosted evidence |
|---:|---|---|---|---|---|
| 01 | New York clock with DST | Exact-vector calendar model | Output range assertions | DST edges, leap/year borrow, invalid input | 11 checks |
| 02 | Round-robin arbiter | Rotating-priority reference model | One-hot and request/grant safety SVA | Full/sparse/single/idle requests | 52 checks |
| 03 | Byte-enable register file | Byte-merge memory model | Per-lane bypass SVA on two ports | Full/partial writes and collisions | 64 transactions |
| 04 | Ready/valid elastic buffer | Ordered queue scoreboard | DUT stall SVA plus producer-hold protocol SVA | Empty, stall, pop+push, drain, conservation | Count is simulator-seed dependent |
| 05 | CDC pulse synchronizer | Sent/received event accounting | One-cycle destination-pulse SVA | Unrelated phases and event conservation | 6 events |
| 06 | Signed pipelined MAC | Latency-aware signed arithmetic model | Valid/result and clear/flush SVA | Signed corners, bubbles and clear | 59 cycles |
| 07 | Buffered 2×2 router | Per-output ordered queues | Stable-output and single-winner SVA | Contention, backpressure, conservation | Seed-dependent packet total |
| 08 | APB interrupt controller | Register/IRQ reference checks | APB setup/access SVA | Read/write/error/IRQ/W1C gates and covergroup | 8 checks |
| 09 | SECDED memory | Known-data ECC comparison | Response and exclusive-flag SVA | Clean, corrected, parity, double-error gates | 4 reads |
| 10 | Elastic INT8 dot product | Signed queue scoreboard | Stall-stability SVA | Positive/negative/zero/bubble/stall gates | Seed-dependent vector total |
| 11 | AXI-Stream width converter | Ordered 2:1 beat scoreboard | Stream-stability and `last` SVA | Low/high/last/stall gates | Seed-dependent beat total |
| 12 | Safe clock gating | Counted source/gated edges | Legal-edge and full-pulse SVA | Functional/scan/mid-cycle gates | 7 full pulses |
| 13 | Two-bit branch predictor | Independent BHT model | Saturating-transition SVA | Every state×outcome transition | 89 updates |
| 14 | Backpressure-safe micro-DMA | Address/data/order scoreboard | Request/output stability SVA | Both stalls, errors, last and done gates | 12-word transfer |

## Repository-wide acceptance gate

`make regression` first runs `scripts/check_structure.sh`, then compiles and executes every design/testbench pair with timing and assertions enabled. A valid completion requires:

1. exactly fourteen root day directories;
2. RTL, self-checking testbench, README and expected output for every day;
3. executable assertions and coverage evidence;
4. exactly ten interview Q&A entries in every project README;
5. no assertion failure, `$fatal`, loss, duplication or ordering error;
6. saved compile/run logs from the hosted workflow.

## Evidence boundary

The dated [verification report](verification_report.md) is the authority for simulator version, commit and exact observed output. A green Verilator regression is functional simulation evidence only. It is not Xcelium/IMC evidence and does not replace synthesis, STA, CDC/RDC, formal, DFT or physical sign-off.
