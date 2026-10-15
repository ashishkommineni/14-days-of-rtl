# Expected output

The portable regression must end with a line similar to:

```text
[DAY 8] PASS: 8 APB checks; read/write/error/IRQ/W1C coverage closed
```

The exact check total may change when directed scenarios are extended. A valid run has no `%Error`, assertion failure, or `$fatal` before the PASS line.
