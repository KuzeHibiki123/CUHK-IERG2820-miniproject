# IERG2820 Mini Project — Verilog

Top-level module: **`mini_project_top`**. Target device: **EP4CE6E22C8 (Cyclone IV E)**. Open `mini_project.qpf` in Quartus. All design files are ordinary Verilog `.v` files. Question 1, Question 2 and each display have separate modules.

Based on the supplied project PDF, pages 2–5, and the OPD-AS5010/AS5011 segment diagram on datasheet page 3. Decimal operand display follows your correction: **show the units digit and light DP for values 10–15**.

## Modules

| File in `rtl/` | Purpose |
|---|---|
| `question1.v` | Four-bit calculator, repeated equals, carry/borrow and divide-by-zero |
| `question2.v` | Eight-bit ALU, registers A/B/C, all 16 instructions, pending instruction |
| `registered_display_rom.v` | Separate C1/C2/C3 registered display modules backed by M9K ROM |
| `c1_display.v` | Combinational C1 reference, retained for regression |
| `c2_display.v` | Combinational C2 reference, retained for regression |
| `c3_display.v` | Combinational C3 reference, retained for regression |
| `hex7_decoder.v` | Shared 0–F digit patterns |
| `display_formatter.v` | Reference decimal/hex formatter for equivalence tests |
| `input_filter.v` | Input synchronization, debounce and single press pulses |
| `clock_enable.v` | Selects full-rate / 1 Hz CCLK and a matching Q2 clock enable |
| `mini_project_top.v` | Connects both questions, selects the mode and drives displays/LEDs |

The default top uses independent arithmetic (`SHARE_MATH=0`). Each question
has its own hardware multiplier and width-specialized divider. Two embedded
9-bit multiplier elements eliminate the shared multiplier's input multiplexers.
The optional `SHARE_MATH=1` path is retained and regression-tested.

C1, C2 and C3 remain separate modules (`c1_registered_display`,
`c2_registered_display`, `c3_registered_display`). They use three M9K lookup
ROMs for decimal conversion, hexadecimal conversion, operand DP, blanking and
segment patterns. Display latency remains exactly one input-clock cycle.
The ROM tables initialize during FPGA configuration, with no runtime loader.
The table-construction division/modulo expressions are constant evaluation,
not additional hardware dividers. The old combinational display modules are
kept as independent regression references and consume no resources in the top.

For standalone cores, `EXTERNAL_MATH=0` builds their own arithmetic. Tie unused
`math_product` and `math_quotient` inputs to zero; Q1's `math_lhs` output can be
left unconnected.

## Controls

| Control | Question 1 | Question 2 |
|---|---|---|
| T1–T4 | A, T1 is the least significant bit | Data-in bits 0–3 |
| T5–T8 | B, T5 is the least significant bit | Data-in bits 4–7 |
| T9/T10 | Operator `{T9,T10}` | Opcode bits 3/2 |
| T11 | 0 = decimal; 1 = hexadecimal | Opcode bit 1 |
| T12 | Unused | Opcode bit 0 |
| SW1 | Execute / equals | Queue and execute on the next CCLK rising edge |
| SW2 | 0 selects Q1 | 1 selects Q2 |
| K1 | Unused | Toggle decimal/hexadecimal on each press |
| K2 | Toggle global fast/slow selection | Toggle 50 MHz / 1 Hz execution rate |
| K4 | Unused; no reset function | Unused; no reset function |

T, K and SW1 are active-high by default: `TOUCH_ACTIVE_LOW=0`, `KEY_ACTIVE_LOW=0`, and `SW1_ACTIVE_LOW=0`. SW1 is low when released and high when pressed; its debounced rising edge requests one execution.

K2 selects the execution rate; K3 and K4 are unused. K4 may remain unconnected. State is initialized automatically after FPGA configuration; there is no user-accessible reset during the experiment. Set the touch inputs first, allow about 10 ms to settle, then press SW1. Holding SW1 does not repeat; release and press again. Each K1 press toggles the format once.

## Displays

Before Q1 execution, C1 shows A, C2 shows B and C3 shows the operator.

| Operand | Decimal display | Hexadecimal display |
|---|---|---|
| 0–9 | 0–9, DP off | 0–9, DP off |
| 10 | `0.` | A |
| 11 | `1.` | b |
| 12 | `2.` | C |
| 13 | `3.` | d |
| 14 | `4.` | E |
| 15 | `5.` | F |

