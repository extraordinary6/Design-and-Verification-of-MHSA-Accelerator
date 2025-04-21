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
    integer res_file;
    integer ref_file;
    integer scan_ref;
    reg [63:0] ref_data [0:127];
    integer pass = 1;
    parameter LINEAR_OUTPUT_BASE = 'd800;

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
        res_file = $fopen("linear_res.txt", "w");
        ref_file = $fopen("linear_ref.txt", "r");

        #20 ;
        rst_n = 1;
        
        #20 ;
        // Feed input data
        start = 1;  // flush the computation

        // Wait for linear_done signal
        wait(mhsa_acc_wrapper_inst.mhsa_acc_top_inst.done_linear == 1'b1);
        #200 ;

        // read the ref
        for (int i = 0; i < 128; i = i + 1) begin
            scan_ref = $fscanf(ref_file, "%h", ref_data[i]);
        end

        // compare the res & ref
        for (int i = 0; i < 128; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(res_file,"\n");
            end
            $fwrite(res_file,"%h ", mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE]);

            if (mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE] !== ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %d, Got %d", 
                        i, ref_data[i], mhsa_acc_wrapper_inst.bar1.mem_data[i+LINEAR_OUTPUT_BASE] );
                pass = 0;
            end
        end

        // print result
        if (pass) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;

    end

endmodule
