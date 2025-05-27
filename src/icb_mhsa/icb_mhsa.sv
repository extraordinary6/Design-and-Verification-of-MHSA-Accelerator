//===================================================================== 
// Description: 
// icb peripheral to mhsa accelerator
// |-- icb2usram
// |-- CSR
// |-- mhsa accelerator top
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/5/27
// ====================================================================

module icb_mhsa#(
)(
    input                           clk,
    input                           rst_n,

    // icb slave
    input                           icb_cmd_valid,
    output                          icb_cmd_ready,
    input                           icb_cmd_read,
    input       [31:0]              icb_cmd_addr,
    input       [31:0]              icb_cmd_wdata,
    input       [3:0]               icb_cmd_wmask,

    output                          icb_rsp_valid,
    input                           icb_rsp_ready,
    output      [31:0]              icb_rsp_rdata,
    output                          icb_rsp_err
);

wire [31:0] input_base;
wire [31:0] output_base;
wire start;
wire done;

wire [31:0] usram_addr;
wire [63:0] usram_wdata;
wire usram_write_en;

imu imu_inst (
    .icb_cmd_valid(icb_cmd_valid),
    .icb_cmd_ready(icb_cmd_ready),
    .icb_cmd_read(icb_cmd_read),
    .icb_cmd_addr(icb_cmd_addr),
    .icb_cmd_wdata(icb_cmd_wdata),
    .icb_cmd_wmask(icb_cmd_wmask),

    .icb_rsp_valid(icb_rsp_valid),
    .icb_rsp_ready(icb_rsp_ready),
    .icb_rsp_rdata(icb_rsp_rdata),
    .icb_rsp_err(icb_rsp_err),

    .clk(clk),
    .rst_n(rst_n)

    // CSR output
    .start({31'b0,start}),
    .done({31'b0,done}),
    .input_base(input_base),
    .output_base(output_base)

    // usram
    .usram_addr(usram_addr),
    .usram_wdata(usram_wdata),
    .usram_write_en(usram_write_en)
);

mhsa_acc_wrapper #(
    .WIDTH(64),
    .LENGTH(4096)
) mhsa_acc_wrapper_inst (
    .clk(clk),
    .rst_n(rst_n),

    // control signals
    .done(done),
    .start(start),
    .input_base(input_base),
    .output_base(output_base),

    // unified sram interface
    .soc_write_en(usram_write_en),
    .soc_data_in(usram_wdata),
    .soc_addr(usram_addr),
    .soc_data_out()
);


endmodule