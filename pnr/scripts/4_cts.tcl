# Create by lisp
### forth stage : clock tree synthesis

## 4.1 set clock tree setting
# 1. set rule : "ndr"
add_ndr -name cts_w2s2 \
        -width_multiplier {M4:M6 2} \
	-spacing_multiplier {M4:M6 2}
# 2. set "ndr" rule for trunk rule
create_route_type -name trunk_rule \
        -non_default_rule cts_w2s2 \
        -top_preferred_layer 6 \
        -bottom_preferred_layer 4

# 3. set clock tree property
set_ccopt_property  route_type trunk_rule \
        -net_type   trunk

set_ccopt_property buffer_cells [list CLKBUF1 CLKBUF2 CLKBUF3]

set_ccopt_property inverter_cells [list INVX1 INVX2 INVX4]

create_ccopt_clock_tree_spec

## 4.2 create_clock_tree
setNanoRouteMode -routeTopRoutingLayer 6
ccopt_design

### FIX TIMING, MODIFIED SDC
set_interactive_constraint_modes [all_constraint_modes -active]

reset_clock_latency [all_clocks]
set_propagated_clock [all_clocks]
set_false_path -from [all_inputs -no_clocks] -to [all_registers]
set_clock_uncertainty -hold 0 [get_clocks clk] 

set_interactive_constraint_modes {}

## 4.3 timing opt after create cts
timeDesign -postCTS

setOptMode -setupTargetSlack 0.00 -holdTargetSlack 0.10

# optDesign -postCTS -setup

# optDesign -postCTS -hold

saveDesign ./design/4_cts.enc

