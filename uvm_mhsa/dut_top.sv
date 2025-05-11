//=====================================================================
// Description:
// DUT instantation
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 5.11 Initial version, Huang Chaofan
// ====================================================================

`timescale 1ns/1ps

module dut_top(
    dut_if.slave mhsa_if
);

  // inst mhsa_wrapper
  mhsa_acc_wrapper #(
    .WIDTH       (64                  ),
    .LENGTH      (4096                )
  ) u_mhsa_acc_wrapper
  (
    .clk         (mhsa_if.clk          ),
    .rst_n       (mhsa_if.rst_n        ),

    .done        (mhsa_if.done         ),
    .start       (mhsa_if.start        ),
    .input_base  (mhsa_if.input_base   ),
    .output_base (mhsa_if.output_base  ),

    .soc_write_en(mhsa_if.soc_write_en ),
    .soc_data_in (mhsa_if.soc_data_in  ),
    .soc_addr    (mhsa_if.soc_addr     ),
    .soc_data_out(mhsa_if.soc_data_out )
  );

endmodule : dut_top