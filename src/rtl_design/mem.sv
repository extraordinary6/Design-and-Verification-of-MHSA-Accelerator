//===================================================================== 
// Description: 
// mem pre-simulation model
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/3/28
// ==================================================================== 

module mem #(
    parameter WIDTH = 64,
    parameter LENGTH = 4096
)
(
    input   clk,
    input   write_en,                       //1 for write, 0 for read
    input   [WIDTH - 1 : 0] data_in,
    input   [31 : 0] addr,
    output logic [WIDTH - 1 : 0] data_out
);

logic [WIDTH - 1 : 0] mem_data [0:LENGTH-1];

initial
begin
    mem_data[0] = {8'd1,8'd4,8'd7,8'd10};
    mem_data[1] = {8'd2,8'd5,8'd8,8'd11};
    mem_data[2] = {8'd3,8'd6,8'd9,8'd12};
    mem_data[3] = {8'd1,8'd4,8'd7,8'd10};
    mem_data[4] = {8'd2,8'd5,8'd8,8'd11};
    mem_data[5] = {8'd3,8'd6,8'd9,8'd12};
end

always@(posedge clk) begin
    if(~write_en)
        data_out <= mem_data[addr];
end

always@(posedge clk) begin
    if(write_en)
        mem_data[addr] <= data_in;
end

endmodule