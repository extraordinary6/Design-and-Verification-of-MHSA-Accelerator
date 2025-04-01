//===================================================================== 
// Description: 
// mm systolic PE unit
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/3/28
// ==================================================================== 

module pe(
    input logic clk,
    input logic rst_n,
    
    //input logic flush,

    input logic [7:0] row_i,
    input logic [7:0] col_i,
    output logic [7:0] row_o,
    output logic [7:0] col_o,

    output [31:0] res
);

always_ff @(posedge clk) begin
    if (!rst_n) begin
        row_o <= 0;
        col_o <= 0;
    end else begin
        if (flush) begin
            row_o <= 0;
            col_o <= 0;
        end else begin
            row_o <= row_i;
            col_o <= col_i;
        end
    end
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        res <= 0;
    end else begin
        if (flush) begin
            res <= 0;
        end else begin
            res <= row_i * col_i + res;
        end
    end
end

endmodule