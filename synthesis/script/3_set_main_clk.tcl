# set CLK_PERIOD  [expr 1000.00/1000.00]
set CLK_PERIOD  6.65

# create_clock -period $CLK_PERIOD [ ________ clk]   #在横线上选填get_ports/get_pins/get_nets
create_clock -name clk -period $CLK_PERIOD [get_ports clk]

set input_ports [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay 0.2 -clock clk [all_inputs]
set_output_delay 0.2 -clock clk [all_outputs]

set_clock_uncertainty -setup 0.1 clk
set_clock_uncertainty -hold  0.2 clk
set_clock_transition         0.2 clk

group_path -name in2reg -from [all_inputs]
group_path -name reg2out -to [all_outputs]
group_path -name in2out -from [all_inputs] -to [all_outputs]
