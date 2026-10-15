# Day 14 — Backpressure-Safe Micro-DMA Engine

## Problem this block solves

Software copying every word between memory and a peripheral wastes CPU cycles. A DMA engine performs the transfer autonomously. This capstone accepts a base address and word count, issues one read at a time, waits for the response, and sends data through a ready/valid stream while preserving order under memory and consumer backpressure.

## Specification

- `start`, aligned `base_addr`, and nonzero `length_words` launch a transfer.
- Misaligned or zero-length commands pulse `config_error` and do not become busy.
- Only one memory request is outstanding.
- Read addresses increase by four bytes per accepted output word.
- Memory response data is held until `out_valid && out_ready`.
- `out_last` marks the final word.
- `done` pulses when the final word transfers; `busy` is low in that completed cycle.

This project deliberately separates the request and response channels. A request handshake says the memory accepted an address; it does not mean read data is already available.

## Internal RTL flow

The controller uses four states:

| State | Responsibility |
|---|---|
| `IDLE` | Validate a new command |
| `ISSUE` | Hold request/address until memory accepts |
| `WAIT_RSP` | Wait for one response without issuing another request |
| `SEND` | Hold response data and `last` until stream acceptance |

After a non-final output handshake, the address increments, the remaining count decrements, and the controller returns to `ISSUE`. After the final handshake it pulses `done` and returns to `IDLE`.

## Cycle reasoning under stalls

If memory deasserts `mem_req_ready`, the engine remains in `ISSUE` and the address stays stable. If the downstream stream deasserts `out_ready`, the engine remains in `SEND` and data/last stay stable. These two holds are independent and are both asserted by SVA.

## Verification strategy

The testbench includes a memory model whose data is an independent deterministic function of address and whose response latency varies. Random request readiness and output readiness generate both backpressure types. The scoreboard checks every output against `memory_value(base + 4*index)`, then verifies request/output conservation. Negative tests cover zero length and misalignment. Functional coverage must hit request stall, output stall, successful completion, both configuration errors, and final-beat marking.

```bash
make day DAY=14
```

## Industry use

DMA engines move descriptors, packets, audio/video samples, AI tensors and storage data. Production engines add bursts, multiple outstanding IDs, FIFOs, byte enables, source/destination addressing, descriptor chains, interrupts, IOMMU/security checks, timeout/error responses and performance counters.

## Common mistakes

The classic errors are incrementing address on request intent instead of request acceptance, assuming response arrives immediately, overwriting held output under backpressure, asserting `done` before the last output handshake, losing the last marker, and allowing a second request when only one outstanding transaction is supported.

## Ten interview questions and answers

1. **What is the difference between request and response handshakes?** The request transfers an address/control command; the response later transfers returned data or status.
2. **When should the DMA increment its address?** In this architecture, only after the current returned word is accepted by the output, keeping address/count/data aligned.
3. **Why hold request address during stall?** Ready/valid requires valid payload to stay stable until acceptance.
4. **Why hold output data during stall?** Changing it would corrupt or skip the pending transaction.
5. **When should `done` assert?** When the final output beat actually handshakes, not when its request is issued or response merely arrives.
6. **What does one outstanding request mean?** The next request is not issued until the previous response has been received and consumed in this simple controller.
7. **How would a FIFO improve performance?** It decouples memory response timing from downstream backpressure and permits multiple prefetched words.
8. **What is burst support?** One address/control request describes multiple sequential data beats, reducing channel overhead.
9. **What additional errors need handling?** Bus error responses, timeout, abort/reset, descriptor faults, alignment/length violations and protection failures.
10. **How would UVM verify this block?** Use command, memory and stream agents; a predictor generates expected addresses/data; a scoreboard checks conservation/order; coverage crosses length, stalls, errors and reset timing.

## Spoken interview answer

“My micro-DMA uses separate ISSUE, WAIT-response and SEND states, so it never confuses address acceptance with data return. It supports one outstanding read and holds both request address and output payload under backpressure. A memory model and scoreboard prove address progression, data ordering, last/done timing and request-to-output conservation.”
