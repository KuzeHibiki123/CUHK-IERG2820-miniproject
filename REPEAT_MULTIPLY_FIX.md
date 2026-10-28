# Repeated multiplication verification — 2026-10-14

Project: `IERG2820_Verilog_Project1/mini_project.qpf`.
Target: EP4CE6E22C8. Final compilation completed at 11:04:18 local time.
Programming file: `build/quartus_project/mini_project.sof`.

## Cause and correction

Q1 previously defaulted to low-nibble chaining: only bits 3:0 of the previous
answer became the next operand. A result of 32 therefore became operand 0.
The board top now defaults to `Q1_CHAIN_8BIT=1`, retaining all eight bits for
repeated operations. Initial four-bit ADD/SUB conventions remain unchanged.

Verified Q1 sequences:

- 2 * 2, followed by repeated equals: 4, 8, 16, 32, 64, 128, 0.
  Only the final 128 * 2 operation sets LED9 overflow.
- 8 * 4 = 32, followed by equals: 128 (legacy setting produced 0).
- 15 * 15 = 225, followed by equals: 47 with overflow (3375 modulo 256).

Q2 multiplication needs no functional change. MUL writes the low byte to A
and high byte to B. Thus A=16/B=2 produces A=32/B=0, and another MUL produces
zero. Reload B=2 before every MUL to keep doubling A. At 128*2, A=0 and B=1
retain the complete 16-bit product 256. Also verified 15*17=255 and
255*255=65025 (B=254, A=1), including OUT B and decimal display positions.

Q2 zero-flag decoding was implemented independently of the result multiplexer
to shorten the critical path. For unsigned division with B nonzero, the
quotient is zero exactly when A<B. Divide-by-zero preserves A, so its zero
flag remains A==0. This optimization changes neither register behavior nor
instruction timing. No false-path or multicycle timing exceptions were added.

## Verification

All ten testbenches in `run_tests.ps1` passed after the final RTL change:

- Q1: 1,032 checks, including all 1,024 initial operand/operator combinations.
- Q2: 393,992 register/result/status checks, including all operand pairs for
  six arithmetic opcodes.
- Displays: all 256 decimal/hex values and segment polarity/blank/DP cases.
- Top integration and power-up/reset behavior.
- Filter equivalence: 18 configurations and 20,000 stimulus cycles.
- Core and top equivalence: 100,000 cycles each, covering both chaining widths.
- Multiplication bounds and repeated multiplication: shared and local math,
  overflow flags, Q2 high-byte storage, and C1/C3/C2 hundreds/tens/units.

Quartus 25.1 Lite full compilation: **0 errors, 14 warnings**.
Balanced optimization, placement seed 4. Final fit: **683/6,272 LE**,
**264 registers**, **one 9-bit multiplier element**, zero RAM bits and no PLL.

| Timing model | Setup slack (ns) | Hold slack (ns) | Pulse-width slack (ns) |
|---|---:|---:|---:|
| Slow 1200 mV, 85 C | 0.004 | 0.453 | 9.758 |
| Slow 1200 mV, 0 C | 1.602 | 0.401 | 9.723 |
| Fast 1200 mV, 0 C | 11.461 | 0.186 | 9.410 |

All internal checks pass with clock uncertainty included. The worst setup
margin is narrow; future RTL or fitting changes require timing revalidation.
Board I/O delays remain unconstrained. Existing unspecified I/O standards and
ten automatically placed ports remain unresolved board-configuration items:
K[2:3], LED[10:15], CCLK and C3[16]. No new pin numbers were invented.

All **59 explicit pin assignments** match the pre-debug backup and final fitter
pin report. CLK_50 remains PIN_24, C3[7] remains PIN_53. C1/C3/C2 display order
is unchanged. Both existing CDF files reference the final SOF.

Final SOF: 358,741 bytes.
SHA-256: `98bbef4bbd14c3466ce7e5c4b436bbf2b47f16fc7254510b5eebe44abc6838d2`.
Machine-checked release metadata: `build/repeat_release_audit.json`.
Compilation log: `build/repeat_compile.log`.
Fit/timing reports: `build/quartus_project/mini_project.fit.summary` and
`build/quartus_project/mini_project.sta.summary`.

The SOF has been generated and checked, but has not been programmed or tested
on the physical board by this debugging session. The user-confirmed damaged
F segment is a separate hardware issue.
