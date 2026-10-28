# In an OPEN Quartus project: source <absolute_path>/add_sources.tcl
# Sets the requested device. Board pin assignments remain in your own project.
set src_dir [file dirname [file normalize [info script]]]
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE6E22C8
set_global_assignment -name TOP_LEVEL_ENTITY mini_project_top
set_global_assignment -name OPTIMIZATION_TECHNIQUE AREA
foreach src {
    hex7_decoder.v c1_display.v c2_display.v c3_display.v display_formatter.v
    input_filter.v clock_enable.v question1.v question2.v registered_display_rom.v mini_project_top.v
} {
    set_global_assignment -name VERILOG_FILE [file join $src_dir rtl $src]
}
set_global_assignment -name SDC_FILE [file join $src_dir mini_project.sdc]
