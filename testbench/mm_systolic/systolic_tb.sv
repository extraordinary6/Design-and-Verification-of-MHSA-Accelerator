`timescale 1ps/1ps

module systolic_tb (
);

    //clk and rst_n
    logic clk;
    logic rst_n;
    logic [63:0] row_bar;
    logic [63:0] col_bar;
    logic bar_valid;
    logic flush;
    integer row_file, col_file, res_file, ref_file;
    integer scan_row, scan_col, scan_ref;
    reg [7:0] row_data [0:7];
    reg [7:0] col_data [0:7];
    reg [7:0] ref_data [0:7][0:7];
    reg [7:0] res_data [0:7][0:7];
    integer pass = 1;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    mm_systolic dut (
    .clk(clk),
    .rst_n(rst_n),
    .row_bar(row_bar),
    .col_bar(col_bar),
    .bar_valid(bar_valid),
    .flush(flush)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        row_bar = 0;
        col_bar = 0;
        row_file = $fopen("row_data.txt", "r");
        col_file = $fopen("col_data.txt", "r");
        ref_file = $fopen("ref_result.txt", "r");
        res_file = $fopen("res.txt", "w");

        #20 ;
        rst_n = 1;
        
        #20 ;
        // Feed input data
        flush = 1;  // flush the computation
        #10 ;
        flush = 0;

        for (int i = 0; i < 128; i = i + 1) begin
            // Read row data
            for (int j = 0; j < 8; j = j + 1) 
                scan_row = $fscanf(row_file, "%d", row_data[j]);
            
            // Read column data
            for (int j = 0; j < 8; j = j + 1)
                scan_col = $fscanf(col_file, "%d", col_data[j]);
            
            // Pack data
            bar_valid = 1;
            row_bar = {row_data[0], row_data[1], row_data[2], row_data[3],
                      row_data[4], row_data[5], row_data[6], row_data[7]};
            col_bar = {col_data[0], col_data[1], col_data[2], col_data[3],
                      col_data[4], col_data[5], col_data[6], col_data[7]};
            
            @(posedge clk);
        end

        bar_valid = 0;  // End of data stream
        row_bar = 0;
        col_bar = 0;

        // Wait for computation
        #2000;  // Adjust based on pipeline depth
        
        // Write and verify results

        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 8; j = j + 1) begin
                scan_ref = $fscanf(ref_file, "%d", ref_data[i][j]);
            end
        end

        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 8; j = j + 1) begin
                res_data[i][j] = dut.res[i][j];
                $fwrite(res_file, "%d ", $signed(dut.res[i][j]));
                
                // Compare with reference
                if ($signed(res_data[i][j]) !== ref_data[i][j]) begin
                    $display("Mismatch at [%0d][%0d]: Expected %d, Got %d", 
                            i, j, ref_data[i][j], res_data[i][j]);
                    pass = 0;
                end
            end
            $fwrite(res_file, "\n");
        end

        // Print final result
        if (pass) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;

    end

endmodule
