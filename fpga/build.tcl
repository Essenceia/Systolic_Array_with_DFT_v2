set project_path [lindex $argv 0]
set bit_path [lindex $argv 1]
set checkpoint_path [lindex $argv 2]
if { $argc > 3 } {
	set enable_debug_core [lindex $argv 3]
	set debug_probes_path [lindex $argv 4]
} else {
	set enable_debug_core 0
	set debug_probes_path "/tmp/dump"
}
puts "Implementation script called with project path $project_path, generating checkpoint at $checkpoint_path, bitfile at $bit_path"

open_project $project_path 

# synth
synth_design -top emulator

if { $enable_debug_core } {
	source debug_core.tcl
} 

# implement
opt_design
place_design
route_design
phys_opt_design
report_timing_summary -no_detailed_paths

if { $enable_debug_core } {
	write_debug_probes -force $debug_probes_path
	report_debug_core
}

# bistream 
puts "Writing bistream at $bit_path"
write_bitstream "$bit_path" -force

write_checkpoint $checkpoint_path -force 
close_project
exit 0
