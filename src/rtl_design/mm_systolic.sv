//===================================================================== 
// Description: 
// mm systolic : 8x8 systolic array for 8*128 matrix multiplication
// every cell stores 8*8 matrix, and the output is 8*8 matrix
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/4/1  
// :) Happy April Fool's Day :)
// Reference:
// https://blog.csdn.net/wordwarwordwar/article/details/103537996
// ==================================================================== 


module mm_systolic#(
    input logic clk,
    input logic rst_n,

    input logic [63:0] row_bar,
    input logic [63:0] col_bar

);

// [ ---------------------- input pattern ctrl ---------------------- ]

wire [7:0] row_0, row1, row_2, row_3, row_4, row_5, row_6, row_7;
wire [7:0] col_0, col_1, col_2, col_3, col_4, col_5, col_6, col_7;

assign row_0 = row_bar[7:0];
assign col_0 = col_bar[7:0];
assign row_1 = row_bar[15:8];
assign col_1 = col_bar[15:8];
assign row_2 = row_bar[23:16];
assign col_2 = col_bar[23:16];
assign row_3 = row_bar[31:24];
assign col_3 = col_bar[31:24];
assign row_4 = row_bar[39:32];
assign col_4 = col_bar[39:32];
assign row_5 = row_bar[47:40];
assign col_5 = col_bar[47:40];
assign row_6 = row_bar[55:48];
assign col_6 = col_bar[55:48];
assign row_7 = row_bar[63:56];
assign col_7 = col_bar[63:56];

// delay input pattern
reg [7:0] row_1_d, row_2_d, row_3_d, row_4_d, row_5_d, row_6_d, row_7_d;
reg [7:0] col_1_d, col_2_d, col_3_d, col_4_d, col_5_d, col_6_d, col_7_d;
reg [7:0] row_2_2d, row_3_2d, row_4_2d, row_5_2d, row_6_2d, row_7_2d;
reg [7:0] col_2_2d, col_3_2d, col_4_2d, col_5_2d, col_6_2d, col_7_2d;
reg [7:0] row_3_3d, row_4_3d, row_5_3d, row_6_3d, row_7_3d;
reg [7:0] col_3_3d, col_4_3d, col_5_3d, col_6_3d, col_7_3d;
reg [7:0] row_4_4d, row_5_4d, row_6_4d, row_7_4d;
reg [7:0] col_4_4d, col_5_4d, col_6_4d, col_7_4d;
reg [7:0] row_5_5d, row_6_5d, row_7_5d;
reg [7:0] col_5_5d, col_6_5d, col_7_5d;
reg [7:0] row_6_6d, row_7_6d;
reg [7:0] col_6_6d, col_7_6d;
reg [7:0] row_7_7d;
reg [7:0] col_7_7d;

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

wire [7:0] row_i_00, row_i_01, row_i_02, row_i_03, row_i_04, row_i_05, row_i_06, row_i_07,
            row_i_10, row_i_11, row_i_12, row_i_13, row_i_14, row_i_15, row_i_16, row_i_17,
            row_i_20, row_i_21, row_i_22, row_i_23, row_i_24, row_i_25, row_i_26, row_i_27,
            row_i_30, row_i_31, row_i_32, row_i_33, row_i_34, row_i_35, row_i_36, row_i_37,
            row_i_40, row_i_41, row_i_42, row_i_43, row_i_44, row_i_45, row_i_46, row_i_47,
            row_i_50, row_i_51, row_i_52, row_i_53, row_i_54, row_i_55, row_i_56, row_i_57,
            row_i_60, row_i_61, row_i_62, row_i_63, row_i_64, row_i_65, row_i_66, row_i_67,
            row_i_70, row_i_71, row_i_72, row_i_73, row_i_74, row_i_75, row_i_76, row_i_77;

wire [7:0] col_i_00, col_i_01, col_i_02, col_i_03, col_i_04, col_i_05, col_i_06, col_i_07,
            col_i_10, col_i_11, col_i_12, col_i_13, col_i_14, col_i_15, col_i_16, col_i_17,
            col_i_20, col_i_21, col_i_22, col_i_23, col_i_24, col_i_25, col_i_26, col_i_27,
            col_i_30, col_i_31, col_i_32, col_i_33, col_i_34, col_i_35, col_i_36, col_i_37,
            col_i_40, col_i_41, col_i_42, col_i_43, col_i_44, col_i_45, col_i_46, col_i_47,
            col_i_50, col_i_51, col_i_52, col_i_53, col_i_54, col_i_55, col_i_56, col_i_57,
            col_i_60, col_i_61, col_i_62, col_i_63, col_i_64, col_i_65, col_i_66, col_i_67,
            col_i_70, col_i_71, col_i_72, col_i_73, col_i_74, col_i_75, col_i_76, col_i_77;

