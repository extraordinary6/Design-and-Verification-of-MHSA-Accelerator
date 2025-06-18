//===================================================================== 
// Description: 
// softmax layer : scale and softmax
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2025/4/28
// V1 date:Remove softmax_core @ 2025/5/2
// V2 date:Parameterize @ 2025/5/8
// ==================================================================== 

module softmax#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096,
    parameter WEIGHT_BASE = 'd0,
    parameter WEIGHT_SIZE = 'd2048,                                           // 128 * 128 * 8bit / 64(mem width) = 2048
    parameter INPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE,
    parameter INPUT_SIZE = 'd512,                                             // 32 * 128 * 8 bit / 64(mem width) = 512
    parameter LINEAR_OUTPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE,
    parameter LINEAR_OUTPUT_SIZE = 'd512,                                     // 32 * 128 * 8 bit / 64(mem width) = 512
    parameter QKMM_OUTPUT_BASE = INPUT_BASE + INPUT_SIZE,
    parameter SOFTMAX_OUTPUT_BASE = LINEAR_OUTPUT_BASE + LINEAR_OUTPUT_SIZE
)(
    input logic clk,
    input logic rst_n,

    input logic start,
    output logic done,

//  input
    output   write_en_bar0,                       //1 for write, 0 for read
    output   [WIDTH - 1 : 0] data_in_bar0,
    output logic [31 : 0] addr_bar0,
    input logic [WIDTH - 1 : 0] data_out_bar0,      

//  output
    output   write_en_bar1,                       //1 for write, 0 for read
    output   [WIDTH - 1 : 0] data_in_bar1,
    output logic [31 : 0] addr_bar1,
    input logic [WIDTH - 1 : 0] data_out_bar1

);

logic output_valid;
logic [WIDTH - 1 : 0] output_bar;
logic input_valid;

logic [WIDTH - 1 : 0] scale_bar;
logic scale_valid;

logic [9:0] read_addr;     // 4(head num) * 32 * 32 * 8 bit / 64(mem width) = 512
logic [8:0] write_addr;

assign write_en_bar0 = 1'b0;
assign data_in_bar0 = 64'b0;
assign addr_bar0 = QKMM_OUTPUT_BASE + read_addr;

assign write_en_bar1 = output_valid;
assign data_in_bar1 = output_bar; // softmax output
assign addr_bar1 = SOFTMAX_OUTPUT_BASE + write_addr;

//  [-------------------------- loop counter --------------------------]

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_addr <= 0;
        input_valid <= 0;
    end else if (start) begin
        if (read_addr == 'd512) begin
            read_addr <= read_addr;                           // Memory protection         
            input_valid <= 0;
        end else begin
            read_addr <= read_addr + 1;
            input_valid <= 1;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_addr <= 0;
    end else if (start) begin
        if(output_valid) begin
            if (write_addr == 'd511) begin
                write_addr <= write_addr;                    // Memory protection 
            end else begin
                write_addr <= write_addr + 1;
            end
        end else begin
            write_addr <= write_addr;
        end
    end
end

// [-------------------------- scale --------------------------]
scale_core scale_core_inst (
    .clk(clk),
    .rst_n(rst_n),
    .input_bar(data_out_bar0),
    .bar_valid(input_valid),
    .output_bar(output_bar),
    .output_valid(output_valid)
);

// [-------------------------- softmax --------------------------]
// softmax_core softmax_core_inst (
//     .clk(clk),
//     .rst_n(rst_n),
//     .input_bar(scale_bar),
//     .bar_valid(scale_valid),
//     .output_bar(output_bar),
//     .output_valid(output_valid)
// );

// [-------------------------- done signal --------------------------]

assign done =  (write_addr == 'd511);

// [-------------------------- print for test --------------------------]

// always_ff @(posedge clk) begin
//     if(write_en_bar1) begin
//         $display("write addr: %0d, data: %h", addr_bar1 , data_in_bar1);
//     end
// end

endmodule