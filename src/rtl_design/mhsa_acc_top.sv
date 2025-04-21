//===================================================================== 
// Description: 
// mhsa_acc_top
//  |-- FSM
//  |-- linear(pre)
//  |   |-- linear_q
//  |   |-- linear_k
//  |   |-- linear_v 
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/3/28
// V1 date:Instantiate linear @ 2024/4/21
// ==================================================================== 

module mhsa_acc_top#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096
)(
    input logic clk,
    input logic rst_n,

    // control signals
    input logic start,
    output logic done,
    input logic [31:0] input_base,
    input logic [31:0] output_base,

    // unified sram interface
    output   bar0_write_en,
    output   [WIDTH - 1 : 0] bar0_data_in,
    output   [31 : 0] bar0_addr,
    input logic [WIDTH - 1 : 0] bar0_data_out,

    output   bar1_write_en,
    output   [WIDTH - 1 : 0] bar1_data_in,
    output   [31 : 0] bar1_addr,
    input logic [WIDTH - 1 : 0] bar1_data_out,

    output   bar2_write_en,
    output   [WIDTH - 1 : 0] bar2_data_in,
    output   [31 : 0] bar2_addr,
    input logic [WIDTH - 1 : 0] bar2_data_out,

    output   bar3_write_en,
    output   [WIDTH - 1 : 0] bar3_data_in,
    output   [31 : 0] bar3_addr,
    input logic [WIDTH - 1 : 0] bar3_data_out
);

logic start_linear;
logic done_linear;

// [----------------- fsm -------------------]


// [----------------- linear ----------------- ]

//TODO:use FSM to ctrl start/done
assign start_linear = start;

linear linear_q(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_linear),
    .done(done_linear),

    .write_en_bar0(bar0_write_en),
    .data_in_bar0(bar0_data_in),
    .addr_bar0(bar0_addr),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar1_write_en),
    .data_in_bar1(bar1_data_in),
    .addr_bar1(bar1_addr),
    .data_out_bar1(bar1_data_out)
);

linear linear_k(
    .clk(clk),
    .rst_n(rst_n),

    .start(start),
    .done(done),

    .write_en_bar0(bar0_write_en),
    .data_in_bar0(bar0_data_in),
    .addr_bar0(bar0_addr),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar2_write_en),
    .data_in_bar1(bar2_data_in),
    .addr_bar1(bar2_addr),
    .data_out_bar1(bar2_data_out)
);

linear linear_v(
    .clk(clk),
    .rst_n(rst_n),

    .start(start),
    .done(done),

    .write_en_bar0(bar0_write_en),
    .data_in_bar0(bar0_data_in),
    .addr_bar0(bar0_addr),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar3_write_en),
    .data_in_bar1(bar3_data_in),
    .addr_bar1(bar3_addr),
    .data_out_bar1(bar3_data_out)
);



endmodule