DP means the operand has a tens digit of 1; it is separate from the arithmetic carry LED. C3 uses `+`, `-`, `×` and `/`. The starburst has no two independent central dots, so `/` represents division.

After Q1 execution, or when displaying a Q2 register:

- **Decimal:** C1 = hundreds (left), C3 = tens (center), C2 = units (right). Leading zeros are blank. Physical order C1/C3/C2. Example: 225 → `2 2 5`; 7 → `blank blank 7`.
- **Hexadecimal:** C1 = high nibble, C2 = low nibble, C3 = blank. Physical order C1/C3/C2. Example: 225 → `E blank 1`.
- Result decimal points are off. Display capacity is 0–255 or 00–FF.

Changing Q1 A, B or the operator returns to operand display and starts a new calculation. Changing only T11 preserves the result and repeat state. Q2 initially displays A; OUT B/C keeps the selected register on display until another OUT or FPGA reconfiguration.

## Question 1

| T9 T10 | Operation | Result and status |
|---|---|---|
| 00 | A + B | Low four bits; carry separately on LED9 |
| 01 | A − B | Low four bits; LED9 = 1 if A < B |
| 10 | A × B | Full eight-bit product |
| 11 | A ÷ B | Unsigned integer quotient; divide-by-zero lights LED16 and preserves the previous result |

For the first ADD/SUB calculation, result bits 7–4 are zero. Thus `15+1` displays 0 with carry set, and `1−2` displays 15 with borrow set, following the PDF's “4-bit result + 1 carry/borrow bit”. Carry is not automatically included in the numeric result.

Repeated equals uses only the previous result's lowest four bits (`Q1_CHAIN_8BIT=0` in the board top), as required by the lab. The unchanged four-bit Group-B operand is used again. MUL still displays the complete eight-bit product; truncation is applied only when feeding that result into the next operation.

For example, `2*2 = 4`, then `= 8, 16, 0`: the low nibble of 16 is zero. `15*15 = 225`, then `= 15`, because 225 = 0xE1 and 1*15=15. Likewise, an initial result of 32 feeds back as zero. These are the required low-nibble chaining results, not premature multiplier overflow. The optional eight-bit chaining parameter remains available for comparison tests; the supplied board project uses zero.

## Question 2

**Repeated multiplication:** MUL B overwrites B with the high eight product bits, as required by the instruction table. For 16*2, A becomes 32 and B becomes 0; another MUL B then computes 32*0. To keep multiplying A by 2, execute LOAD B=2 before each MUL B. For 128*2, A=0 and B=1 preserve the full product 256. OUT B displays that high byte.

Opcode order is `{T9,T10,T11,T12}`, most significant bit first.

| Code | Instruction | Action |
|---|---|---|
| 0000 | LOAD A | A = Data-in |
| 0001 | LOAD B | B = Data-in |
| 0010 | LOAD C | C = Data-in |
| 0011 | INV | A = bitwise complement of A |
| 0100 | ADD B | A = A + B |
| 0101 | ADD C | A = A + C |
| 0110 | SUB B | A = A − B |
| 0111 | SUB C | A = A − C |
| 1000 | MUL B | A = low byte; B = high byte of A × B |
| 1001 | DIV B | A = integer quotient A / B; B unchanged |
| 1010 | RL | Shift A left, fill bit 0 with zero |
| 1011 | RR | Shift A right, fill bit 7 with zero |
| 1100 | OUT A | Select A for display |
| 1101 | OUT B | Select B for display |
| 1110 | OUT C | Select C for display |
| 1111 | NOP | Preserve state |

RL/RR are logical shifts, as specified in the PDF, rather than circular rotations. All arithmetic is unsigned.

LED conventions:

- LED1–8: the same selected register as C1/C2/C3, with LED1 = bit 0. The default is A. OUT B/C selects B/C for both binary and numeric displays; OUT A selects A again. LOAD B/C does not change the displayed register. The binary LEDs and numeric display share the same one-cycle output latency.
- LED9: addition carry, subtraction borrow, nonzero MUL high byte, or shifted-out bit. LOAD, INV and DIV clear carry.
- LED10: on exactly when the currently displayed register is zero (default A, or B/C selected by OUT). It is synchronized with LED1–8 and C1/C2/C3; writes to an unselected register do not change it.
- LED16: divide-by-zero. A is preserved on error. LOAD and arithmetic recompute/clear the error flag.
- OUT preserves carry/error and selects the register used by LED10. NOP preserves state. The standalone Q2 core retains its latest-result zero output, but the board LED10 uses the displayed value.
- LED15: extra pending-instruction indicator. LED11–14 are off. Q1 keeps LED10–15 off.

