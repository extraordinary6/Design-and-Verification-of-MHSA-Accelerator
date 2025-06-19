# Create by lisp
### first stage : initial design

## 1.1 define power & ground network of design
set init_gnd_net {VSS}
set init_pwr_net {VDD}

set init_lef_file { \
/home/MicroE/library/lef/gscl45nm.lef \
/home/MicroE/library/lef/IO.lef \
/home/MicroE/library/lef/SRAM.lef \
}

## 1.3 define other info
set init_top_cell {mhsa_acc_wrapper} ;# top cell name
# !!![NEED-TO-DO]!!!
set init_verilog {./netlist/mhsa_acc_wrapper.mapped.v}
# mmmc means multi modes multi corners, sdc is read in the mmmc.view
set init_mmmc_file {./netlist/mmmc.tcl}

## 1.4 init_design: after initial deisgn, remember to check whether "ERROR" in the run.log
init_design

saveDesign ./design/1_init.enc