assign col_i_00 = col_0;
assign col_i_01 = col_1_d;
assign col_i_02 = col_2_d;
assign col_i_03 = col_3_d;
assign col_i_04 = col_4_d;
assign col_i_05 = col_5_d;
assign col_i_06 = col_6_d;
assign col_i_07 = col_7_d;
assign row_i_00 = row_0;
assign row_i_10 = row_1_d;
assign row_i_20 = row_2_d;
assign row_i_30 = row_3_d;
assign row_i_40 = row_4_d;
assign row_i_50 = row_5_d;
assign row_i_60 = row_6_d;
assign row_i_70 = row_7_d;

// [ ---------------------- 8x8 systolic array ---------------------- ]

// TODO : 将 row_i 与 col_i 数组化，使用 generate 语句重构
pe pe00(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_00),
    .col_i(col_i_00),
    .row_o(row_i_01),
    .col_o(col_i_10),
    .res(res_00)
);

pe pe01(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_01),
    .col_i(col_i_01),
    .row_o(row_i_02),
    .col_o(col_i_11),
    .res(res_01)
);

pe pe02(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_02),
    .col_i(col_i_02),
    .row_o(row_i_03),
    .col_o(col_i_12),
    .res(res_02)
);

pe pe03(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_03),
    .col_i(col_i_03),
    .row_o(row_i_04),
    .col_o(col_i_13),
    .res(res_03)
);

pe pe04(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_04),
    .col_i(col_i_04),
    .row_o(row_i_05),
    .col_o(col_i_14),
    .res(res_04)
);

pe pe05(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_05),
    .col_i(col_i_05),
    .row_o(row_i_06),
    .col_o(col_i_15),
    .res(res_05)
);

pe pe06(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_06),
    .col_i(col_i_06),
    .row_o(row_i_07),
    .col_o(col_i_16),
    .res(res_06)
);

pe pe07(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_07),
    .col_i(col_i_07),
    .row_o(),
    .col_o(col_i_17),
    .res(res_07)
);

pe pe10(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_10),
    .col_i(col_i_10),
    .row_o(row_i_11),
    .col_o(col_i_20),
    .res(res_10)
);

pe pe11(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_11),
    .col_i(col_i_11),
    .row_o(row_i_12),
    .col_o(col_i_21),
    .res(res_11)
);

pe pe12(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_12),
    .col_i(col_i_12),
    .row_o(row_i_13),
    .col_o(col_i_22),
    .res(res_12)
);

pe pe13(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_13),
    .col_i(col_i_13),
    .row_o(row_i_14),
    .col_o(col_i_23),
    .res(res_13)
);

pe pe14(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_14),
    .col_i(col_i_14),
    .row_o(row_i_15),
    .col_o(col_i_24),
    .res(res_14)
);

pe pe15(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_15),
    .col_i(col_i_15),
    .row_o(row_i_16),
    .col_o(col_i_25),
    .res(res_15)
);

pe pe16(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_16),
    .col_i(col_i_16),
    .row_o(row_i_17),
    .col_o(col_i_26),
    .res(res_16)
);

pe pe17(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_17),
    .col_i(col_i_17),
    .row_o(),
    .col_o(col_i_27),
    .res(res_17)
);

pe pe20(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_20),
    .col_i(col_i_20),
    .row_o(row_i_21),
    .col_o(col_i_30),
    .res(res_20)
);

pe pe21(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_21),
    .col_i(col_i_21),
    .row_o(row_i_22),
    .col_o(col_i_31),
    .res(res_21)
);

pe pe22(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_22),
    .col_i(col_i_22),
    .row_o(row_i_23),
    .col_o(col_i_32),
    .res(res_22)
);

pe pe23(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_23),
    .col_i(col_i_23),
    .row_o(row_i_24),
    .col_o(col_i_33),
    .res(res_23)
);

pe pe24(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_24),
    .col_i(col_i_24),
    .row_o(row_i_25),
    .col_o(col_i_34),
    .res(res_24)
);