SW1 captures the instruction and data together. The one-entry pending slot holds them until the next execution edge. While LED15 is on, wait before submitting another instruction. A full slot ignores additional presses except on the same edge that its old instruction commits. Leaving Q2 cancels a pending instruction but preserves registers.

## Timing and use

All internal logic continues to use `CLK_50`. After FPGA configuration, Q2 can commit on every 50 MHz edge. Each debounced K2 press toggles between this full-rate mode and 1 Hz mode. Holding K2 toggles only once. In slow mode a queued SW1 instruction commits on the next 1 Hz CCLK rising edge; switching back to fast commits a pending command on the next enabled input edge. SW1 still requests one instruction per press in either mode. CCLK outputs the selected rate on PIN_141; it is an observation output, not an internal clock. Q1 remains SW1-driven. Input debounce and display updates remain at 50 MHz so slow mode does not lose button presses. Segment outputs update one input-clock cycle after register changes.

Default parameters are 50 MHz input, 1 Hz slow mode (`CPU_HZ=1`) and 10 ms debounce. `CLOCK_HZ` must be divisible by `2*CPU_HZ` and at least twice `CPU_HZ`.

Open **`mini_project.qpf`** to use the supplied project, already set to EP4CE6E22C8 with all RTL sources included. Alternatively, source `add_sources.tcl` from an open Quartus project; it sets the device and adds the sources. Testbenches are simulation-only. `mini_project.sdc` defines the 50 MHz clock.

Signal conventions: C1/C2 use `{DP,G,F,E,D,C,B,A}`; C3 uses `{DP,N,M,L,K,J,H,G2,G1,F,E,D2,D1,C,B,A2,A1}`. Display polarity, switch polarity and mode polarity are top-level parameters. The QSF preserves existing pin assignments, including CLK_50 on PIN_24, C3[7] on PIN_53 and CCLK on PIN_141. K2 is added on PIN_101; its dual-purpose nCEO function is released for regular user I/O after configuration.

## Verification

`run_tests.ps1` runs thirteen automatic tests for arithmetic, displays, debounce,
integration, and cycle-by-cycle comparisons against the original design.
The `reference_*.v` files are simulation-only. Run with Icarus Verilog:

```powershell
.\run_tests.ps1 -IcarusBin 'C:\path\to\iverilog\bin'
```

In this workspace, the script also finds the temporary local simulator automatically. Outputs go to `build/`; `top.vcd` contains the integration waveform. See `verification_results.txt` for the actual run results.

Current fitted resources after area optimization: **601 LE**, **260 logic
registers**, **3 M9K blocks** (24,576 initialized memory bits), and **2 embedded
9-bit multiplier elements**. The latest pass reduces LE use by 31 (4.91%)
from the previous 632-LE build without increasing memory or DSP use.
Q2's A-register input mux is specialized to instructions that write A;
unused pending-payload updates and the bus-filter counter logic are simplified.
Quartus synthesis uses AREA optimization; the placement seed remains 6.

All thirteen functional/equivalence tests pass, including all Q2 arithmetic
operand pairs, cycle-by-cycle input-filter/core/top comparisons, 8,192 ROM
input combinations in both polarities, and 9,917 Q2 LED/display cycle checks.

All nine internal timing checks pass at 50 MHz. Worst setup slack is
**1.912 ns**; changes require timing revalidation.
Board I/O delays remain unconstrained, and physical board verification is
still required. See `AREA_OPTIMIZATION_20261015.md` for current measurements,
tradeoffs and the release artifact. Older dated reports are historical.

The current lab behavior remains: no K4 reset, low-four-bit Q1 chaining,
K2 selects 50 MHz / 1 Hz, decimal C1/C3/C2 = hundreds/tens/units.

Latest update: `AREA_OPTIMIZATION_20261015.md` documents the 601-LE build. LED10 still indicates whether the currently displayed Q2 register is zero.
