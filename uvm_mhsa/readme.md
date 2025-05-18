在MHSA_Accelerator_E203目录下打开powershell  

启用断言、覆盖率的编译(vlog)，仿真(vsim)指令：      
vlog +incdir+<questasim_dir>/verilog_src/uvm-1.2/src -cover sbceft ./uvm_mhsa/my_top.sv

vsim -gui work.my_top -novopt -assertdebug -coverage -sv_lib <questasim_dir>/uvm-1.2/win64/uvm_dpi +UVM_TESTNAME=test0

运行仿真：
run -all

输出覆盖率报告：     
coverage report -output ./uvm_mhsa/report/coverage_report.txt
