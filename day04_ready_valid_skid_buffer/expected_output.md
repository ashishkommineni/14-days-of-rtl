# Expected output

The PASS signature is:

```text
[DAY 4] PASS: <cycles> cycles, accepted=<count> delivered=<same count>, no loss/reorder
```

Random counts can differ across simulators; equality and FIFO ordering are the required result. The exact output from a pinned hosted run is recorded in [`docs/verification_report.md`](../docs/verification_report.md).
