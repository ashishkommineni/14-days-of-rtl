# Expected output

```text
[DAY 1] PASS: 11 NYC clock checks, including both DST boundaries
```

Any `$fatal` before this line is a failure. The output line is printed only after every exact-vector comparison and range assertion has passed, including rejection of a pre-2007 date outside the implemented DST policy.
