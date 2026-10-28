# Lab requirements correction — 2026-10-14

This update supersedes the full-byte chaining change in REPEAT_MULTIPLY_FIX.md
and the K4 reset behavior described in earlier reports.

## No user-accessible reset

K4 is no longer connected to any internal logic. The existing K[4] port and
PIN_106 assignment remain reserved for compatibility, but K4 may be left
unconnected. The final synthesis report confirms no output depends on K[4].
The initialized two-bit startup sequence releases internal initialization after
configuration. It cannot be triggered by a button during the experiment.
K4 also cannot reset the clock selection or blank the displays.

## Required continuous multiplication

The board top now defaults to Q1_CHAIN_8BIT=0. Each repeated Q1 operation uses
only the previous result's bits 3:0. A multiplication still produces and
displays its complete eight-bit result before that feedback truncation.

- 15*15 = 225 (0xE1); another equals computes 1*15 = 15.
- 2*2, followed by repeated equals: 4, 8, 16, 0, 0.
- An initial product 32 (0x20) feeds back as zero on the next operation.

The optional full-byte parameter is retained for comparison tests but is not
enabled in the board project. Q2's specified A/B product storage is unchanged.
K2 still selects 50 MHz / 1 Hz, starts in 50 MHz after configuration, and uses
PIN_101. CCLK stays on PIN_141. The 50 MHz source remains required on PIN_24.

## Verification and artifact

All eleven testbenches passed. Updated tests check actual-default low-nibble
results, floating/high/unknown K4, preservation of Q1/Q2 registers when K4
changes, and preservation of slow clock selection when K4 changes. The startup
test starts with K4 disconnected (Z). Arithmetic equivalence tests still cover
both configurable chaining widths.

Quartus compilation completed 2026-10-14 at 22:31:25: zero errors, 12 warnings.
The warning that K[4] drives no output is expected. Final fit: 762 LE,
292 registers, one 9-bit multiplier element, zero RAM bits. This is 15 fewer
LE than the prior K2 build. All nine internal timing checks pass at 50 MHz:
worst setup slack 1.431 ns, worst hold slack 0.186 ns. Board I/O delays remain
unspecified; this is not complete board timing signoff.

All 62 explicit pin assignments were preserved and checked against the fitter.
Program `build/quartus_project/mini_project.sof`, not the separate diagnostic
SOF. The file has been generated and verified, but not tested on the physical
board in this session.

Logs: `build/no_k4_tests.log`, `build/no_k4_compile.log`.
Release metadata: `build/no_k4_release_audit.json`.
Backup: `backups/before_no_k4_low_nibble_20261014`.
