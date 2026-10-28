# Verification for the requested EP4CE6E22C8 device; no board pin assignments.
package require ::quartus::project
project_new mini_project_check -overwrite
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE6E22C8
set_global_assignment -name NUM_PARALLEL_PROCESSORS 4
source ../../add_sources.tcl
project_close
