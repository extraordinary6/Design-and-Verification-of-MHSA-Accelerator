#In actual project, to prevent synthesis tools from mapping std cell 
# with either too large or too small drive strengths that can cause driving issues, 
# X0 or X32 are usually disabled.

# set_dont_use [get_lib_cells */*X0_RVT]
# set_dont_use [get_lib_cells */*X32_RVT]

set compile_enable_datapath_opt true
set compile_seqmap_merge_identical_modules true
set compile_ultra_optimization true
set compile_use_timing_driven true
set power_collapse true
