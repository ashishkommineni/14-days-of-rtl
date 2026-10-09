# Day 06 — FSM Design and Verification

## Why FSMs?
A finite-state machine retains control history. Its next state is a function of its current state and sampled inputs. Moore outputs depend on state; Mealy outputs depend on state and inputs.

## Specification
A single-outstanding command controller has five states: IDLE, SEND, WAIT_RSP, COMPLETE, ERROR_STATE. A start accepted in IDLE enters SEND. In SEND, request_valid remains high until request_ready. In WAIT_RSP, a response produces a one-cycle COMPLETE or ERROR_STATE; otherwise a programmable timeout produces ERROR_STATE. A response arriving on the terminal timeout opportunity wins over timeout. Start while busy is ignored. The controller assumes synchronous functional inputs and an asynchronous active-low reset.

## Architecture
Two processes: one always_ff holds state and wait_count; one always_comb computes next_state and Moore outputs. All combinational signals receive defaults, avoiding latches. WAIT_RSP has a bounded timeout; a response clears the count.

## Timing
For TIMEOUT_CYCLES=4, the old wait_count values evaluated on WAIT_RSP edges are 0,1,2,3. Without response, the fourth edge enters ERROR_STATE. A successful response enters COMPLETE after the accepting edge; done is high for the COMPLETE cycle.

## Verification plan
- Start, delayed request_ready, immediate response, delayed response
- Error response, timeout, response on terminal timeout edge
- Reset from every active state; start while busy
- Illegal-state recovery and X checks
- Assertions: hold request while stalled; handshake enters WAIT_RSP; response success/error transition; timeout transition; done/error mutually exclusive
- Functional coverage: each state, each legal transition, SEND and WAIT_RSP self-loops, success/error/timeout, boundary response, reset from active states

## Interview review — 10 prompts
1. What hardware implements an FSM, and how is next_state derived?
2. Explain Moore vs Mealy output latency and glitches.
3. Code a two-process request/ack FSM that holds request.
4. Compare binary, one-hot and Gray encoding for timing and area.
5. Explain default assignments and latch prevention.
6. Debug a state that appears stuck using state, next_state, clock and transition inputs.
7. Derive overlapping 1011 detection from longest matching prefix.
8. Plan state/transition/priority/reset verification and SVA.
9. Explain illegal-state handling and synthesis optimization limits.
10. Decide which functions belong in FSM control versus datapath.

## Limitations
Educational example, not production-ready protocol IP. No request payload storage, transaction IDs, CDC, retry or formal proof. Verification execution has not been claimed.
