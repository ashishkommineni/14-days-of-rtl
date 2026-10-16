# Expected output

```text
[DAY 2] PASS: 52 arbitration checks; safety SVA and rotating-priority model active
```

The random request masks are compared cycle by cycle with an independent priority model. The SVA proves one-hot and request/grant safety continuously; full-contention fairness is exercised by two complete rotations and checked by the model.
