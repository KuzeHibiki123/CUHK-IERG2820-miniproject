# Logic-element optimization

The final design uses **671 LE instead of 892 LE**, saving **221 LE (24.8%)**.
Question 1, Question 2 and the three display modules remain separate.

| Resource | Original | Optimized |
|---|---:|---:|
| Total logic elements | 892 | 671 |
| Registers | 267 | 264 |
| Embedded 9-bit multipliers | 1 | 1 |
| RAM bits | 0 | 0 |

Both reports use Quartus Prime Lite 25.1std.0, Cyclone IV E, EP4CE6E22C8,
Balanced optimization and the default 50 MHz / 10 Hz timing parameters.
The original automatic device selection resolved to EP4CE6E22C8; the current
project and scripts explicitly select this device. Synthesis was repeated
with that explicit selection and still reports 671 LE.
The counts are Analysis & Synthesis estimates before fitting. They are
not transistor/gate counts or a guarantee for another FPGA family.

## Changes retained

- **Simpler debounce counters.** Single-bit inputs need no separate candidate
  register. The touch bus uses one candidate register and a saturating counter.
  Stable-time requirements and accepted-input timing are unchanged.
- **Shared addition/subtraction.** Each core uses one add/subtract datapath;
  carry/borrow comes from the extended sum rather than another comparison.
- **Narrow standalone Q1 arithmetic.** With the default four-bit setting,
  arithmetic widths are explicitly limited to the required operand width.
- **Explicit register write enables.** Q2 updates only the destination registers
  and flags, reducing feedback multiplexers. Pending command payload registers
  need no reset network because they cannot be used until marked valid.
- **Shared multiplication/division across modes.** The top selects operands from
  the active core. One combinational multiplier/divider serves both, without
  changing the SW1 or CCLK execution schedule. State remains private to each core.

`SHARE_MATH=1` is the optimized top-level default. `EXTERNAL_MATH=0` remains
the default on the individual question modules so they can be used standalone.
Do not enable external arithmetic in a standalone question without connecting
the product/quotient inputs to the corresponding operands.

No instructions, flags, decimal-point conventions, repeat behavior, debounce,
reset, or registered segment outputs were removed. T, K and SW1 remain
active-high. Optional eight-bit Q1 chaining is still supported.

## Evidence and limits

All seven regression tests pass. Besides the arithmetic and display cases,
tests compare the original and optimized filters, cores and complete top-level
design on every simulated clock cycle. Top-level comparison covers both Q1
repeat widths and all Q1/Q2 opcodes. All LED, segment and CCLK outputs match.

See `verification_results.txt`, `reports/before.map.summary` and
`reports/after.map.summary`. Detailed reports are also included. The local
pre-optimization archive is retained in `optimization/before_optimization.zip`.

This is a tested reduction, not a proof that no smaller design exists. Board
fitting, 50 MHz timing signoff and oscilloscope verification still depend on
the actual hardware. Further changes that introduce serial arithmetic or
different debounce timing would need an explicit behavior/timing tradeoff.
