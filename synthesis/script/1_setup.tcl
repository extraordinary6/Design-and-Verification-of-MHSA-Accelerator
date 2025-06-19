set std_path   		"/home/MicroE/library/lib"
set search_path 	"$std_path"

set target_library	"gscl45nm.db SRAM.db"
set dw_library     	"/opt/synopsys/syn/O-2018.06-SP1/libraries/syn/dw_foundation.sldb"
#set link_library        "* $target_library $dw_library"

set link_library        "* $target_library"

define_name_rules BORG -type net -allowed "A-Z a-z 0-9" -first_restricted "_0-9\\" \
        -last_restricted "_0-9\\" -max_length 30

suppress_message LINT-31
suppress_message LINT-52
suppress_message LINT-28
suppress_message LINT-2
suppress_message LINT-1