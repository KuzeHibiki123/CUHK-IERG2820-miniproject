# Clock pin correction - 2026-10-13

The newly provided Board Introduction.pdf (page 1) explicitly identifies PIN_24 / CLK2 as the board's 50 MHz clock and PIN_90 / CLK5 as 27 MHz. The previous Pin_Assignment.txt incorrectly identified PIN_23 as the 50 MHz source.

Changed only CLK_50's location from PIN_23 to PIN_24 in the main and diagnostic QSF files. Original QSF and SOF files were backed up beside their originals with before_clock_pin_fix suffixes. No RTL, other pin location, polarity, frequency parameter or timing period was changed. Board observations (static display test works, K4 releases normally, heartbeat does not blink with PIN_23) are consistent with the wrong clock pin. Actual display recovery must be checked after loading the rebuilt SOF.

## Rebuild verification

- mini_project: full compilation successful; CLK_50 fitted to PIN_24; all 59 explicit locations verified; other locations unchanged; new SOF SHA256 716613223262b1ee7a3910bc1ccf6d0cf207918abe48035524b9babe5edd9eca
- display_diagnostic: full compilation successful; CLK_50 fitted to PIN_24; all 41 explicit locations verified; other locations unchanged; new SOF SHA256 522a22b213ae04cdd8fb4cc8c0506edb01cce8ff375e075454d27254f033a09a

Main compilation: 0 errors, 20 warnings (including existing incomplete pin/I/O assignments and clock uncertainty warnings). Diagnostic compilation: 0 errors, 2 warnings. Hardware confirmation remains pending reprogramming.

The following is the historical audit BEFORE this correction; references to PIN_23 and unknown board clock wiring are superseded by the evidence above.

---

# Display audit - 2026-10-13

## Verified

- Main project is EP4CE6E22C8. Latest available full-build report says Successful (647 LEs). All 59 explicit location assignments match the fitted pin report, including C1 DP=70 and C2 DP=68. No brace-wrapped port names remain.
- Current display defaults are active-high for C1/C2/C3; T, K and SW1 remain active-high as requested.
- Q1 exhaustive arithmetic checks, Q2 arithmetic/architecture checks, segment decoding/formatting, top integration, filter equivalence, core equivalence and top equivalence passed. The old top equivalence test used mismatched default display polarities; both instances now explicitly use the current active-high configuration. Only test files were changed.
- New startup simulation verifies 0 / 0 / + after startup in Q1 with zero inputs; holding K4 high blanks all three displays; without a clock they cannot recover; restoring clock with K4 low restores display.
- An independent clock-free segment diagnostic passed simulation and full Quartus compilation (0 errors, 2 warnings: LogicLock license and incomplete I/O standards). All 41 explicit diagnostic locations match its fitted pin report. Its SOF is provided in ../display_diagnostic/output_files/display_diagnostic.sof.

## Most relevant unresolved hardware conditions

1. K4 is mapped to PIN_106 and feeds an asynchronous-assert reset. Any persistent high input holds the entire main design in reset, blanking all segments with the current polarity. The actual idle level has not been measured.
2. Every display output is registered on CLK_50, assigned to PIN_23. The actual oscillator connection has not been confirmed. EP4CE6E22C8 identifies an FPGA, not a board schematic.
3. Display common connections and any external driver/enable circuitry are unknown. Input key polarity does not determine display polarity. The supplied starburst datasheet covers both common-anode AS5010 and common-cathode AS5011, and therefore cannot uniquely identify the fitted circuit.
4. There are no explicit I/O-standard assignments. The last fitter report uses 2.5 V defaults; physical VCCIO is unknown. No voltage change was made without board evidence.
5. Ten main-project ports still lack explicit locations. The fitter assigned K2=120, K3=137, LED10=64, LED11=113, LED12=1, LED13=7, LED14=115, LED15=55, CCLK=59, C3 DP=141. These are automatic placement results, NOT verified board wiring and may change on recompilation. Missing locations do not disable the already assigned C1/C2/C3 segment outputs.
6. The last timing report has positive setup slack of 0.265 ns but warns that clock uncertainty is missing; it is not a complete hardware timing signoff. External input/output timing constraints are also incomplete.

## Scope and next step

Main RTL, existing QSF, board pin selections and the main SOF were preserved. No unverified polarity or clock-pin changes were made. Load the separate diagnostic SOF, toggle SW2, observe LED1 and the complementary LED2/LED3 pair, then supply those observations and a board schematic/model or measured clock/reset/common-terminal information. Hardware fault isolation remains pending those observations; a successful simulation cannot certify wiring.
