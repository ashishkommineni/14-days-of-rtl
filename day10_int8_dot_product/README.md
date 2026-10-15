# Day 10 — Elastic INT8 Dot-Product Engine

## Problem this block solves

Neural-network inference repeatedly multiplies low-precision activations by weights and adds the products. This project implements one four-lane INT8 dot product with a 32-bit bias and transports it through a two-stage elastic pipeline. The arithmetic is small, but the real RTL lesson is preserving data when the consumer applies backpressure.

## Specification

For every accepted input transaction:

```text
result = bias + a0*b0 + a1*b1 + a2*b2 + a3*b3
```

Each operand is signed 8-bit two’s complement. The accumulator/result is signed 32-bit. `in_valid && in_ready` accepts one vector. `out_valid && out_ready` retires one result. Bubbles and arbitrary output stalls are legal, ordering must be preserved, and no accepted vector may be lost or duplicated.

## Internal RTL flow

Stage 1 calculates and stores the dot product. Stage 2 holds the result at the output. Readiness propagates backward:

```text
s2_ready = output stage empty OR consumer ready
s1_ready = stage 1 empty OR s2_ready
in_ready = s1_ready
```

When the output is stalled, stage 2 freezes. If stage 1 is also occupied, `in_ready` falls. When space becomes available, both stages may advance on the same edge. Nonblocking assignments naturally move the old Stage-1 value into Stage 2 while accepting a new value into Stage 1.

## Cycle reasoning

| Cycle | Input | Stage 1 | Stage 2/output | Consumer |
|---:|---|---|---|---|
| 0 | Vector A accepted | A | empty | ready |
| 1 | Vector B accepted | B | A | ready |
| 2 | Vector C blocked | B | A held | not ready |
| 3 | Vector C accepted | C | B | ready; A retires |

The assertion requires `result` and `out_valid` to remain stable throughout Cycle 2’s stall.

## Verification strategy

The scoreboard calculates each accepted dot product independently and queues expected results. Directed vectors force positive, negative and zero values. Random vectors inject bubbles and backpressure. End-of-test conservation requires accepted and delivered totals to match. Coverage must hit positive, negative, zero, an input bubble, and an output stall. SVA checks output stability and valid retention.

```bash
make day DAY=10
```

## Industry use

The same structure appears in DSP blocks, CNN/transformer accelerators, SIMD execution lanes, audio filters, and quantized edge-AI hardware. Production versions add many lanes, multiplier mapping, saturation/rounding, zero skipping, accumulation across cycles, and power gating.

## Common mistakes

The common arithmetic mistake is accidental unsigned multiplication. The common control mistake is overwriting Stage 2 during backpressure. Other traps include insufficient accumulator width, mismatched valid latency, clearing valid without a handshake, and using driver intent rather than accepted inputs in the scoreboard.

## Ten interview questions and answers

1. **Why use INT8 in inference?** It reduces storage, bandwidth, multiplier area and energy while often retaining acceptable accuracy after quantization.
2. **Why is the accumulator wider than eight bits?** Products are 16-bit signed values and several products plus bias must be summed without immediate overflow.
3. **What defines transaction acceptance?** Only `in_valid && in_ready` on a clock edge.
4. **What must happen during output backpressure?** `out_valid` stays high and the entire payload remains stable until handshake.
5. **Why are there two valid bits?** Each pipeline stage independently tracks whether its data is meaningful.
6. **Can Stage 1 and Stage 2 move on the same edge?** Yes. Old Stage 1 advances while a new input replaces it, giving one-result-per-cycle throughput after fill.
7. **What is a bubble?** A cycle in which a pipeline stage carries no valid transaction.
8. **How does the scoreboard avoid mirroring the DUT?** It computes the mathematical dot product directly from accepted input samples and compares outputs in order.
9. **What would saturation add?** Instead of two’s-complement wraparound, values beyond a configured range clamp to its minimum or maximum.
10. **How would this become a systolic PE?** Add local operand forwarding, an accumulation register, array-neighbor links, and cycle-aligned valid/control movement.

## Spoken interview answer

“This is a four-lane signed INT8 dot-product datapath with a two-stage ready/valid pipeline. I focused on elastic control: readiness propagates backward, and both payload and valid freeze under output backpressure. The scoreboard models only accepted vectors and proves ordering and transaction conservation under bubbles and stalls.”
