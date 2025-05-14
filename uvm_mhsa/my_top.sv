//=====================================================================
// Description:
// my top
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.6 Initial version, Huang Chaofan
// ====================================================================

`timescale 1ns/1ns
`include "uvm_pkg.sv"
//`include "C:/questasim64_10.4c/verilog_src/uvm-1.2/src/uvm_pkg.sv"  //also ok 

// include RTL DUT
`include "../src/rtl_design/attmm.sv"
`include "../src/rtl_design/connect.sv"
`include "../src/rtl_design/icb_usram_bus.sv"
`include "../src/rtl_design/linear.sv"
`include "../src/rtl_design/mem_wk.sv"
`include "../src/rtl_design/mem_wq.sv"
`include "../src/rtl_design/mem_wv.sv"
`include "../src/rtl_design/mem_x.sv"
`include "../src/rtl_design/mem.sv"
`include "../src/rtl_design/mhsa_acc_top.sv"
`include "../src/rtl_design/mhsa_acc_wrapper.sv"
`include "../src/rtl_design/mm_pe.sv"
`include "../src/rtl_design/mm_systolic.sv"
`include "../src/rtl_design/qkmm.sv"
`include "../src/rtl_design/scale_core.sv"
`include "../src/rtl_design/softmax.sv"

// include assertion file
`include "if_assertion.sv"
`include "dut_top.sv"
`include "dut.sv"
`include "dut_if.sv"
`include "my_sequence_pkg.sv"
`include "my_agent_pkg.sv"
`include "my_env_pkg.sv"
`include "my_test_pkg.sv"

module my_top;

  import uvm_pkg::*;
  import my_sequence_pkg::*;
  import my_agent_pkg::*;
  import my_env_pkg::*;
  import my_test_pkg::*;
  parameter NUM_ENV = 4;

  genvar i;

  generate
    for(i = 0; i < NUM_ENV; i++) begin

      logic clock;
      initial begin
        clock = 0;
        forever #(5+i) clock = ~clock;
      end

      logic reset_n;
      initial begin
        reset_n = 0;
        repeat(3) @(negedge clock);
        reset_n = 1;
      end

      dut_if u_dut_if(clock, reset_n);
      
      // siganl initialization
      initial begin
        u_dut_if.start = 0;
        u_dut_if.soc_write_en = 0;
        u_dut_if.soc_data_in = 0;
        u_dut_if.soc_addr = 0;
        u_dut_if.input_base = 0;
        u_dut_if.output_base = 0;
      end

      dut #(.ID(i)) u_dut(.mhsa_if(u_dut_if));

      initial begin
        uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top", $sformatf("dut_vif_i%1d", i), u_dut_if);
        uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top", $sformatf("dut_vif_o%1d", i), u_dut_if);
      end

    end //for
  endgenerate

  initial begin
    run_test();
  end
endmodule : my_top