pe pe25(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_25),
    .col_i(col_i_25),
    .row_o(row_i_26),
    .col_o(col_i_35),
    .res(res_25)
);

pe pe26(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_26),
    .col_i(col_i_26),
    .row_o(row_i_27),
    .col_o(col_i_36),
    .res(res_26)
);

pe pe27(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_27),
    .col_i(col_i_27),
    .row_o(),
    .col_o(col_i_37),
    .res(res_27)
);

pe pe30(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_30),
    .col_i(col_i_30),
    .row_o(row_i_31),
    .col_o(col_i_40),
    .res(res_30)
);

pe pe31(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_31),
    .col_i(col_i_31),
    .row_o(row_i_32),
    .col_o(col_i_41),
    .res(res_31)
);

pe pe32(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_32),
    .col_i(col_i_32),
    .row_o(row_i_33),
    .col_o(col_i_42),
    .res(res_32)
);

pe pe33(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_33),
    .col_i(col_i_33),
    .row_o(row_i_34),
    .col_o(col_i_43),
    .res(res_33)
);

pe pe34(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_34),
    .col_i(col_i_34),
    .row_o(row_i_35),
    .col_o(col_i_44),
    .res(res_34)
);

pe pe35(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_35),
    .col_i(col_i_35),
    .row_o(row_i_36),
    .col_o(col_i_45),
    .res(res_35)
);

pe pe36(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_36),
    .col_i(col_i_36),
    .row_o(row_i_37),
    .col_o(col_i_46),
    .res(res_36)
);

pe pe37(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_37),
    .col_i(col_i_37),
    .row_o(),
    .col_o(col_i_47),
    .res(res_37)
);

pe pe40(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_40),
    .col_i(col_i_40),
    .row_o(row_i_41),
    .col_o(col_i_50),
    .res(res_40)
);

pe pe41(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_41),
    .col_i(col_i_41),
    .row_o(row_i_42),
    .col_o(col_i_51),
    .res(res_41)
);

pe pe42(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_42),
    .col_i(col_i_42),
    .row_o(row_i_43),
    .col_o(col_i_52),
    .res(res_42)
);

pe pe43(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_43),
    .col_i(col_i_43),
    .row_o(row_i_44),
    .col_o(col_i_53),
    .res(res_43)
);

pe pe44(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_44),
    .col_i(col_i_44),
    .row_o(row_i_45),
    .col_o(col_i_54),
    .res(res_44)
);

pe pe45(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_45),
    .col_i(col_i_45),
    .row_o(row_i_46),
    .col_o(col_i_55),
    .res(res_45)
);

pe pe46(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_46),
    .col_i(col_i_46),
    .row_o(row_i_47),
    .col_o(col_i_56),
    .res(res_46)
);

pe pe47(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_47),
    .col_i(col_i_47),
    .row_o(),
    .col_o(col_i_57),
    .res(res_47)
);

pe pe50(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_50),
    .col_i(col_i_50),
    .row_o(row_i_51),
    .col_o(col_i_60),
    .res(res_50)
);

pe pe51(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_51),
    .col_i(col_i_51),
    .row_o(row_i_52),
    .col_o(col_i_61),
    .res(res_51)
);

pe pe52(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_52),
    .col_i(col_i_52),
    .row_o(row_i_53),
    .col_o(col_i_62),
    .res(res_52)
);

pe pe53(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_53),
    .col_i(col_i_53),
    .row_o(row_i_54),
    .col_o(col_i_63),
    .res(res_53)
);

pe pe54(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_54),
    .col_i(col_i_54),
    .row_o(row_i_55),
    .col_o(col_i_64),
    .res(res_54)
);

pe pe55(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_55),
    .col_i(col_i_55),
    .row_o(row_i_56),
    .col_o(col_i_65),
    .res(res_55)
);

pe pe56(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_56),
    .col_i(col_i_56),
    .row_o(row_i_57),
    .col_o(col_i_66),
    .res(res_56)
);

pe pe57(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_57),
    .col_i(col_i_57),
    .row_o(),
    .col_o(col_i_67),
    .res(res_57)
);

pe pe60(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_60),
    .col_i(col_i_60),
    .row_o(row_i_61),
    .col_o(col_i_70),
    .res(res_60)
);

pe pe61(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_61),
    .col_i(col_i_61),
    .row_o(row_i_62),
    .col_o(col_i_71),
    .res(res_61)
);

pe pe62(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_62),
    .col_i(col_i_62),
    .row_o(row_i_63),
    .col_o(col_i_72),
    .res(res_62)
);

