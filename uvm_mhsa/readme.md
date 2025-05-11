启用断言、覆盖率：
vlog +incdir+D:/questasim/questa_sim/verilog_src/uvm-1.2/src -cover sbceft C:/Users/Xypher/Desktop/master/SoC_design_method/project/MHSA_Accelerator_E203/uvm_mhsa/my_top.sv

vsim -gui work.my_top -novopt -assertdebug -coverage -sv_lib D:/questasim/questa_sim/uvm-1.2/win64/uvm_dpi +UVM_TESTNAME=test0

输出覆盖率报告：
coverage report -output ./report/coverage_report.txt