# Day 08 — APB Interrupt Controller

## Problem this block solves

Peripherals often produce several local event pulses, while a CPU expects one interrupt line and a small software-visible register map. This project joins those two worlds. Hardware events become sticky status bits, software selects which sources are allowed to interrupt, and a global enable controls the final output. The register interface follows the APB setup/access protocol so the block can sit behind a low-bandwidth SoC peripheral bus.

## Specification

| Address | Register | Access | Meaning |
|---:|---|---|---|
| `0x00` | `CTRL` | RW | Bit 0 is the global interrupt enable |
| `0x04` | `IRQ_ENABLE` | RW | One enable bit per source |
| `0x08` | `IRQ_STATUS` | RO/W1C | Events set bits; writing 1 clears a bit |
| `0x0C` | `ID` | RO | Constant design identifier `0x44561408` |

All transfers complete in one access cycle. Unmapped, misaligned, and writes to the read-only ID register assert `PSLVERR`. Status update is **set-dominant**: if software clears a bit in the same cycle that hardware raises the event, the event remains pending. That ordering prevents a real interrupt from being lost.

## Internal RTL flow

APB first presents address/control with `PSEL=1, PENABLE=0`. In the access phase `PENABLE` rises. The decoder determines whether the address is legal, the write logic updates the selected register, and the read mux drives `PRDATA`. The sticky status equation is:

```text
next_status = (current_status AND NOT clear_mask) OR irq_sources
irq         = global_enable AND OR(next/pending_status AND irq_enable)
```

The final OR makes the source set win over a simultaneous clear. This tiny expression is the most important design decision in the block.

## Cycle example

| Cycle | APB/action | Status[2:0] | IRQ |
|---:|---|---:|---:|
| 0 | Reset | `000` | 0 |
| 1–2 | Enable sources 0 and 2, enable global IRQ | `000` | 0 |
| 3 | Source 0 pulses | `001` | 1 |
| 4–5 | Software reads status | `001` | 1 |
| 6 | Software clears bit 0 while source 2 pulses | `100` | 1 |

## Verification strategy

The self-checking testbench reads the ID register, programs both enable levels, injects an event, checks the sticky status and IRQ, proves set-dominant W1C behavior, and checks three error classes. SVA verifies access completion and legal APB phase ordering. Portable coverage counters make the test fail unless read, write, error, IRQ, and simultaneous clear/set scenarios all occur. The Xcelium-only covergroup crosses operation type with each implemented address.

Run this project alone:

```bash
make day DAY=08
```

Expected signature: `[DAY 8] PASS: ... read/write/error/IRQ/W1C coverage closed`.

## Industry use

This structure appears in UARTs, DMA engines, timers, GPIO controllers, sensor hubs, and power-management IP. Real products normally add synchronizers for asynchronous event sources, per-source trigger selection, interrupt priority, security/privilege checks, and a generated register specification.

## Common mistakes

The main bugs are clearing a newly arriving event, accepting a transfer in the setup phase, changing address/control while waiting, permitting writes to read-only registers, and deriving IRQ from the raw source instead of sticky status. Another interview trap is calling this APB3 while using `PSTRB`; byte strobes belong to later APB versions. This implementation intentionally uses full-word writes and does not expose `PSTRB`.

## Ten interview questions and answers

1. **Why are interrupt-status bits sticky?** A one-cycle event may occur long before software reads the register. A sticky bit preserves the event until software acknowledges it.
2. **What is W1C?** Writing a one clears the corresponding status bit; writing zero leaves it unchanged. It avoids a read-modify-write race across unrelated bits.
3. **Why must set dominate clear?** Otherwise an event arriving during the clear transaction disappears, so software never services it.
4. **When does an APB transfer complete?** On a clock edge with `PSEL`, `PENABLE`, and `PREADY` all high.
5. **What is the difference between setup and access?** Setup selects address/control with `PENABLE=0`; access holds them stable and raises `PENABLE`.
6. **When should `PSLVERR` be sampled?** Only on the completing access cycle.
7. **Why have both per-source and global enables?** Per-source bits select causes; the global bit gives software an atomic master mask.
8. **Should raw asynchronous IRQ inputs feed this RTL directly?** No. They need the appropriate CDC mechanism before they enter the destination clock domain.
9. **What would a scoreboard model?** Register contents, sticky event accumulation, W1C ordering, decode errors, and the final IRQ equation.
10. **How would you extend this block?** Add trigger type/polarity, priority, masked/raw status, CDC front ends, register-generation metadata, and formal properties for no event loss.

## Spoken interview answer

“I built an APB interrupt controller with global and per-source masks, sticky status, and write-one-to-clear acknowledgement. The key corner case is clear and event in the same cycle, so the next-state equation is set-dominant and cannot lose the new event. The testbench checks legal transfers, decode errors and that race, while assertions check the APB phase contract.”
