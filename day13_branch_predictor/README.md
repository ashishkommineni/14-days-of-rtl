# Day 13 — Two-Bit Saturating Branch Predictor

## Problem this block solves

A pipelined processor must choose the next fetch address before an earlier branch is resolved. Waiting wastes cycles, so hardware predicts whether a branch will be taken. This project implements a small branch-history table (BHT) containing one two-bit saturating counter per index.

## Specification

- Sixteen entries, indexed by a four-bit branch index.
- Reset state is `01`, weakly not taken.
- Counter states are `00` strongly not taken, `01` weakly not taken, `10` weakly taken, and `11` strongly taken.
- The MSB is the prediction.
- A taken update increments unless already `11`.
- A not-taken update decrements unless already `00`.
- Query is combinational; update occurs on the clock edge.

Two bits add hysteresis. A strongly biased branch needs two consecutive opposite outcomes before the predicted direction changes.

## State movement

```text
00 --T--> 01 --T--> 10 --T--> 11
00 <--N-- 01 <--N-- 10 <--N-- 11
```

At `00`, another not-taken result stays at `00`; at `11`, another taken result stays at `11`. Those saturation boundaries prevent arithmetic wraparound.

## Cycle example

A new entry starts at `01` and predicts not taken. The first taken outcome updates it to `10`; the next query predicts taken. Another taken result moves it to `11`. One later not-taken result moves it only to `10`, so the predictor still says taken. A second not-taken result reaches `01` and flips the prediction.

## Verification strategy

The testbench maintains an independent BHT model. A directed sequence drives one entry through every state, both directions, and both saturation boundaries. Random updates exercise aliasing across all 16 entries. The test closes every state/outcome transition and all four prediction-versus-actual combinations: correct taken, correct not taken, predicted taken but not taken, and predicted not taken but taken.

```bash
make day DAY=13
```

## Industry use

Two-bit counters are a foundation for local/global predictors, gshare, tournament predictors, loop predictors and TAGE-like designs. Modern CPUs combine direction prediction with a branch target buffer, return-address stack, speculative history and recovery after misprediction.

## Common mistakes

Typical bugs are allowing two-bit arithmetic to wrap `11→00` or `00→11`, initializing to a strong state, using byte-address bits that are always zero, updating the wrong instruction after a pipeline flush, ignoring aliasing, and confusing direction prediction with target prediction.

## Ten interview questions and answers

1. **Why use two bits instead of one?** Hysteresis prevents one unusual outcome from immediately reversing a stable prediction.
2. **Which bit forms the prediction?** The counter MSB: states `10` and `11` predict taken.
3. **What does saturating mean?** Increment/decrement stops at the maximum/minimum instead of wrapping.
4. **Why reset to weakly not taken?** It avoids strong initial bias while matching the common fall-through default.
5. **What is aliasing?** Different branch PCs map to the same entry and interfere with each other’s history.
6. **How is the index chosen?** Commonly from aligned PC bits; low instruction-alignment bits are excluded.
7. **What is a misprediction penalty?** Wrong-path work is flushed and fetch restarts at the correct address, costing pipeline cycles.
8. **What is missing from a BHT?** The target address. A BTB or return-address stack supplies target prediction.
9. **How should updates handle squashed branches?** Only architecturally valid/resolved branch outcomes should train state, or speculative updates need recovery.
10. **How would you improve accuracy?** Add more entries, PC/history hashing, global/local history, tournament selection, or a TAGE-style multi-history predictor.

## Spoken interview answer

“I implemented a 16-entry BHT with two-bit saturating counters. The MSB predicts direction, and resolved outcomes train the indexed counter without wrapping at 00 or 11. My reference model verifies every update, and directed coverage forces all eight state/outcome transitions plus every prediction/actual combination.”
