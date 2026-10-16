# Day 1 — UTC to New York clock

## What this block does

`nyc_clock` converts a valid UTC calendar/time input into New York local time. It selects UTC−5 during Eastern Standard Time and UTC−4 during Eastern Daylight Time, handles a borrow into the previous day/month/year, and rejects impossible input dates.

## Why this is a useful RTL problem

The subtract-four-hours part is easy. The real design work is at the boundaries: the offset changes on rules expressed as “the second Sunday” or “the first Sunday,” and a negative local hour changes the calendar date. This project combines functions, signed arithmetic, calendar corner cases, and a specification that can be checked with exact vectors.

## Behavioral contract

- Valid year range begins at 2007. This block implements the current US DST policy introduced in 2007; it intentionally rejects earlier years rather than silently applying the wrong historical rule.
- Inputs must contain a real Gregorian date, hour `0..23`, and minute `0..59`.
- DST starts at `07:00 UTC` on the second Sunday in March.
- DST ends at `06:00 UTC` on the first Sunday in November.
- The start instant is already daylight time; the end instant is already standard time.
- Invalid input deasserts `valid_datetime` and drives all local outputs to zero.

## How it works internally

1. `days_in_month()` validates the day and implements Gregorian leap-year rules.
2. `day_of_week()` uses the Sakamoto formula with `Sunday = 0`.
3. `nth_sunday()` derives the two transition dates for the supplied year.
4. UTC date/hour is compared with the transition instants to select `-4` or `-5`.
5. The signed offset is applied using an integer-width intermediate.
6. If the hour becomes negative, the calendar borrows one day and fixes month/year rollover.

The wider intermediate in step 5 matters. Storing `2 - 5` in a 5-bit unsigned value does not produce `-3`; it wraps. Date correction must see a real negative number.

## Worked example

At the 2026 spring transition:

| UTC input | DST decision | New York output |
|---|---|---|
| 2026-03-08 06:59 | Standard (`−5`) | 2026-03-08 01:59 |
| 2026-03-08 07:00 | Daylight (`−4`) | 2026-03-08 03:00 |

The local clock skips from 01:59 to 03:00. There is no 02:xx local time on that date.

## Verification

The self-checking test covers winter, summer, both sides of both DST transitions, year borrow, leap-day borrow, an invalid non-leap February 29, an invalid month, and a pre-2007 date outside the stated policy. Immediate assertions also keep every valid output within legal time/calendar ranges.

Run only this project:

```bash
make day DAY=01
```

## Interview-ready answer

> I built a combinational UTC-to-New-York converter. The main problem is not the fixed offset; it is deriving US daylight-saving boundaries and keeping the calendar correct when subtraction crosses midnight. I use a Gregorian day-of-week function to find the second Sunday in March and first Sunday in November, compare the UTC input against the exact 07:00 and 06:00 transition instants, and then apply a signed four- or five-hour offset. A negative result borrows from the prior date with month, year, and leap-year handling. The testbench checks both sides of each transition and invalid dates, and design assertions constrain valid outputs to legal ranges.

## Ten interview questions and concise answers

1. **Why are the transition hours expressed in UTC?** Comparing everything in one time domain avoids ambiguity during the repeated fall-back hour.
2. **Why is a signed wide intermediate required?** A narrow unsigned hour wraps before the design can detect a negative result.
3. **What is the Gregorian leap-year rule?** Divisible by 4, except centuries unless also divisible by 400.
4. **Is division/modulo free in hardware?** No. Constant division may synthesize into optimized logic, but area/timing must be reviewed for the target. A production clock may use counters or precomputed tables.
5. **What happens at fall-back?** `05:59 UTC` maps to `01:59 EDT`; `06:00 UTC` maps to `01:00 EST`, so the local 01:xx hour repeats.
6. **Why does this implementation reject years before 2007?** US DST transition dates changed historically. Restricting the input contract is more honest than applying the post-2007 March/November rule to dates that followed a different policy.
7. **Why is the implementation combinational?** The output is a pure function of the supplied timestamp and policy. A real running clock would normally keep registered time state and update it from a tick.
8. **How would you validate the day-of-week function independently?** Compare it against trusted calendar vectors spanning leap years, century exceptions such as 2100, and known Sundays, rather than reusing the DUT formula in the testbench.
9. **What should happen for an invalid input?** The contract deasserts `valid_datetime`, clears `is_dst`, and drives all local time outputs to zero so downstream logic cannot mistake stale data for a conversion.
10. **How would production time-zone support differ?** It would use a versioned policy table or firmware-managed transition registers, because legal rules can change; the RTL would also define update atomicity and persistence across reset.

## Common traps

- Mixing a Monday-based day index with a Sunday-based formula.
- Testing only noon, never the exact transition minute.
- Applying the offset in an unsigned vector.
- Assuming February always has 28 days.
- Describing this as time-zone IP without stating the rule set and supported years.

## Revision card

**Rule:** second Sunday in March at 07:00 UTC through first Sunday in November before 06:00 UTC. **Key implementation point:** signed offset, then calendar borrow. **Key proof:** exact before/after transition vectors.
