# Expected output

The PASS signature is:

```text
[DAY 6] PASS: <cycles> pipeline cycles, final signed accumulator=<signed value>
```

The final numeric value can differ with another simulator's random stream; every accepted product and output-valid cycle must still match the reference model. The exact output from a pinned hosted run is recorded in [`docs/verification_report.md`](../docs/verification_report.md).
