//===================================================================== 
// Description: 
// mhsa_acc_top
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/3/28
// ==================================================================== 

module mhsa_acc_top#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096
)(
    input logic clk,
    input logic rst_n,

    // control signals
    output logic done,
    input logic [31:0] input_base,
    input logic [31:0] output_base,

    // unified sram interface
    output   acc_write_en,                       //1 for write, 0 for read
    output   [WIDTH - 1 : 0] acc_data_in,
    output   [31 : 0] acc_addr,
    input logic [WIDTH - 1 : 0] acc_data_out
);




endmodule