# Requirements and portability

## Portable regression

- Verilator 5.x
- GNU Make, Bash and a C++20-capable compiler
- Linux runner (the GitHub Actions workflow installs Verilator on Ubuntu)

Run all projects with `make regression` or one project with `make day DAY=NN`.

## Cadence Xcelium path

`make xcelium` calls `xrun -64bit -sv -assert -coverage all`. Xcelium compiles the dedicated Day 08–14 covergroups that are preprocessor-disabled under Verilator. A valid Cadence installation and license are required. Use IMC/vManager for database analysis and merging; do not describe the Xcelium path as executed evidence unless its transcript and tool version are captured.

## Language boundary

- RTL uses synthesizable SystemVerilog: `always_ff`, `always_comb`, parameters, enums, functions, packed/unpacked arrays and generate-time structure.
- Testbenches use timing controls, tasks/functions, random stimulus, reference queues/arrays, procedural checks and SVA checker modules.
- No UVM package is required; the goal is to keep each design and checker visible before adding a reusable class-based environment.

## Project assumptions

- Resets assert asynchronously and are released away from active edges in the supplied tests.
- Day 05 assumes source events are spaced far enough apart for a toggle synchronizer to observe them; implementation sign-off also needs CDC constraints and structural analysis.
- Day 06 requires accumulator width to accommodate the configured product and accumulation policy.
- Day 07 sources obey ready/valid and hold an unaccepted packet stable.
- Day 08 interrupt sources are already synchronous to `pclk`; asynchronous physical sources require CDC front ends.
- Day 09 models registers as memory. A production implementation may replace them with a macro, pipeline ECC, scrub corrected data and define an uncorrectable-error policy.
- Day 10 uses 32-bit wrapping arithmetic and four INT8 lanes; it does not claim quantization/saturation accuracy for a trained model.
- Day 11 assumes all eight input bytes are valid because the teaching interface omits `TKEEP`.
- Day 12 is a behavioral clock-gating model. ASIC implementation must use an ICG cell; FPGA implementation must use vendor clock enables/buffers.
- Day 13 demonstrates direction prediction only; target prediction and speculative-history recovery are out of scope.
- Day 14 permits one outstanding memory read and assumes every accepted request eventually receives exactly one response.

## Sign-off boundary

A green simulation regression validates the documented educational behaviors. It does not replace lint, synthesis, STA, CDC/RDC, DFT, UPF, formal protocol compliance, security review, memory characterization, or physical-design sign-off.
