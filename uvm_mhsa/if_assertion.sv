//=====================================================================
// Description:
// Interface assertion for mhsa
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.28 Initial version, Huang Chaofan
// ====================================================================

module if_assertion (
  dut_if.others   mhsa_if
);

  // Signal X Assertion
  property start_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    not ($isunknown(mhsa_if.start));
  endproperty : start_no_x_check

  property done_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    not ($isunknown(mhsa_if.done));
  endproperty : done_no_x_check

  property input_base_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    not ($isunknown(mhsa_if.input_base));
  endproperty : input_base_no_x_check

  property output_base_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    not ($isunknown(mhsa_if.output_base));
  endproperty : output_base_no_x_check

  property soc_write_en_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    not ($isunknown(mhsa_if.soc_write_en));
  endproperty : soc_write_en_no_x_check

  property soc_data_in_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    mhsa_if.soc_write_en |-> (not ($isunknown(mhsa_if.soc_data_in)));
  endproperty : soc_data_in_no_x_check

  property soc_addr_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    mhsa_if.soc_write_en |-> (not ($isunknown(mhsa_if.soc_addr)));
  endproperty : soc_addr_no_x_check

  property soc_data_out_no_x_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    mhsa_if.done |-> (not ($isunknown(mhsa_if.soc_data_out)));
  endproperty : soc_data_out_no_x_check

  check_start_no_x: assert property (start_no_x_check) else $error($stime, "\t\t FATAL: 'start' exists X!\n");
  check_done_no_x: assert property (done_no_x_check) else $error($stime, "\t\t FATAL: 'done' exists X!\n");
  check_input_base_no_x: assert property (input_base_no_x_check) else $error($stime, "\t\t FATAL: 'input_base' exists X!\n");
  check_output_base_no_x: assert property (output_base_no_x_check) else $error($stime, "\t\t FATAL: 'output_base' exists X!\n");
  check_soc_write_en_no_x: assert property (soc_write_en_no_x_check) else $error($stime, "\t\t FATAL: 'soc_write_en' exists X!\n");
  check_soc_data_in_no_x: assert property (soc_data_in_no_x_check) else $error($stime, "\t\t FATAL: 'soc_data_in' exists X!\n");
  check_soc_addr_no_x: assert property (soc_addr_no_x_check) else $error($stime, "\t\t FATAL: 'soc_addr' exists X!\n");
  check_soc_data_out_no_x: assert property (soc_data_out_no_x_check) else $error($stime, "\t\t FATAL: 'soc_data_out' exists X!\n");

  // Siganl Stable Assertion
  property start_keep_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    mhsa_if.start |-> mhsa_if.start until mhsa_if.done;
  endproperty : start_keep_check

  property input_base_keep_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    (!mhsa_if.done) |-> $stable(mhsa_if.input_base);
  endproperty : input_base_keep_check

  property output_base_keep_check;
    @(posedge mhsa_if.clk) disable iff (!mhsa_if.rst_n)
    (!mhsa_if.done) |-> $stable(mhsa_if.output_base);
  endproperty : output_base_keep_check

  check_start_keep: assert property (start_keep_check) else $error($stime, "\t\t FATAL: 'start' is not stable!\n");
  check_input_base_keep: assert property (input_base_keep_check) else $error($stime, "\t\t FATAL: 'input_base' is not stable!\n");
  check_output_base_keep: assert property (output_base_keep_check) else $error($stime, "\t\t FATAL: 'output_base' is not stable!\n");
 
    

endmodule : if_assertion