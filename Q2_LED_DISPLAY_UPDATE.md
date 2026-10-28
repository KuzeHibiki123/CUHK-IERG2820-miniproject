# Q2 binary/numeric display synchronization — 2026-10-15

LED1–8 now display the same selected register value as C1/C2/C3.
LED1 remains bit 0, and LED8 remains bit 7.

- Default: A on both binary LEDs and numeric displays.
- LOAD B/C: the selected display stays unchanged; default A remains visible.
- OUT B/C: both displays select B/C and retain that selection.
- OUT A: both displays return to A.
- Decimal/hexadecimal toggling changes the numeric format, not the binary value.

The LED path samples Q2's selected display value on the same 50 MHz edge as
the display ROMs. This preserves their common one-cycle output latency during
register writes and OUT selection changes. Q1's binary LEDs retain their
original behavior. LED9 carry, LED10 latest-instruction zero, LED15 busy and
LED16 error retain their previous status meanings; they are not numeric bits.

Modified production RTL: `rtl/mini_project_top.v`. Q2 arithmetic and all pin
assignments are unchanged. The reference top was updated to reflect the new
specified LED behavior, and `tb_q2_led_display.v` was added to the test suite.

All 13 testbenches pass, including 5,009 cycle-by-cycle checks of binary versus
decimal/hex segment output. Directed cases cover LOAD A/B/C, OUT A/B/C, sticky
selection during arithmetic, multiplication high-byte updates, NOP, both clock
rates, and ignored K4. Existing arithmetic, ROM, input-filter and full-top
regression tests pass.

Quartus compile completed at 09:46:47 local time: zero errors, 21 warnings.
Fitted use: 633 LE, 268 logic registers, three M9K blocks (24,576 bits), two
9-bit multiplier elements. The earlier area-only build was 610 LE/260 registers;
this update adds eight binary display output registers. All nine internal
timing checks pass: worst setup slack 1.040 ns, worst hold slack 0.186 ns.
Board I/O delays remain unspecified and this session has not tested hardware.

All 62 explicit locations match the backup and the fitted pin report.
Program `build/quartus_project/mini_project.sof`.
Logs: `build/q2_led_tests.log`, `build/q2_led_compile.log`.
Release hash and checks: `build/q2_led_release_audit.json`.
Backup: `backups/before_q2_led_display_20261015`.
