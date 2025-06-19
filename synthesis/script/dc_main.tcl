set_host_options -max_cores 4

set top "mhsa_acc_wrapper"

source ../script/1_setup.tcl

set_svf ../svf/${top}.svf

source ../script/2_read_file.tcl

current_design $top

check_design 

source ../script/3_set_main_clk.tcl

source ../script/4_set_mode_inout_drc_load.tcl

source ../script/5_set_synthesis_instruction.tcl

link

compile

source ../script/6_write_file.tcl

set_svf -off

