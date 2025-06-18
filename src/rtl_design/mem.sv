//===================================================================== 
// Description: 
// mem pre-simulation model
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2025/3/28
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

always@(posedge clk) begin
    if(~write_en)
        data_out <= mem_data[addr];
end

always@(posedge clk) begin
    if(write_en)
        mem_data[addr] <= data_in;
end

endmodule