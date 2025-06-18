//===================================================================== 
// Description: 
// mhsa_acc_wrapper
//  |-- arbiter (2-level)
//  |   |-- soc/acc arb
//  |   |-- mem address map arbiter
//  |-- mem
//  |   |-- bar0
//  |   |-- bar1
//  |   |-- bar2
//  |   |-- bar3
//  |-- mhsa_acc_top
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2025/3/28
// V1 date:Modify arb logic @ 2025/4/21
// ==================================================================== 

module mhsa_acc_wrapper#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096
)(
    input logic clk,
    input logic rst_n,

    // control signals
    output logic done,
    input logic start,
    input logic [31:0] input_base,
    input logic [31:0] output_base,

    // unified sram interface
    input   soc_write_en,                       //1 for write, 0 for read
    input   [WIDTH - 1 : 0] soc_data_in,
    input   [31 : 0] soc_addr,
    output logic [WIDTH - 1 : 0] soc_data_out
);

logic acc_bar0_write_en;
logic acc_bar1_write_en;
logic acc_bar2_write_en;
logic acc_bar3_write_en;
logic [WIDTH - 1 : 0] acc_bar0_data_in;
logic [WIDTH - 1 : 0] acc_bar1_data_in;
logic [WIDTH - 1 : 0] acc_bar2_data_in;
logic [WIDTH - 1 : 0] acc_bar3_data_in;
logic [31 : 0] acc_bar0_addr;
logic [31 : 0] acc_bar1_addr;
logic [31 : 0] acc_bar2_addr;
logic [31 : 0] acc_bar3_addr;
logic [WIDTH - 1 : 0] acc_bar0_data_out;
logic [WIDTH - 1 : 0] acc_bar1_data_out;
logic [WIDTH - 1 : 0] acc_bar2_data_out;
logic [WIDTH - 1 : 0] acc_bar3_data_out;

logic bar0_write_en;
logic bar1_write_en;
logic bar2_write_en;
logic bar3_write_en;
logic [WIDTH - 1 : 0] bar0_data_in;
logic [WIDTH - 1 : 0] bar1_data_in;
logic [WIDTH - 1 : 0] bar2_data_in;
logic [WIDTH - 1 : 0] bar3_data_in;
logic [31 : 0] bar0_addr;
logic [31 : 0] bar1_addr;
logic [31 : 0] bar2_addr;
logic [31 : 0] bar3_addr;
logic [WIDTH - 1 : 0] bar0_data_out;
logic [WIDTH - 1 : 0] bar1_data_out;
logic [WIDTH - 1 : 0] bar2_data_out;
logic [WIDTH - 1 : 0] bar3_data_out;

// [-------------------------- mhsa_acc_top --------------------------]

mhsa_acc_top #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) mhsa_acc_top_inst (
    .clk(clk),
    .rst_n(rst_n),

    // control signals
    .start(start),
    .done(done),
    .input_base(input_base),
    .output_base(output_base),

    // unified sram interface
    .bar0_write_en(acc_bar0_write_en),
    .bar0_data_in(acc_bar0_data_in),
    .bar0_addr(acc_bar0_addr),
    .bar0_data_out(acc_bar0_data_out),

    .bar1_write_en(acc_bar1_write_en),
    .bar1_data_in(acc_bar1_data_in),
    .bar1_addr(acc_bar1_addr),
    .bar1_data_out(acc_bar1_data_out),

    .bar2_write_en(acc_bar2_write_en),
    .bar2_data_in(acc_bar2_data_in),
    .bar2_addr(acc_bar2_addr),
    .bar2_data_out(acc_bar2_data_out),

    .bar3_write_en(acc_bar3_write_en),
    .bar3_data_in(acc_bar3_data_in),
    .bar3_addr(acc_bar3_addr),
    .bar3_data_out(acc_bar3_data_out)
);

