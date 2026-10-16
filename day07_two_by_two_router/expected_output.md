# Expected output

The PASS signature is:

```text
[DAY 7] PASS: <cycles> cycles, <count> packets routed without loss/reorder
```

Packet totals can vary with a different random stream. Passing requires both per-output ordering and global accepted/delivered equality. The exact output from a pinned hosted run is recorded in [`docs/verification_report.md`](../docs/verification_report.md).
