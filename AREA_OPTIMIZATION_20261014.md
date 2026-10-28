# Area optimization — 2026-10-14

Final target: EP4CE6E22C8. Open `mini_project.qpf` and program
`build/quartus_project/mini_project.sof`.

| Resource | Before | Final |
|---|---:|---:|
| Fitted logic elements | 762 | 610 |
| Logic registers | 292 | 260 |
| Embedded 9-bit multiplier elements | 1 | 2 |
| M9K blocks | 0 | 3 |
| Initialized memory bits | 0 | 24,576 |

LE reduction: **152 (19.95%)**. This is a measured implementation improvement,
not a proof of the globally minimum possible LE count. Memory and DSP capacity
are used deliberately to minimize LE usage: 3/30 M9Ks and 2/30 9-bit multiplier
elements. The final compile completed at 22:48:44 local time.

## Changes

- Default to independent arithmetic (`SHARE_MATH=0`). Q1's default divide is
  truly four-bit. The optional shared path also explicitly sizes its Q1 divide
  to four bits when low-nibble chaining is selected.
- Force Q1 multiplication into an embedded multiplier. Two independent
  multipliers avoid the shared multiplier's input selection logic.
- Simplify Q1's saved input updates: writing an unchanged input is equivalent
  to holding it, so an extra equality-controlled write enable is unnecessary.
- Retain Q2's result register but derive zero directly from that registered
  result. Zero previously tracked exactly this value for every instruction,
  including LOAD, OUT, NOP and divide-by-zero. Redundant per-opcode zero
  detection and the dedicated zero flip-flop are removed.
- Use three initialized M9K ROMs to convert display values directly into
  registered segment patterns. C1/C2/C3 remain independent modules; preview
  DP, operators, decimal/hex modes, blanking, active polarity and one-cycle
  latency are preserved. ROM contents are embedded in the programming file.

The original combinational display modules remain as independent simulation
references. They are not instantiated in the production top. Testbenches and
`add_sources.tcl` include the new display implementation.

## Measured alternatives

| Trial | Fitted LE | Decision |
|---|---:|---|
| Original | 762 | Baseline |
| Explicit four-bit Q1 divide | 726 | Retain width specialization |
| Simpler Q1 input storage and common Q2 zero detector | 691 | Functional/timing tests pass |
| Replace result register with register selector | 706 | Rejected: selector costs more than saved registers |
| Independent multipliers without forced Q1 DSP | 706 | Small multiplier mapped into logic |
| Force Q1 DSP, retain registered result | 678 | Retain |
| Add three registered display ROMs | 610 | Final |

## Validation

All twelve testbenches pass. Eleven core/filter/top/display/startup/clock tests
are logged in `build/area_tests.log`; the additional exhaustive ROM test is
logged in `build/area_display_rom_tests.log`. The full suite is now included in
`run_tests.ps1`. Coverage includes all Q1 initial arithmetic cases, all operand
pairs for six Q2 arithmetic opcodes, 100,000-cycle core/top equivalence checks,
both chaining widths, both arithmetic architectures, ignored/floating K4,
K2 debounce/toggle and queued-command behavior.

ROM tests compare 8,192 input combinations in both polarities with the original
formatter/decoders, including reset and exact one-cycle latency. All 2,560
entries in the three Quartus-generated `.hdl.mif` ROM initialization files
were independently checked against the expected segment patterns.

Quartus full compilation: zero errors, 21 warnings. Nine additional warnings
refer to unused write-side signals of inferred read-only memories; the
initialized contents were verified as above. Existing unused ports, constant
LED outputs and unspecified I/O details account for the other warnings.

| Timing model | Setup slack (ns) | Hold slack (ns) | Pulse-width slack (ns) |
|---|---:|---:|---:|
| Slow 1200 mV, 85 C | 0.075 | 0.451 | 9.466 |
| Slow 1200 mV, 0 C | 1.687 | 0.400 | 9.497 |
| Fast 1200 mV, 0 C | 6.808 | 0.186 | 9.372 |

All internal timing checks pass, but the worst setup margin is narrow. No
false-path or multicycle exceptions were added. Board I/O delays remain
unspecified; no physical programming/measurement was performed in this session.

All 62 explicit pin assignments match the backup and final fitter report.
No K4 reset, Q1 low-nibble chaining, Q2 register semantics, K2 rate selection,
and decimal C1/C3/C2 ordering are unchanged.

SOF SHA-256: `a926e328ef631b265162c86b684e1e0a85faec9962b86451dcb9cea842a9385e`.
Machine-readable release verification: `build/area_release_audit.json`.
Compilation log: `build/area_compile.log`.
Pre-optimization backup: `backups/before_area_opt_20261014`.
