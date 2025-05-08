//===================================================================== 
// Description: 
// mem with Weight Data pre-simulation model
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/4/18
// ==================================================================== 

module mem_wk #(
    parameter WIDTH = 64,
    parameter LENGTH = 4096,
    parameter WEIGHT_BASE = 'd0,
    parameter WEIGHT_SIZE = 'd2048                                           // 128 * 128 * 8bit / 64(mem width) = 2048
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
    integer i, j, k;
    integer fd,scan_row;
    reg [7:0] data[0:127];

    // Open the text file
    fd = $fopen("Wk.txt", "r");

    // Read data from file and initialize memory
    for (i = 0; i < 128; i = i + 1) begin
        for (j = 0; j < 128; j = j + 1) begin
            scan_row = $fscanf(fd, "%d", data[j]);
        end

        // Pack 8 bytes into one 64-bit memory word
        for (j = 0; j < 16; j = j + 1) begin
            mem_data[WEIGHT_BASE + i * 16 + j] = { data[j * 8], data[j * 8 + 1], data[j * 8 + 2], data[j * 8 + 3], data[j * 8 + 4], data[j * 8 + 5], data[j * 8 + 6], data[j * 8 + 7] };
        end
    end

    // Close the file
    $fclose(fd);
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