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
    integer linear_res_file, qkmm_res_file, softmax_res_file, attmm_res_file, connect_res_file;
    integer linear_ref_file, qkmm_ref_file, softmax_ref_file,attmm_ref_file, connect_ref_file;
    integer linear_ref, qkmm_ref, softmax_ref, attmm_ref, connect_ref;
    reg [63:0] linear_ref_data [0:511];
    reg [63:0] qkmm_ref_data [0:511];
    reg [63:0] softmax_ref_data [0:511];
    reg [63:0] attmm_ref_data [0:511];
    reg [63:0] connect_ref_data [0:511];
    integer linear_pass = 1;
    integer qkmm_pass = 1;
    integer softmax_pass = 1;
    integer attmm_pass = 1;
    integer connect_pass = 1;
    parameter WIDTH = 64;
    parameter LENGTH = 4096;
    parameter WEIGHT_BASE = 'd0;
    parameter WEIGHT_SIZE = 'd2048;                                           // 128 * 128 * 8bit / 64(mem width) = 2048
    parameter INPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE;
    parameter INPUT_SIZE = 'd512;                                             // 32 * 128 * 8 bit / 64(mem width) = 512
    parameter LINEAR_OUTPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE;
    parameter LINEAR_OUTPUT_SIZE = 'd512;                                     // 32 * 128 * 8 bit / 64(mem width) = 512
    parameter QKMM_OUTPUT_BASE = INPUT_BASE + INPUT_SIZE;
    parameter QKMM_OUTPUT_SIZE = 'd512;                                     // 32 * 32 * 4 * 8 bit / 64(mem width) = 512
    parameter SOFTMAX_OUTPUT_BASE = LINEAR_OUTPUT_BASE + LINEAR_OUTPUT_SIZE;
    parameter ATTMM_OUTPUT_BASE = LINEAR_OUTPUT_BASE + LINEAR_OUTPUT_SIZE;
    parameter CONNECT_OUTPUT_BASE = QKMM_OUTPUT_BASE + QKMM_OUTPUT_SIZE;

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
        softmax_res_file = $fopen("softmax_res.txt", "w");
        softmax_ref_file = $fopen("softmax_output.txt", "r");
        attmm_res_file = $fopen("attmm_res.txt", "w");
        attmm_ref_file = $fopen("attmm_output.txt", "r");
        connect_res_file = $fopen("connect_res.txt", "w");
        connect_ref_file = $fopen("connect_output.txt", "r");

        #20 ;
        rst_n = 1;
        
        #20 ;
        // Feed input data
        start = 1;  // flush the computation

// [----------------- linear -------------------]
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_linear == 1'b1);
        #200 ;

        // compare the res & ref
        for (int i = 0; i < 512; i = i + 1) begin
            linear_ref = $fscanf(linear_ref_file, "%h", linear_ref_data[i]);
        end

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

        // check
        if (linear_pass) begin
            $display("LINEAR PASSED");
        end else begin
            $display("LINEAR FAILED");
        end

// [----------------- qkmm -------------------]
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_qkmm == 1'b1);
        #200 ;

        // compare the res & ref
        for (int i = 0; i < 512; i = i + 1) begin
            qkmm_ref = $fscanf(qkmm_ref_file, "%h", qkmm_ref_data[i]);
        end

        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(qkmm_res_file,"\n");
            end
            $fwrite(qkmm_res_file,"%h ", mhsa_acc_wrapper_inst.bar0.mem_data[i+QKMM_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar0.mem_data[i+QKMM_OUTPUT_BASE] !== qkmm_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, qkmm_ref_data[i], mhsa_acc_wrapper_inst.bar0.mem_data[i+QKMM_OUTPUT_BASE] );
                qkmm_pass = 0;
            end
        end

        // check
        if (qkmm_pass) begin
            $display("QKMM PASSED");
        end else begin
            $display("QKMM FAILED");
        end

//  [----------------- softmax -------------------]
        // // Wait for softmax_done signal
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_softmax == 1'b1);
        #200 ;

        // Compare the softmax output with the reference data
        for (int i = 0; i < 512; i = i + 1) begin
            softmax_ref = $fscanf(softmax_ref_file, "%h", softmax_ref_data[i]);
        end

        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(softmax_res_file,"\n");
            end
            $fwrite(softmax_res_file,"%h ", mhsa_acc_wrapper_inst.bar1.mem_data[i+SOFTMAX_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar1.mem_data[i+SOFTMAX_OUTPUT_BASE] !== softmax_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, softmax_ref_data[i], mhsa_acc_wrapper_inst.bar1.mem_data[i+SOFTMAX_OUTPUT_BASE] );
                softmax_pass = 0;
            end
        end

        // check
        if (softmax_pass) begin
            $display("SOFTMAX PASSED");
        end else begin
            $display("SOFTMAX FAILED");
        end

// [----------------- attmm -------------------]
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_attmm == 1'b1);
        #200 ;

        // compare the res & ref
        for (int i = 0; i < 512; i = i + 1) begin
            attmm_ref = $fscanf(attmm_ref_file, "%h", attmm_ref_data[i]);
        end

        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(attmm_res_file,"\n");
            end
            $fwrite(attmm_res_file,"%h ", mhsa_acc_wrapper_inst.bar2.mem_data[i+ATTMM_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar2.mem_data[i+ATTMM_OUTPUT_BASE] !== attmm_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, attmm_ref_data[i], mhsa_acc_wrapper_inst.bar2.mem_data[i+ATTMM_OUTPUT_BASE] );
                attmm_pass = 0;
            end
        end

        // check
        if (attmm_pass) begin
            $display("ATTMM PASSED");
        end else begin
            $display("ATTMM FAILED");
        end

// [----------------- connect -------------------]

        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_connect == 1'b1);
        #200 ;

        // compare the res & ref
        for (int i = 0; i < 512; i = i + 1) begin
            connect_ref = $fscanf(connect_ref_file, "%h", connect_ref_data[i]);
        end

        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(connect_res_file,"\n");
            end
            $fwrite(connect_res_file,"%h ", mhsa_acc_wrapper_inst.bar0.mem_data[i+CONNECT_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar0.mem_data[i+CONNECT_OUTPUT_BASE] !== connect_ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %h, Got %h", 
                        i, connect_ref_data[i], mhsa_acc_wrapper_inst.bar0.mem_data[i+CONNECT_OUTPUT_BASE] );
                connect_pass = 0;
            end
        end

        // check
        if (connect_pass) begin
            $display("CONNECT PASSED");
        end else begin
            $display("CONNECT FAILED");
        end

        // [----------------- finish -------------------]  
        $fclose(linear_res_file);
        $fclose(linear_ref_file);
        $fclose(qkmm_res_file);
        $fclose(qkmm_ref_file);
        $fclose(softmax_res_file);
        $fclose(softmax_ref_file);
        $fclose(attmm_res_file);
        $fclose(attmm_ref_file);
        $fclose(connect_res_file);
        $fclose(connect_ref_file);
        $display("Simulation finished.");
        $finish;

    end

endmodule
