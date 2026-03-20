set all_sc [get_cells -hier * -filter {ORIG_REF_NAME =~ "sg13g2_sdfrbpq_*"}]


set sdc_pin [get_pins -of_objects  [lindex $all_sc 0] -filter { REF_PIN_NAME == SCD }]
set prev_ff [all_fanin $sdc_pin -only_cells] 
set prev_sf [get_cells [get_property PARENT $prev_ff]]

proc get_next_sf { current } {
	set sdc_pin [get_pins -of_objects  $current -filter { REF_PIN_NAME == SCD }]
	set prev_ff [all_fanin $sdc_pin -only_cells -startpoints_only] 
	set prev_sf [get_cells [get_property PARENT $prev_ff]]
	return $prev_sf 
}

proc search_scan_chain { last_sf } {
	set i 0
	puts "$i: [get_property NAME $last_sf]"
	set flop_type [get_property ORIG_REF_NAME $last_sf]
	while { string equal $flop_type "sg13g2_sdfrbpq_1" || string equal $flop_type "sg13g2_sdfrbpq_2" } {
		set last_sf [ get_next_sf $last_sf ]
		set flop_type [get_property ORIG_REF_NAME $last_sf]
		puts "$i: [get_property NAME $last_sf]"
	}
}
