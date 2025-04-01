//===================================================================== 
// Description: 
// mhsa_acc_wrapper
//  |-- arbiter
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
// V0 date:Initial version @ 2024/3/28
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

logic acc_rst_n;
assign acc_rst_n = rst_n & start;

// [-------------------------- mhsa_acc_top --------------------------]
logic acc_write_en;
logic [WIDTH - 1 : 0] acc_data_in;
logic [31 : 0] acc_addr;
logic [WIDTH - 1 : 0] acc_data_out;

mhsa_acc_top #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) mhsa_acc_top_inst (
    .clk(clk),
    .rst_n(acc_rst_n),

    // control signals
    .done(done),
    .input_base(input_base),
    .output_base(output_base),

    // unified sram interface
    .acc_write_en(acc_write_en),
    .acc_data_in(acc_data_in),
    .acc_addr(acc_addr),
    .acc_data_out(acc_data_out)
);

// [-------------------------- arbiter --------------------------]
// soc/acc arbiter
logic mem_write_en;
logic [WIDTH - 1 : 0] mem_data_in;
logic [31 : 0] mem_addr;
logic [WIDTH - 1 : 0] mem_data_out;

assign mem_data_in = start ? acc_data_in : soc_data_in; // when start , soc release the sram bus
assign mem_addr = start ? acc_addr : soc_addr;
assign mem_write_en = start ? acc_write_en : soc_write_en;
assign soc_data_out = start ? 0 : mem_data_out;
assign acc_data_out = start ? mem_data_out : 0;

// address map arbiter
logic sel_bar0, sel_bar1, sel_bar2, sel_bar3;
logic sel_bar0_1d, sel_bar1_1d, sel_bar2_1d, sel_bar3_1d;                   // 1d : read valid

//TODO: no true address map, just for test
assign sel_bar0 = (mem_addr >= 32'h0000_0000 && mem_addr < 32'h0000_1000);
assign sel_bar1 = (mem_addr >= 32'h0000_1000 && mem_addr < 32'h0000_2000);
assign sel_bar2 = (mem_addr >= 32'h0000_2000 && mem_addr < 32'h0000_3000);
assign sel_bar3 = (mem_addr >= 32'h0000_3000 && mem_addr < 32'h0000_4000);

assign write_en_bar0 = mem_write_en && sel_bar0;
assign write_en_bar1 = mem_write_en && sel_bar1;
assign write_en_bar2 = mem_write_en && sel_bar2;
assign write_en_bar3 = mem_write_en && sel_bar3;

always_ff @( clk ) begin
    sel_bar0_1d <= sel_bar0;
    sel_bar1_1d <= sel_bar1;
    sel_bar2_1d <= sel_bar2;
    sel_bar3_1d <= sel_bar3;
end

assign mem_data_out =   (sel_bar0_1d) ? data_out_bar0 :
                        (sel_bar1_1d) ? data_out_bar1 :
                        (sel_bar2_1d) ? data_out_bar2 :
                        (sel_bar3_1d) ? data_out_bar3 : 0;
    
// [-------------------------- mem --------------------------]
mem #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar0 (
    .clk(clk),
    .write_en(write_en_bar0),
    .mem_data_in(mem_data_in),
    .mem_addr(mem_addr),
    .data_out(data_out_bar0)
);

mem #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar1 (
    .clk(clk),
    .write_en(write_en_bar1),
    .mem_data_in(mem_data_in),
    .mem_addr(mem_addr),
    .data_out(data_out_bar1)
);

mem #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar2 (
    .clk(clk),
    .write_en(write_en_bar2),
    .mem_data_in(mem_data_in),
    .mem_addr(mem_addr),
    .data_out(data_out_bar2)
);

mem #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) bar3 (
    .clk(clk),
    .write_en(write_en_bar3),
    .mem_data_in(mem_data_in),
    .mem_addr(mem_addr),
    .data_out(data_out_bar3)
);



endmodule