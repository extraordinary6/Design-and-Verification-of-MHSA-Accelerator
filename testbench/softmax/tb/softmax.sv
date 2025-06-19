module softmax (
    input         clk,
    input         rst_n,
 
    input  [63:0] input_bar,
    input         bar_valid,
    output [63:0] output_bar,
    output        output_valid
);
    parameter integer H = 5;

    logic [63:0]  lut_1D_in;
    logic [63:0]  lut_1D_out;
    logic [63:0]  lut_2D_out;
    logic [63:0]  input_reg [0:3];
    logic [1:0]   cnt;
    logic [2:0]   cnt_done;
    logic [H-1:0] cnt_sum;
    logic [H-1:0] cnt_sum_add;
    logic [H-1:0] cnt_sum_sub;
    logic [12:0]  sum [0:(1<<H)-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
        end else if (bar_valid | output_valid) begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_sum <= 0;
        end else if (!bar_valid && output_valid) begin
            cnt_sum <= 0;
        end else if (cnt == 2'b11) begin
            cnt_sum <= cnt_sum + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_reg[0] = 0;
            input_reg[1] = 0;
            input_reg[2] = 0;
            input_reg[3] = 0;
        end else if (bar_valid) begin
            input_reg[cnt] = lut_1D_out;
        end
    end

    always @(*) begin
        if (!rst_n) begin
            lut_1D_in = 0;
        end else if (bar_valid) begin
            lut_1D_in = input_bar;
        end
    end

    lut_1D lut_1D (
        .data_in(lut_1D_in),
        .data_out(lut_1D_out)
    );

    assign cnt_sum_add = cnt_sum + 1;
    assign cnt_sum_sub = cnt_sum - 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < (1 << H); i++) begin
                sum[i] <= 0;
            end
        end else if (bar_valid) begin
            sum[cnt_sum_add] <= 0;
            sum[cnt_sum] <= sum[cnt_sum] + lut_1D_out[7:0] + lut_1D_out[15:8] + 
                            lut_1D_out[23:16] + lut_1D_out[31:24] + lut_1D_out[39:32] + 
                            lut_1D_out[47:40] + lut_1D_out[55:48] + lut_1D_out[63:56];
        end
    end

    lut_2D lut_2D (
        .data_in(input_reg[cnt]),
        .sum(sum[cnt_sum_sub]),
        .data_out(lut_2D_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_done <= 0;
        end else if (cnt == 3'b11 & (cnt_sum == (1<<H) - 1)) begin
            cnt_done <= cnt_done + 1;
        end else if (cnt_done == 3'b100) begin
            cnt_done <= 0;
        end else if (cnt_done != 0) begin
            cnt_done <= cnt_done + 1;
        end
    end

    assign output_valid = (cnt_done != 0) | (cnt_sum != 0);
    assign output_bar = output_valid ? lut_2D_out : 0;

endmodule