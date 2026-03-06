proc make_result_dir { } {
  variable result_dir
  set result_dir results
  if { ![file exists $result_dir] } {
    file mkdir $result_dir
  }
  return $result_dir
}

proc make_result_file { filename } {
  variable result_dir

  make_result_dir

  set root [file rootname $filename]
  set ext [file extension $filename]
  set filename "$root-tcl$ext"
  return [file join $result_dir $filename]
}

