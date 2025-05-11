//=====================================================================
// Description:
// dut_top and assertion
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.2 Initial version, Huang Chaofan
// V1 date: 4.28 add assertion, Huang Chaofan
// ====================================================================

`timescale 1ns/1ps

module dut #(
  parameter ID = 0
)
(
  dut_if    mhsa_if
);

  dut_top u_dut_top
  (
    .mhsa_if       (mhsa_if.slave      )
  );

  // assertion
  if(ID == 0)
  begin
    bind mhsa_acc_wrapper if_assertion
    if_assertion_bind_mhsa_acc_wrapper
    (
      .mhsa_if     (mhsa_if.others     )
    );
  end

endmodule : dut