module scale_tb;

    // 时钟和复位信号
    bit clk;
    bit rst_n;

    // 输入信号
    logic [63:0] input_bar;
    logic bar_valid;

    // 输出信号
    logic [63:0] output_bar;
    logic output_valid;

    // 实例化被测模块
    scale uut (
        .clk(clk),
        .rst_n(rst_n),
        .input_bar(input_bar),
        .bar_valid(bar_valid),
        .output_bar(output_bar),
        .output_valid(output_valid)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 复位信号控制
    initial begin
        rst_n = 0;
        #10 rst_n = 1; // 在时间 10 处释放复位信号
    end

    // 测试激励
    initial begin
        // 初始化输入信号
        input_bar = 64'b0;
        bar_valid = 0;

        // 等待复位完成
        @(negedge !rst_n);

        // 发送第一组测试数据
        input_bar = 64'h00fc00fd00fe00ff; // 示例输入数据
        bar_valid = 1;
        #1300
        bar_valid = 0;

        // 等待一段时间观察输出
        #100;

        // 结束仿真
        $stop;
    end

    // 监控输出结果
    initial begin
        $monitor("Time = %0t | input_bar = %h, bar_valid = %b, output_bar = %h", $time, input_bar, bar_valid, output_bar);
    end

endmodule