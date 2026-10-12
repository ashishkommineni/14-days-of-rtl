# Day 08 — Signed arithmetic, widths, overflow and pipelined MAC

## Problem
A MAC must preserve sign and enough intermediate precision. Unsigned contamination, premature truncation and misaligned valid flags can silently corrupt DSP results.

## Rules and derivation
- Signed A-bit operand range: -2^(A-1) to 2^(A-1)-1.
- Signed A x B multiplication requires A+B bits.
- A full-precision addition of product and addend requires max(PROD_WIDTH, ACC_WIDTH)+1 bits.
- Sign extend BEFORE arithmetic, not after truncation.
- Check full-precision value against output minimum and maximum; clamp if SATURATE=1, otherwise truncate low ACC_WIDTH bits.
- Saturation occurs only once, after multiplication and addition.

## Pipeline
Stage 1 captures full product, extended addend, and valid; stage 2 captures result, overflow, and valid. With E0 input acceptance, T0 is registered in stage 1 after E0 and becomes visible at output after E1 (one edge-to-edge interval, two registering stages). Back-to-back transactions are supported, invalid cycles create bubbles. There is no backpressure.

## RTL
[rtl/pipelined_signed_mac.sv](rtl/pipelined_signed_mac.sv)

## Example
With A=B=4, ACC=8, SATURATE=1:
- 3*4+5 = 17, no overflow
- -3*4+2 = -10, no overflow
- 7*7+100 = 149, saturates to 127, overflow=1
- -8*7-100 = -156, saturates to -128, overflow=1

## Verification plan
Use independently modeled signed arithmetic, transaction queue, bubble tracking and cycle-accurate output checks. Test max/min operands, exact boundaries, overflow both signs, reset mid-flight, consecutive valid cycles. Assertions: in_valid |=> valid_s1, valid_s1 |=> out_valid, output known when valid, saturation values when overflow. Cover operand sign combinations, boundary classes and back-to-back activity.

## Ten interview prompts
1. Meaning of signed packed vectors, part-select signedness.
2. Arithmetic expression sizing and explicit widening.
3. Full precision multiplier coding (A+B).
4. Signed overflow equation vs carry-out.
5. Throughput versus latency in pipelined MAC.
6. Debug a negative result printed as a large positive value.
7. Understand SVA preponed samples vs NBA.
8. Modify wrapping accumulator to saturate.
9. Verify with independent wide reference model.
10. Choose internal widths, Q format, guard bits and stages for production DSP.

## Limitations
No fixed-point rounding or binary point alignment; no ready/valid backpressure; output ignored unless out_valid=1; compile and simulator regression not executed in this environment.
