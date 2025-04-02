//===================================================================== 
// Description: 
// mm systolic : 8x8 systolic array for matrix multiplication (8,N)¡Á(N,8)
// every cell stores 8*8 matrix, and the output is 8*8 matrix
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/4/1   :) Happy April Fool's Day :)
// V1 date:Fix the bug and complete testbench @ 2024/4/2
// Reference:
// https://blog.csdn.net/wordwarwordwar/article/details/103537996
// ==================================================================== 


module mm_systolic(
    input logic clk,
    input logic rst_n,

    input logic [63:0] row_bar,
    input logic [63:0] col_bar,
    input logic bar_valid,         
    input logic flush               // pull up one cycle to flush PE result
);

// [ ---------------------- devide bar into 8x8 matrix ---------------------- ]
wire [7:0] row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7;
wire [7:0] col_0, col_1, col_2, col_3, col_4, col_5, col_6, col_7;
assign {row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7} = row_bar;
assign {col_0, col_1, col_2, col_3, col_4, col_5, col_6, col_7} = col_bar;

// [ ---------------------- input pattern ctrl ---------------------- ]

// delay-input pattern
reg [7:0] row_1_d, col_1_d;
reg [7:0] row_2_d, row_2_2d, col_2_d, col_2_2d;
reg [7:0] row_3_d, row_3_2d, row_3_3d, col_3_d, col_3_2d, col_3_3d;
reg [7:0] row_4_d, row_4_2d, row_4_3d, row_4_4d, col_4_d, col_4_2d, col_4_3d, col_4_4d;
reg [7:0] row_5_d, row_5_2d, row_5_3d, row_5_4d, row_5_5d, col_5_d, col_5_2d, col_5_3d, col_5_4d, col_5_5d;
reg [7:0] row_6_d, row_6_2d, row_6_3d, row_6_4d, row_6_5d, row_6_6d, col_6_d, col_6_2d, col_6_3d, col_6_4d, col_6_5d, col_6_6d;
reg [7:0] row_7_d, row_7_2d, row_7_3d, row_7_4d, row_7_5d, row_7_6d, row_7_7d, col_7_d, col_7_2d, col_7_3d, col_7_4d, col_7_5d, col_7_6d, col_7_7d;

always_ff @(posedge clk) begin
    row_1_d <= row_1;
    col_1_d <= col_1;
    row_2_d <= row_2;
    col_2_d <= col_2;
    row_3_d <= row_3;
    col_3_d <= col_3;
    row_4_d <= row_4;
    col_4_d <= col_4;
    row_5_d <= row_5;
    col_5_d <= col_5;
    row_6_d <= row_6;
    col_6_d <= col_6;
    row_7_d <= row_7;
    col_7_d <= col_7;
    row_2_2d <= row_2_d;
    col_2_2d <= col_2_d;
    row_3_2d <= row_3_d;
    col_3_2d <= col_3_d;
    row_4_2d <= row_4_d;
    col_4_2d <= col_4_d;
    row_5_2d <= row_5_d;
    col_5_2d <= col_5_d;
    row_6_2d <= row_6_d;
    col_6_2d <= col_6_d;
    row_7_2d <= row_7_d;
    col_7_2d <= col_7_d;
    row_3_3d <= row_3_2d;
    col_3_3d <= col_3_2d;
    row_4_3d <= row_4_2d;
    col_4_3d <= col_4_2d;
    row_5_3d <= row_5_2d;
    col_5_3d <= col_5_2d;
    row_6_3d <= row_6_2d;
    col_6_3d <= col_6_2d;
    row_7_3d <= row_7_2d;
    col_7_3d <= col_7_2d;
    row_4_4d <= row_4_3d;
    col_4_4d <= col_4_3d;
    row_5_4d <= row_5_3d;
    col_5_4d <= col_5_3d;
    row_6_4d <= row_6_3d;
    col_6_4d <= col_6_3d;
    row_7_4d <= row_7_3d;
    col_7_4d <= col_7_3d;
    row_5_5d <= row_5_4d;
    col_5_5d <= col_5_4d;
    row_6_5d <= row_6_4d;
    col_6_5d <= col_6_4d;
    row_7_5d <= row_7_4d;
    col_7_5d <= col_7_4d;
    row_6_6d <= row_6_5d;
    col_6_6d <= col_6_5d;
    row_7_6d <= row_7_5d;
    col_7_6d <= col_7_5d;
    row_7_7d <= row_7_6d;
    col_7_7d <= col_7_6d;
end

// valid shift register
reg [6:0] bar_valid_delay;
always_ff @(posedge clk) begin
    if (!rst_n) begin
        bar_valid_delay <= 0;
    end else begin
        bar_valid_delay <= {bar_valid_delay[5:0], bar_valid};
    end
end

// [ ---------------------- 8x8 systolic array ---------------------- ]
// Add an extra row/column during definition to prevent array out-of-bounds access
wire [7:0] row_i [0:8][0:8];
wire [7:0] col_i [0:8][0:8];
wire din_valid [0:8][0:8];
reg [31:0] res [0:7][0:7];

// systolic array input
assign col_i[0][0] = col_0;
assign col_i[0][1] = col_1_d;
assign col_i[0][2] = col_2_2d;
assign col_i[0][3] = col_3_3d;
assign col_i[0][4] = col_4_4d;
assign col_i[0][5] = col_5_5d;
assign col_i[0][6] = col_6_6d;
assign col_i[0][7] = col_7_7d; 

assign row_i[0][0] = row_0;
assign row_i[1][0] = row_1_d;
assign row_i[2][0] = row_2_2d;
assign row_i[3][0] = row_3_3d;
assign row_i[4][0] = row_4_4d;
assign row_i[5][0] = row_5_5d;
assign row_i[6][0] = row_6_6d;
assign row_i[7][0] = row_7_7d;

assign din_valid[0][0] = bar_valid;
assign din_valid[1][0] = bar_valid_delay[0];
assign din_valid[2][0] = bar_valid_delay[1];
assign din_valid[3][0] = bar_valid_delay[2];
assign din_valid[4][0] = bar_valid_delay[3];
assign din_valid[5][0] = bar_valid_delay[4];
assign din_valid[6][0] = bar_valid_delay[5];
assign din_valid[7][0] = bar_valid_delay[6];

generate 
    genvar i, j;
    for (i = 0; i < 8; i = i + 1) begin
        for (j = 0; j < 8; j = j + 1) begin
            pe pe_inst(
                .clk(clk),
                .rst_n(rst_n),
                .flush(flush),
                .row_i(row_i[i][j]),
                .col_i(col_i[i][j]),
                .din_valid(din_valid[i][j]),
                .row_o(row_i[i][j+1]),
                .col_o(col_i[i+1][j]),
                .dout_valid(din_valid[i][j+1]),
                .res(res[i][j])
            );
        end
    end
endgenerate


endmodule