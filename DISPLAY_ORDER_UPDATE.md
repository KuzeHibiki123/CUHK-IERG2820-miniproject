# Display order and segment F verification

Decimal result physical order is C1 (hundreds), C3 (tens), C2 (ones). Leading hundreds/tens are blanked; units always show. Input preview and hexadecimal layout are unchanged. Both Q1 results and Q2 register displays use the corrected formatter.

C3[7] remains segment F on user-confirmed PIN_53. The previous full-build pin report already used PIN_53. No missing F truth-table entry was found: decimal 0,4,5,6,8,9 assert this output. Added an independent expected-F test plus Q2 result 42 integration assertion. All 256 decimal/hex formatter values, 16 glyphs, polarity/blanking tests, arithmetic, integration, equivalence and startup regressions passed. Isolated F test simulation passed.

All existing pin assignments were preserved and verified against final fitter reports. Main and isolated F projects completed full compilation. Main resource use: 641 / 6,272 ( 10 % ). Added derive_clock_uncertainty and placement SEED=2; minimum reported internal setup slack is 0.268 ns at 50 MHz. External I/O constraints and ten unassigned main-project locations remain incomplete; this is not full board timing signoff.

Main SOF: build/quartus_project/mini_project.sof
Isolated F SOF: ../starburst_f_test/output_files/starburst_f_test.sof

In the isolated test, SW2 controls only F and LED1; no clock or reset is required. If LED1 switches but F remains dark, measure PIN_53 and check the cable/F terminal. Hardware confirmation remains pending; simulation and fitting do not prove physical segment continuity.

Backups are under backups/display_order_before_20261013.
