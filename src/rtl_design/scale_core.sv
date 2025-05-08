module scale_core (
    input               clk,
    input               rst_n,
    input        [63:0] input_bar,
    input               bar_valid,
    output logic [63:0] output_bar,
    output logic        output_valid
);

    logic [7:0] scale_dot = 8'b00101101; // 1/sqrt(32)*255=45

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_valid <= 0;
        end else if (bar_valid) begin
            output_valid <= 1;
        end else begin
            output_valid <= 0;
        end
    end

    // Multiply the scaled data(1/sqrt(32)) by 4 (45/255*4=0.703125)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_bar <= 0;
        end else if (bar_valid) begin
            for (int i = 0; i < 8; i++) begin
                output_bar[i*8 +: 8] = (input_bar[i*8 +: 8] >> 1) + (input_bar[i*8 +: 8] >> 3) + 
                                    (input_bar[i*8 +: 8] >> 4) + (input_bar[i*8 +: 8] >> 6);
            end
        end else begin
            output_bar <= 0;
        end
    end

endmodule