proc get_all_ff { clk } {
	return [get_cells [all_registers -clock $clk ]]
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

proc exclude_from_scan_chain { jtag_clk } {
	set jtag_dff [get_all_ff $jtag_clk]
	set_dont_touch_instance_list $jtag_dff
}

proc cleanup_dont_touch { jtag_clk } {
	set jtag_dff [get_all_ff $jtag_clk]
	clear_dont_touch_instance_list $jtag_dff
}

proc add_scan_chain { } {

	puts "Current state of don't touch, will be excluded from scan chain"
	report_dont_touch 
	
	scan_replace

	report_dft_plan -verbose 

	execute_dft_plan 

}

proc write_scan_chain_translate { filename block } {
	set csv_out [open "$filename" "w"]
	set dft [$block getDft]
	set chains [$dft getScanChains]
	if { [llength $chains] > 1 } {
		utl::error ADD_SCAN_CHAIN_TCL 2  "Warning: expecting a single chain! got {}" [llength $chains]
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

