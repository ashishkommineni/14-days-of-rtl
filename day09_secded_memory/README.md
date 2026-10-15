# Day 09 — SECDED-Protected Memory

## Problem this block solves

Stored bits can flip because of radiation, voltage noise, marginal timing, or wear. A parity bit detects some corruption but cannot identify the bad bit. This project stores each 32-bit word with Hamming parity plus one overall parity bit, allowing the read path to **correct one error and detect two errors** (SECDED).

## Specification

- 16 words of 32-bit payload data.
- Six Hamming parity bits cover 38 positions; one overall parity bit produces a 39-bit codeword.
- A clean read returns data with both flags low.
- A one-bit error in payload, Hamming parity, or overall parity asserts `single_error`; payload is corrected when required.
- A two-bit error asserts `double_error`; data is reported but must not be trusted.
- A verification-only injection port XORs a mask into a stored codeword.

The injection port represents an error-injection hook used during validation. A production macro normally exposes this through DFT, ECC control registers, or a memory-wrapper test mode rather than ordinary functional logic.

## How the code is built

Positions 1, 2, 4, 8, 16 and 32 are Hamming parity locations. The 32 payload bits fill all other positions from 1 through 38. Each parity bit covers positions whose binary position number contains its bit. The XOR of all 38 Hamming bits is stored as the overall parity.

On read, six parity checks form a syndrome. The overall parity check separates cases:

| Syndrome | Overall mismatch | Meaning | Action |
|---:|---:|---|---|
| 0 | 0 | Clean | Return payload |
| nonzero | 1 | One error in Hamming field | Flip the syndrome position |
| 0 | 1 | Overall-parity bit error | Payload already correct |
| nonzero | 0 | Two-bit error | Flag uncorrectable |

## Cycle behavior

A write encodes and stores on its request edge. A read samples the selected codeword and registers `rsp_valid`, corrected data, and error flags. The memory accepts one request per cycle; this educational implementation does not stall or scrub corrected words back automatically.

## Verification strategy

The testbench writes four known patterns and performs four read classes: clean, single payload/Hamming-bit corruption, overall-parity corruption, and double corruption. Its functional coverage gate requires all four. Assertions check that reads produce a response, writes do not, and correctable/uncorrectable flags are mutually exclusive. The Xcelium covergroup covers operation and result class.

```bash
make day DAY=09
```

## Industry use

SECDED is common in SRAMs, caches, register files, NoC buffers, safety islands, automotive controllers, and server memory paths. Production systems also count corrected errors, scrub memory, poison uncorrectable data, generate interrupts, and analyze multi-bit physical adjacency.

## Common mistakes

Typical errors are mixing zero-based array indexes with one-based Hamming positions, calculating the syndrome without including parity locations, reversing the overall-parity truth table, silently “correcting” a double error, and testing only data-bit corruption. Another trap is assuming SECDED makes memory perfect: three or more corrupt bits can alias to another classification.

## Ten interview questions and answers

1. **What does SECDED mean?** Single-error correction and double-error detection within one protected codeword.
2. **Why is normal parity insufficient?** It can indicate odd corruption but cannot identify which bit must be repaired.
3. **What is a syndrome?** The vector of failed Hamming parity checks; for a single error it encodes the corrupted position.
4. **Why add overall parity?** Pure Hamming correction cannot reliably distinguish one error from two; the extra parity bit provides that distinction.
5. **Can a parity-bit error be corrected?** Yes. Hamming parity errors have a syndrome position; an overall-parity-only error leaves payload unchanged.
6. **Should data be consumed when `double_error` is high?** No. The data is uncorrectable and the system needs an error policy such as retry, poison, reset, or failover.
7. **What is scrubbing?** Periodically reading, correcting, and rewriting memory so a latent single error does not combine with a second error.
8. **Why test every physical codeword bit?** The encoder’s mapping can be wrong for only one parity/data position even when a few directed examples pass.
9. **How would you verify ECC exhaustively?** For several payloads, inject each single-bit mask and many/all two-bit combinations, compare to an independent encoder/decoder model, and close syndrome coverage.
10. **What changes for wider data?** Recalculate the required Hamming parity count using `2^r >= m + r + 1`, then add the overall parity bit.

## Spoken interview answer

“The wrapper expands each 32-bit word into a Hamming codeword plus overall parity. At read time the syndrome locates a single corrupted position, while overall parity tells me whether it is a correctable single error or a detected double error. I verified clean data, payload and parity single-bit errors, and an uncorrectable double-bit case.”