pe pe63(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_63),
    .col_i(col_i_63),
    .row_o(row_i_64),
    .col_o(col_i_73),
    .res(res_63)
);

pe pe64(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_64),
    .col_i(col_i_64),
    .row_o(row_i_65),
    .col_o(col_i_74),
    .res(res_64)
);

pe pe65(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_65),
    .col_i(col_i_65),
    .row_o(row_i_66),
    .col_o(col_i_75),
    .res(res_65)
);

pe pe66(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_66),
    .col_i(col_i_66),
    .row_o(row_i_67),
    .col_o(col_i_76),
    .res(res_66)
);

pe pe67(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_67),
    .col_i(col_i_67),
    .row_o(),
    .col_o(col_i_77),
    .res(res_67)
);

pe pe70(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_70),
    .col_i(col_i_70),
    .row_o(row_i_71),
    .col_o(),
    .res(res_70)
);

pe pe71(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_71),
    .col_i(col_i_71),
    .row_o(row_i_72),
    .col_o(),
    .res(res_71)
);

pe pe72(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_72),
    .col_i(col_i_72),
    .row_o(row_i_73),
    .col_o(),
    .res(res_72)
);

pe pe73(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_73),
    .col_i(col_i_73),
    .row_o(row_i_74),
    .col_o(),
    .res(res_73)
);

pe pe74(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_74),
    .col_i(col_i_74),
    .row_o(row_i_75),
    .col_o(),
    .res(res_74)
);

pe pe75(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_75),
    .col_i(col_i_75),
    .row_o(row_i_76),
    .col_o(),
    .res(res_75)
);

pe pe76(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_76),
    .col_i(col_i_76),
    .row_o(row_i_77),
    .col_o(),
    .res(res_76)
);

pe pe77(
    .clk(clk),
    .rst_n(rst_n),
    .row_i(row_i_77),
    .col_i(col_i_77),
    .row_o(),
    .col_o(),
    .res(res_77)
);

// [ ---------------------- output pattern ctrl ---------------------- ]

// TODO : just for test, need to be modified
reg [31:0] res [0:7][0:7];

assign res[0][0] = res_00;
assign res[0][1] = res_01;
assign res[0][2] = res_02;
assign res[0][3] = res_03;
assign res[0][4] = res_04;
assign res[0][5] = res_05;
assign res[0][6] = res_06;
assign res[0][7] = res_07;
assign res[1][0] = res_10;
assign res[1][1] = res_11;
assign res[1][2] = res_12;
assign res[1][3] = res_13;
assign res[1][4] = res_14;
assign res[1][5] = res_15;
assign res[1][6] = res_16;
assign res[1][7] = res_17;
assign res[2][0] = res_20;
assign res[2][1] = res_21;
assign res[2][2] = res_22;
assign res[2][3] = res_23;
assign res[2][4] = res_24;
assign res[2][5] = res_25;
assign res[2][6] = res_26;
assign res[2][7] = res_27;
assign res[3][0] = res_30;
assign res[3][1] = res_31;
assign res[3][2] = res_32;
assign res[3][3] = res_33;
assign res[3][4] = res_34;
assign res[3][5] = res_35;
assign res[3][6] = res_36;
assign res[3][7] = res_37;
assign res[4][0] = res_40;
assign res[4][1] = res_41;
assign res[4][2] = res_42;
assign res[4][3] = res_43;
assign res[4][4] = res_44;
assign res[4][5] = res_45;
assign res[4][6] = res_46;
assign res[4][7] = res_47;
assign res[5][0] = res_50;
assign res[5][1] = res_51;
assign res[5][2] = res_52;
assign res[5][3] = res_53;
assign res[5][4] = res_54;
assign res[5][5] = res_55;
assign res[5][6] = res_56;
assign res[5][7] = res_57;
assign res[6][0] = res_60;
assign res[6][1] = res_61;
assign res[6][2] = res_62;
assign res[6][3] = res_63;
assign res[6][4] = res_64;
assign res[6][5] = res_65;
assign res[6][6] = res_66;
assign res[6][7] = res_67;
assign res[7][0] = res_70;
assign res[7][1] = res_71;
assign res[7][2] = res_72;
assign res[7][3] = res_73;
assign res[7][4] = res_74;
assign res[7][5] = res_75;
assign res[7][6] = res_76;
assign res[7][7] = res_77;

endmodule