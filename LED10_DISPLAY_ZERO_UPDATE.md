# LED10 displayed-register zero indicator — 2026-10-15

In Q2, LED10 is on exactly when the currently displayed register is zero.
This includes default A and the sticky OUT A/B/C selection. Writes to an
unselected register cannot change LED10. Decimal/hex selection does not
change its meaning. In Q1 LED10 remains off.

The top compares the existing sampled display value with zero. This aligns
LED10 with LED1–8 and C1/C2/C3 on register updates and OUT selection changes.
No additional register or arithmetic operation is introduced. The standalone
Q2 core's result and zero outputs retain their existing API and behavior.
The unused latest-result register is optimized out of the board design.
Carry/error/busy indicators and all user pin assignments are unchanged.

Verification: all 13 testbenches pass, including 9,917 cycle checks of LED10,
binary LEDs and numeric displays. Directed cases cover default A=0, zero and
nonzero A/B/C, writes to unselected registers, sticky selection, hexadecimal,
slow clock operation and Q1 LED10 off.

Quartus compilation: zero errors, 21 warnings. Target EP4CE6E22C8.
Resources: 632 LE, 260 registers, three M9K blocks (24,576 bits), two embedded
9-bit multiplier elements. Previous build: 633 LE, 268 registers.
All nine internal 50 MHz timing checks pass; worst setup slack 1.552 ns,
worst hold slack 0.186 ns. Board I/O delays remain unspecified.
All 62 explicit pin assignments match both the backup and fitted pin report.
Hardware has not been tested in this session.

Program: `build/quartus_project/mini_project.sof`.
Logs: `build/led10_tests.log`, `build/led10_compile.log`.
Release checks and SHA-256: `build/led10_release_audit.json`.
Backup: `backups/before_led10_display_zero_20261015`.
