# GitHub portfolio and RTL-series audit — 2026-10-12

## Scope and evidence
Inspected the connected GitHub account's 12 repository names and profile README; read the README in the seven-project RTL repository and representative AXI4-Lite, asynchronous FIFO, SystemVerilog learning and UVM learning projects; reviewed the README, verification-results documents and LICENSE presence for AHB-Lite, APB3, I2C, SPI, UART and synchronous FIFO. Inspected the new 14-day series RTL/TB/SVA and CI configuration. This is a **documentation and static review**, not a complete line-by-line code audit of all 12 repositories. Existing verification reports are historical project records; no new simulator PASS was independently obtained in this audit.

## Profile findings
- Strong specialization: ASIC/SoC RTL, UVM, SVA, protocol verification and CDC.
- The profile presents three different engineering examples (7-day RTL, AXI4-Lite, asynchronous FIFO), with distinct verification evidence. Preserve this interview-friendly selection.
- UVM and SystemVerilog learning material is correctly distinguished from production IP.
- Add direct navigation to the in-progress 14-day concept series without calling it finished. **Done on 2026-10-12**.
- Employment, internship dates, tools, publication and educational facts are self-described, **not independently authenticated in this audit**. Verify resume consistency before using them in applications.

## Verified structural positives
- Six inspected protocol/FIFO repositories each expose README.md, LICENSE and docs/verification_results.md.
- The root 7-day RTL repo maintains its own dated seven-project verification report; do not conflate that proof with the new nested series.
- Existing UVM/DV notebooks provide explanation-centered learning paths.

## New 14-day series defects and changes
1. Earlier GitHub Actions regression compiled only RTL and TB, so standalone SVA modules were not instantiated or checked. Fixed: explicitly instantiate SVA modules in all three testbenches, add assertion source files to the Verilator build, and enable `--assert`.
2. An assertion instance was initially named `checker`, a SystemVerilog reserved keyword. Fixed: renamed it `u_assertions`.
3. Day 05 initially lacked a separate assertion module. Fixed: added restart, pause, terminal, tick consistency and increment assertions.
4. The profile did not navigate to the new series. Fixed: added an explicitly **in-progress** link.
5. The series README and verification report distinguish published examples from pending topics and **do not** advertise unexecuted regressions as passing.

## Remaining verification gaps — do not call complete
- Simulator availability locally: Verilator, Icarus and Yosys were not found in the working container.
- GitHub Actions: workflow has been committed, but no successful job result was independently retrieved in this audit.
- Three published topics (05, 06, 08) have RTL, TB, SVA and condensed READMEs. Long-form articles and exactly ten **fully answered** interview questions are not yet transcribed into GitHub.
- Days 01–04, 07 and 09–14 are unpublished in this series.
- No generated coverage report, synthesis/PPA report, lint report or CDC sign-off exists for the new series.
- Assertions are bound only for the present single test configuration; parameter-matrix testing, testbench mutants and forced-failure checks should be added.
- Functional coverage plans are described in documentation but dedicated runnable covergroup collection isn't yet included in these published benches.
- A fully independent mathematical reference model should be checked under supported parameter ranges beyond the current narrow MAC example. In particular, the current TB uses 32-bit integers as golden reference and must not be generalized blindly to larger operands.

## Recommended future improvements in priority order
1. **P0:** Run the new three-project GitHub Actions matrix and fix actual build or assertion failures before adding PASS badges.
2. **P0:** Expand all three chapters with worked waveforms, diagrams, ten fully answered interview questions, a documented coverage matrix and exact simulator version / output.
3. **P1:** Complete Days 01–04 and 07–14 in fixed sequence without duplicating the separate 7-day project corpus.
4. **P1:** Add parameter sweeps (timer period and width, FSM timeout=1 and boundaries, MAC operand widths and saturation toggle); add mutation tests proving scoreboard detects intentionally broken RTL.
5. **P1:** Add signed MAC randomized reference with wider-than-32-bit types where supported, and explicitly test saturation vs wrapping.
6. **P2:** Consolidate root README navigation into 'project builds' versus 'learning curriculum', and preserve the professional three-project selection on the profile.
7. **P2:** For the low-power Booth/MKSA project, publish measured FPGA utilization, timing and switching-power methodology **only after** tool runs; distinguish estimated power from measured evidence.
8. **P2:** Add a capstone integrating a control-register interface, DMA-like datapath, interrupts and FIFO, with one integrated UVM regression and defensible proof of coverage closure.

## Quality gate for each series day
Spec → RTL lint → compile → directed and randomized self-checking TB → SVA enabled and exercised → coverpoint/cross review → documented waveform/cycle examples → regression evidence with exact tool/version → README interview Q&A. Mark 'verified' only when there is executable evidence.

## Copyright and trust
Keep MIT LICENSE attribution in each independent repository. Do not put private credentials, simulator licenses, sensitive logs or copyrighted textbooks into public GitHub history. Do not advertise unexecuted tools or test results as proof.