// [-------------------------- arbiter --------------------------]
// address map
// 4096 = 2^12 = 12 bits address
// bar0 base address : 0x0000_0000
// bar1 base address : 0x0000_1000
// bar2 base address : 0x0000_2000
// bar3 base address : 0x0000_3000
logic sel_bar0, sel_bar1, sel_bar2, sel_bar3;
logic sel_bar0_1d, sel_bar1_1d, sel_bar2_1d, sel_bar3_1d;

assign sel_bar0 = (soc_addr >= 32'h0000_0000 && soc_addr < 32'h0000_1000);
assign sel_bar1 = (soc_addr >= 32'h0000_1000 && soc_addr < 32'h0000_2000);
assign sel_bar2 = (soc_addr >= 32'h0000_2000 && soc_addr < 32'h0000_3000);
assign sel_bar3 = (soc_addr >= 32'h0000_3000 && soc_addr < 32'h0000_4000);

// read data valid signal
always_ff @( clk ) begin
    sel_bar0_1d <= sel_bar0;
    sel_bar1_1d <= sel_bar1;
    sel_bar2_1d <= sel_bar2;
    sel_bar3_1d <= sel_bar3;
end

assign bar0_write_en = start ? acc_bar0_write_en : (sel_bar0 ? soc_write_en : 0);
assign bar1_write_en = start ? acc_bar1_write_en : (sel_bar1 ? soc_write_en : 0);
assign bar2_write_en = start ? acc_bar2_write_en : (sel_bar2 ? soc_write_en : 0);
assign bar3_write_en = start ? acc_bar3_write_en : (sel_bar3 ? soc_write_en : 0);

assign bar0_data_in = start ? acc_bar0_data_in : (sel_bar0 ? soc_data_in : 0);
assign bar1_data_in = start ? acc_bar1_data_in : (sel_bar1 ? soc_data_in : 0);
assign bar2_data_in = start ? acc_bar2_data_in : (sel_bar2 ? soc_data_in : 0);
assign bar3_data_in = start ? acc_bar3_data_in : (sel_bar3 ? soc_data_in : 0);

assign bar0_addr = start ? acc_bar0_addr : (sel_bar0 ? {20'h0,soc_addr[11:0]} : 0);
assign bar1_addr = start ? acc_bar1_addr : (sel_bar1 ? {20'h0,soc_addr[11:0]} : 0);
assign bar2_addr = start ? acc_bar2_addr : (sel_bar2 ? {20'h0,soc_addr[11:0]} : 0);
assign bar3_addr = start ? acc_bar3_addr : (sel_bar3 ? {20'h0,soc_addr[11:0]} : 0);

assign soc_data_out = start ? 0 : (sel_bar0_1d ? bar0_data_out : 
                                   sel_bar1_1d ? bar1_data_out : 
                                   sel_bar2_1d ? bar2_data_out : 
                                   sel_bar3_1d ? bar3_data_out : 0);

assign acc_bar0_data_out = start ? bar0_data_out : 0 ;
assign acc_bar1_data_out = start ? bar1_data_out : 0 ;
assign acc_bar2_data_out = start ? bar2_data_out : 0 ;
assign acc_bar3_data_out = start ? bar3_data_out : 0 ;

// [-------------------------- mem --------------------------]
mem_x #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar0 (
    .clk(clk),
    .write_en(bar0_write_en),
    .data_in(bar0_data_in),
    .addr(bar0_addr),
    .data_out(bar0_data_out)
);

mem_wq #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar1 (
    .clk(clk),
    .write_en(bar1_write_en),
    .data_in(bar1_data_in),
    .addr(bar1_addr),
    .data_out(bar1_data_out)
);

mem_wk #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar2 (
    .clk(clk),
    .write_en(bar2_write_en),
    .data_in(bar2_data_in),
    .addr(bar2_addr),
    .data_out(bar2_data_out)
);

mem_wv #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar3 (
    .clk(clk),
    .write_en(bar3_write_en),
    .data_in(bar3_data_in),
    .addr(bar3_addr),
    .data_out(bar3_data_out)
);


endmodule