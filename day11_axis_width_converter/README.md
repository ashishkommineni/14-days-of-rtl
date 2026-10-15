# Day 11 — AXI-Stream 64-to-32 Width Converter

## Problem this block solves

Two streaming blocks may carry the same packet format but use different datapath widths. This converter accepts one 64-bit ready/valid beat and emits two ordered 32-bit beats. It teaches width adaptation, payload holding, packet-boundary movement, and backpressure.

## Specification

- Accept a 64-bit beat only on `s_valid && s_ready`.
- Emit bits `[31:0]` first and `[63:32]` second.
- Assert output `m_last` only with the upper half when the accepted input beat had `s_last=1`.
- Hold `m_valid`, `m_data`, and `m_last` stable while the consumer is not ready.
- Do not accept another input until both output halves retire.

This intentionally favors clarity over peak throughput. A production converter could add buffering so the next input is accepted while the final half of the previous beat leaves.

## Internal RTL flow

`busy` means a 64-bit beat is stored. `upper_half=0` selects the low word. After the first output handshake, `upper_half` becomes one. After the second, `busy` clears and `s_ready` rises. `s_last` is stored beside the payload because packet metadata must experience exactly the same stalls as data.

## Cycle example

Input `64'h11223344_AABBCCDD` with `s_last=1` becomes:

| Output handshake | `m_data` | `m_last` |
|---:|---:|---:|
| First | `AABBCCDD` | 0 |
| Second | `11223344` | 1 |

If `m_ready=0` between them, the currently selected word and its `last` value remain unchanged.

## Verification strategy

For each accepted input, the testbench pushes two expected output records into a queue. Random source-valid and sink-ready patterns create bubbles and stalls. Every output beat is compared for data and `last`. End-of-test checks prove `outputs = 2 × inputs`. Coverage requires both halves, last and non-last transfers, and backpressure. SVA checks stall stability, legal `last`, and the simple no-buffer readiness rule.

```bash
make day DAY=11
```

## Industry use

Width converters appear between network interfaces, DMA engines, NoCs, accelerators, memory ports, video pipelines, and protocol bridges. Real AXI-Stream designs also move `TKEEP`, `TSTRB`, `TID`, `TDEST`, and `TUSER`; all sidebands must stay aligned with their data bytes.

## Common mistakes

Frequent bugs are reversing word order, asserting `last` on the first half, accepting a new input before stored data is drained, changing output during a stall, and dropping byte-valid information for partial final beats. The simplified interface has no `TKEEP`, so it assumes all eight input bytes are valid.

## Ten interview questions and answers

1. **What is a ready/valid transfer?** A transaction occurs only on an edge where both signals are high.
2. **Can valid depend combinationally on ready?** A source should assert valid when data is available and hold it; making valid wait for ready can deadlock another compliant endpoint.
3. **Why store `last`?** It is part of the transaction payload and must be delayed/stalled with the data.
4. **What happens if the sink stalls after the low word?** The upper word remains selected with `m_valid=1` until accepted.
5. **Why is throughput limited?** There is only one 64-bit holding register, so input readiness returns after both halves complete.
6. **How could throughput improve?** Add an input skid buffer or a second 64-bit register and allow simultaneous final-output/new-input handshakes.
7. **What does `TKEEP` solve?** It marks which bytes are valid, especially in a packet’s partial final beat.
8. **What should an assertion check during stall?** Valid and every payload/sideband bit must remain stable.
9. **How does a scoreboard model conversion?** Split each accepted input into ordered expected output beats and compare each accepted output.
10. **What changes for 32-to-64 conversion?** Accumulate two input beats, merge them, and correctly combine packet boundaries and byte-valid metadata.

## Spoken interview answer

“The converter stores one 64-bit stream beat and emits the low and high 32-bit halves in order. `last` is delayed to the second half, and the output is frozen under backpressure. My scoreboard splits accepted inputs into two expected records and proves ordering, metadata alignment and two-to-one beat conservation.”
