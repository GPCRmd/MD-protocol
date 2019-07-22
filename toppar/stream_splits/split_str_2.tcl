#! /usr/bin/env tclsh



proc split_str {strfiles} {
  foreach strfile $strfiles {
    set readrtfn 1
    set readinpn 1
    set strh [open "$strfile" r]
    set inputbuffer {}
    while {![eof $strh] } {
      set inputbuffer [read $strh 4096]
      if {[regexp -lineanchor -nocase {^\s*read\s+rtf\s+card.*?$(.*)} $inputbuffer -> rtftext]} {
	puts "$strfile: READ RTF CARD..."
	set rtfh [open "[file rootname $strfile]_${readrtfn}.rtf" w]
	set inputbuffer $rtftext
	while {!([set found [regexp -lineanchor -nocase {(.*?)^\s*end(\s*|\s+[*!].*)$} $inputbuffer -> rtftext]] || [eof $strh])} {
	  puts -nonewline $rtfh $inputbuffer
	  set inputbuffer [read $strh 4096]
	}

	if {[eof $strh] && !$found} {set rtftext $inputbuffer}
	puts -nonewline $rtfh $rtftext
	close $rtfh
	incr readrtfn
      }

      if {[regexp -lineanchor -nocase {^\s*read\s+param?\s+card.*?$(.*)} $inputbuffer -> inptext]} {
	puts "$strfile: READ PARA CARD..."
	set inph [open "[file rootname $strfile]_${readinpn}.inp" w]
	set inputbuffer $inptext
	while {!([set found [regexp -lineanchor -nocase {(.*?)^\s*end(\s*|\s+[*!].*)$} $inputbuffer -> inptext]] || [eof $strh])} {
	  puts -nonewline $inph $inputbuffer
	  set inputbuffer [read $strh 4096]
	}
	if {[eof $strh] && !$found} {set inptext $inputbuffer}
	puts -nonewline $inph $inptext	
	incr readinpn
	close $inph
      }
      
    }
    close $strh
  }
}



split_str $argv

exit