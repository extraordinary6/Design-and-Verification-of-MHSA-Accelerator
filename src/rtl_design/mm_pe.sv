//===================================================================== 
// Description: 
// mm systolic PE unit
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2025/3/28
// V1 data:Add flush/valid signal @ 2025/4/2
// ==================================================================== 

module pe(
    input logic clk,
    input logic rst_n,
    input logic flush,

    input logic signed [7:0] row_i,
    input logic signed [7:0] col_i,
    input logic din_valid,

    output logic [7:0] row_o,
    output logic [7:0] col_o,
    output logic dout_valid,

    output logic signed [31:0] res
);

always_ff @(posedge clk) begin
    row_o <= row_i;
    col_o <= col_i;
    dout_valid <= din_valid;
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        res <= 0;
    end else begin
        if (flush) begin
            res <= 0;                               // reset res
        end else begin
            if (din_valid) begin
                res <= row_i * col_i + res;
            end else begin
                res <= res;                         // keep res     
            end
        end
    end
end

endmodule