`timescale 1ps/1ps

module wrapper_tb (
);

    //clk and rst_n
    logic clk;
    logic rst_n;
    logic write_en_bar0;
    logic [63:0] data_in_bar0;
    logic [31:0] addr_bar0;
    logic [63:0] data_out_bar0;
    logic write_en_bar1;
    logic [63:0] data_in_bar1;
    logic [31:0] addr_bar1;
    logic [63:0] data_out_bar1;
    logic soc_write_en;                       //1 for write, 0 for read
    logic [63:0] soc_data_in;
    logic [31:0] soc_addr;
    logic [63:0] soc_data_out;
    logic done;
    logic [31:0] input_base;
    logic [31:0] output_base;
    logic start;
    logic linear_done;
    integer linear_res_file, qkmm_res_file;
    integer linear_ref_file, qkmm_ref_file;
    integer linear_ref, qkmm_ref;
    reg [63:0] linear_ref_data [0:511];
    reg [63:0] qkmm_ref_data [0:127];
    integer linear_pass = 1;
    integer qkmm_pass = 1;
    parameter LINEAR_OUTPUT_BASE = 'd2048;
    parameter QKMM_OUTPUT_BASE = LINEAR_OUTPUT_BASE + 'd512;     // 32 * 128 * 8 bit / 64(mem width) = 512

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    mhsa_acc_wrapper mhsa_acc_wrapper_inst(
        .clk(clk),
        .rst_n(rst_n),

        // control signals
        .done(done),
        .start(start),
        .input_base(input_base),
        .output_base(output_base),

        // unified sram interface
        .soc_write_en(soc_write_en),                       //1 for write, 0 for read
        .soc_data_in(soc_data_in),
        .soc_addr(soc_addr),
        .soc_data_out(soc_data_out)
    );

    assign soc_write_en = 0;

    initial begin
        clk = 0;
        rst_n = 0;
        linear_res_file = $fopen("linear_res.txt", "w");
        linear_ref_file = $fopen("linear_q_output.txt", "r");
        qkmm_res_file = $fopen("qkmm_res.txt", "w");
        qkmm_ref_file = $fopen("qkmm_output.txt", "r");

        #20 ;
        rst_n = 1;
        
        #20 ;
        // Feed input data
        start = 1;  // flush the computation

        // Wait for linear_done signal
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_linear == 1'b1);
        #200 ;

        // read the ref
        for (int i = 0; i < 512; i = i + 1) begin
            linear_ref = $fscanf(linear_ref_file, "%h", linear_ref_data[i]);
        end

        // compare the res & ref
        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(linear_res_file,"\n");
            end
            $fwrite(linear_res_file,"%h ", mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE] !== linear_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, linear_ref_data[i], mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE] );
                linear_pass = 0;
            end
        end

        // Wait for qkmm_done signal
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_qkmm == 1'b1);
        #200 ;

        for (int i = 0; i < 512; i = i + 1) begin
            qkmm_ref = $fscanf(qkmm_ref_file, "%h", qkmm_ref_data[i]);
        end

        // compare the res & ref
        for (int i = 0; i < 128; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(qkmm_res_file,"\n");
            end
            $fwrite(qkmm_res_file,"%h ", mhsa_acc_wrapper_inst.bar2.mem_data[i+QKMM_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar2.mem_data[i+QKMM_OUTPUT_BASE] !== qkmm_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, qkmm_ref_data[i], mhsa_acc_wrapper_inst.bar2.mem_data[i+QKMM_OUTPUT_BASE] );
                qkmm_pass = 0;
            end
        end


        // print result
        if (linear_pass) begin
            $display("LINEAR PASSED");
        end else begin
            $display("LINEAR FAILED");
        end

        if (qkmm_pass) begin
            $display("QKMM PASSED");
        end else begin
            $display("QKMM FAILED");
        end

        $finish;

    end

endmodule
