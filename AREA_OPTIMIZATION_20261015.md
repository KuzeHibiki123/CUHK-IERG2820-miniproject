# Area optimization — 2026-10-15

Target: EP4CE6E22C8. Project: `mini_project.qpf`.
Program `build/quartus_project/mini_project.sof`.

| Resource | Before | Final |
|---|---:|---:|
| Fitted logic elements | 632 | 601 |
| Logic registers | 260 | 260 |
| M9K blocks / initialized memory bits | 3 / 24,576 | 3 / 24,576 |
| Embedded 9-bit multiplier elements | 2 | 2 |

Measured reduction: **31 LE (4.91%)**. This is not a claim of a global minimum.

## Retained changes

- Separate Q2 A-register input selection from the latest-instruction result
  output. OUT and LOAD B/C never write A, so their data paths are unnecessary
  in A's mux. Divide-by-zero disables A's write instead of selecting A again.
  The standalone result/zero interface retains its previous behavior.
- Mark A's next value as don't-care only for opcodes where its write enable
  is false. No architectural register receives that don't-care value.
- Track pending instruction inputs whenever the slot is empty or a step
  occurs. While a command is waiting without a step, its payload is held.
  Busy/commit/refill/cancellation behavior is unchanged; only unobservable
  payload writes lose unnecessary reset/enable/execute gating.
- Let the bus debounce counter wrap after acceptance. A changed candidate
  always restarts qualification at the same count. Reaccepting an unchanged
  candidate cannot change the output or generate another rising pulse.
  The acceptance time and output pulses match the original every cycle.
- Use Quartus AREA synthesis optimization. Keep the existing seed, device,
  timing constraints and all explicit board pin assignments.

Q1's RTL is unchanged in the final build. A trial of replacing its divide-by-
zero feedback mux with a write enable increased its resource use and was
reverted. Display modules, arithmetic widths, LED10 selected-value zero,
K2 clock selection, no K4 reset and low-nibble Q1 chaining are preserved.

## Trials

| Trial | Fitted LE | Worst setup slack (ns) |
|---|---:|---:|
| Starting LED10 build | 632 | 1.552 |
| Specialized Q2 A mux / divide-by-zero hold | 614 | 3.068 |
| Also remove bus-counter saturation | 607 | 2.392 |
| Also simplify queue, A mux don't-cares and Q1 hold | 607 | 2.185 |
| Restore original Q1; use AREA synthesis (final) | 601 | 1.912 |

## Verification

All 13 testbenches pass on the final RTL. Coverage includes 393,992 Q2
register/result/status checks, all Q1 four-bit arithmetic cases, 100,000-cycle
core/top comparisons, 18 debounce configurations, clock switching, ignored
K4, 8,192 display ROM combinations with both polarities, and 9,917 Q2
LED/display checks including LED10 zero indication.

Quartus full compilation: zero errors, 21 warnings. All nine internal 50 MHz
timing checks pass. No false paths or multicycle exceptions were introduced.
Board I/O delays remain unspecified; hardware was not programmed or measured
in this session. All 62 explicit locations match both the original QSF and
the fitted pin report.

Logs: `build/area15_trial4_tests.log`, `build/area15_trial4_compile.log`.
Release checks, source hashes and SOF SHA-256: `build/area15_release_audit.json`.
Original sources/settings/SOF: `backups/before_area_opt_20261015`.
