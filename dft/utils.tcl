proc get_driving_dff_inst { net } {
	foreach p [get_pins -of_object $net] {
		set driver_pin [get_name $p] 
		if {$driver_pin == "Q"} {
			return [$p instance]
		}
	}
	puts "WARNING: driving ff not found for [get_name $net]"
}

proc get_all_jtag_ff { match } {
	set ff_inst {}
	set nets [get_nets $match]
	foreach n $nets {
		lappend ff_inst [get_driving_dff_inst $n]
	}
	return $ff_inst
}

proc set_dont_touch_instance_list { ilist } {
	foreach i $ilist {
		set_dont_touch $i
	}
}

proc clear_dont_touch_instance_list { ilist } {
foreach i $ilist {
		unset_dont_touch $i
	}	
}

proc add_scan_chain { } {
	# exclude jtag from scan chain
	set jtag_inst_list [get_all_jtag_ff m_jtag*]
	set_dont_touch_instance_list $jtag_inst_list 
	report_dont_touch 
	
	scan_replace

	report_dft_plan -verbose 

	execute_dft_plan 

	clear_dont_touch_instance_list $jtag_inst_list

	report_dont_touch
}

proc get_ff_q_net_name { inst } {
	
}
	
proc write_scan_chain_translate { filename block } {
	set csv_out [open "$filename" "w"]
	set dft [$block getDft]
	set chains [$dft getScanChains]
	if { [llength $chains] > 1 } {
		puts "Warning: expecting a single chain !"
		error
	}
	foreach chain $chains {
		puts  "Writing scan chain '[$chain getName]' to file"
	    set partitions [$chain getScanPartitions]
	    foreach partition $partitions {
	        set lists [$partition getScanLists]
	        foreach list $lists {
	            set insts [$list getScanInsts]
	            set last_clk "\$"
	            set last_edge "\$"
	            foreach inst $insts {
	                set current_clk [$inst getScanClock]
	                set current_edge [$inst getClockEdge]
	                if { "$last_clk" != "$current_clk" || "$last_edge" != "$current_edge" } {
	                    set inv_string ""
	                    if { "$current_edge" == "1" } {
	                        set inv_string "!"
	                    }
						set clk $inv_string$current_clk
	                    set last_clk "$current_clk"
	                    set last_edge "$current_edge"
	                }
					set q_name [[[[$inst getInst] getFirstOutput] getNet] getName] 
					puts $csv_out "[[$inst getInst] getName],$q_name, $clk"
	            }
	        }
	    }
	}
	close $csv_out

} 

