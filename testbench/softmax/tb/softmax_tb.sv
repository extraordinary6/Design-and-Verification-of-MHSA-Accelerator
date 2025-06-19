module softmax_tb;

    bit clk;
    bit rst_n;

    logic [63:0] input_bar;
    logic bar_valid;

    logic [63:0] output_bar;
    logic output_valid;

    logic [63:0] ref_data;

    int scan_ref;
    int res_file;
    int ref_file;

    int output_count;

    softmax uut (
        .clk(clk),
        .rst_n(rst_n),
        .input_bar(input_bar),
        .bar_valid(bar_valid),
        .output_bar(output_bar),
        .output_valid(output_valid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        res_file = $fopen("D:/toolbox/questasim/file/SoC/project/rtl/softmax/output_v.txt", "w");
        ref_file = $fopen("D:/toolbox/questasim/file/SoC/project/rtl/softmax/qkmm_output.txt", "r");

        if (res_file == 0 || ref_file == 0) begin
            $display("Failed to open file");
            $stop;
        end

        #20;
        rst_n = 1;

        output_count = 0;
        for (int i = 0; i < 133; i++) begin
            $fscanf(ref_file, "%h", ref_data);

            @(posedge clk);
            input_bar = ref_data;

            if (i >= 128) begin
                bar_valid = 0;
            end else begin
                bar_valid = 1;
            end

            if (output_valid) begin
                $fwrite(res_file, "%h ", output_bar);
                output_count++;

                if (output_count == 4) begin
                    $fwrite(res_file, "\n");
                    output_count = 0;
                end
            end
        end

        #50

        $fclose(res_file);
        $fclose(ref_file);

        $stop;
    end

    // 监控输出结果
    initial begin
        $monitor("Time = %0t | input_bar = %h, bar_valid = %b, output_bar = %h", $time, input_bar, bar_valid, output_bar);
    end

endmodule