`timescale 1ps/1ps

module linear_tb (
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
    logic start;
    logic linear_done;
    integer res_file;
    integer ref_file;
    integer scan_ref;
    reg [63:0] ref_data [0:511];
    integer pass = 1;
    parameter LINEAR_OUTPUT_BASE = 'd2048;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    linear dut (
        .clk(clk),
        .rst_n(rst_n),

        .start(start),
        .done(linear_done),

        .write_en_bar0(write_en_bar0),
        .data_in_bar0(data_in_bar0),
        .addr_bar0(addr_bar0),
        .data_out_bar0(data_out_bar0),

        .write_en_bar1(write_en_bar1),
        .data_in_bar1(data_in_bar1),
        .addr_bar1(addr_bar1),
        .data_out_bar1(data_out_bar1)
    );


    mem_x bar0 (
        .clk(clk),
        .write_en(write_en_bar0),
        .data_in(data_in_bar0),
        .addr(addr_bar0),
        .data_out(data_out_bar0)
    );

    mem_w bar1 (
        .clk(clk),
        .write_en(write_en_bar1),
        .data_in(data_in_bar1),
        .addr(addr_bar1),
        .data_out(data_out_bar1)
    );

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
        wait(linear_done == 1'b1);
        #200 ;

        // read the ref
        for (int i = 0; i < 512; i = i + 1) begin
            scan_ref = $fscanf(ref_file, "%h", ref_data[i]);
        end

        // compare the res & ref
        for (int i = 0; i < 512; i++) begin
            if ((i % 4 == 0) && (i != 0)) begin
                $fwrite(res_file,"\n");
            end
            $fwrite(res_file,"%h ", bar1.mem_data[i+LINEAR_OUTPUT_BASE]);

            if (bar1.mem_data[i+LINEAR_OUTPUT_BASE] !== ref_data[i]) begin
                $display("Mismatch at [%0d]: Expected %d, Got %d", 
                        i, ref_data[i], bar1.mem_data[i+LINEAR_OUTPUT_BASE] );
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
