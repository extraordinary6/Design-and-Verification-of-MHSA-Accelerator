//===================================================================== 
// Description: 
// linear layer : X * W -> Q/K/V
//  |-- FSM
//  |   |-- loop counter
//  |   |-- ctrl logic 
//  |   |-- fsm
//  |-- address generator
//  |   |-- read address
//  |   |-- write address
//  |-- systolic
//  |-- debug logic(opt.)
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/4/17
// V1 date:Fix the bug and complete testbench @ 2024/4/20
// V2 data:Merge bar2 to bar1 @ 2024/4/21
// v3 data:Modify Weight (32,128) -> (128,32) @ 2024/4/24
// v4 data:parameterize @ 2024/5/8
// ==================================================================== 

// only for linear tb
//`define NO_TRANSPOSE

module linear#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096,
    parameter WEIGHT_BASE = 'd0,
    parameter WEIGHT_SIZE = 'd2048,                                           // 128 * 128 * 8bit / 64(mem width) = 2048
    parameter INPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE,
    parameter INPUT_SIZE = 'd512,                                             // 32 * 128 * 8 bit / 64(mem width) = 512
    parameter LINEAR_OUTPUT_BASE = WEIGHT_BASE + WEIGHT_SIZE,
    parameter LINEAR_OUTPUT_SIZE = 'd512
)(
    input logic clk,
    input logic rst_n,

    input logic start,
    output logic done,

//  X input
    output   write_en_bar0,                       //1 for write, 0 for read
    output   [WIDTH - 1 : 0] data_in_bar0,
    output logic [31 : 0] addr_bar0,
    input logic [WIDTH - 1 : 0] data_out_bar0,      

//  Weight input
    output   write_en_bar1,                       //1 for write, 0 for read
    output   [WIDTH - 1 : 0] data_in_bar1,
    output logic [31 : 0] addr_bar1,
    input logic [WIDTH - 1 : 0] data_out_bar1

);
logic [31:0] read_addr_w;
logic [31:0] read_addr_x;
logic [31:0] write_addr;

logic [31:0] res [0:7][0:7];         // 8*8 systolic array, each PE output 8 bits
localparam IDLE = 2'b00;
localparam READ = 2'b01;
localparam WAIT = 2'b10;        // wait for compute finish
localparam WRITE = 2'b11;

logic [1:0] state, next_state;
logic bar_valid;           // bar0 and bar1 valid signal
logic flush;              // flush PE result

assign write_en_bar0 = 1'b0;
assign data_in_bar0 = 64'b0;
assign addr_bar0 = INPUT_BASE + read_addr_x; // read address for X input
assign addr_bar1 = (state == WRITE) ? ( write_addr + LINEAR_OUTPUT_BASE ) : ( read_addr_w + WEIGHT_BASE );

// [-------------------------- loop counter --------------------------]
logic [7:0] read_cnt;           // read 128 clock cycles
logic [3:0] wait_cnt;           // wait 15 clock cycles ( read latency 7 + systolic latency 8 )
logic [2:0] write_cnt;          // write 8 clock cycles
logic [5:0] loop_cnt;           // x_loop(32/8) * y_loop(128/8) = 4*16 = 64  

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_cnt <= 8'b0;
    end else begin
        if (state == READ) begin
            read_cnt <= read_cnt + 1'b1;
        end else begin
            read_cnt <= 8'b0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_cnt <= 3'b0;
    end else begin
        if (state == WRITE) begin
            write_cnt <= write_cnt + 1'b1;
        end else begin
            write_cnt <= 3'b0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wait_cnt <= 4'b0;
    end else begin
        if (state == WAIT) begin
            wait_cnt <= wait_cnt + 1'b1;
        end else begin
            wait_cnt <= 4'b0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        loop_cnt <= 6'b0;
    end else begin
        if (write_cnt == 3'd7) begin
                loop_cnt <= loop_cnt + 1'b1;
        end else begin
            loop_cnt <= loop_cnt;
        end
    end
end
// [-------------------------- input address generator --------------------------]

// row : X input
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_addr_x <= 32'b0;
    end else begin
        if(state == READ) begin
            if(read_cnt == 8'd127) begin
                if(loop_cnt[3:0] == 4'b1111) begin              // y_loop = 16
                    read_addr_x <= read_addr_x - 4*127 + 1;
                end else begin
                    read_addr_x <= read_addr_x - 4*127;
                end
            end else begin
                read_addr_x <= read_addr_x + 4;
            end
        end
        else begin
            read_addr_x <= read_addr_x;
        end
    end
end

// col : weight input
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_addr_w <= 32'b0;
    end else begin
        if(state == READ) begin
            if(read_cnt == 8'd127) begin
                if(loop_cnt[3:0] == 4'b1111) begin
                    read_addr_w <= 32'b0;
                end else begin
                    read_addr_w <= read_addr_w - 16*127 + 1;
                end
            end else begin
                read_addr_w <= read_addr_w + 16;
            end
        end
        else begin
            read_addr_w <= read_addr_w;
        end
    end
end

// [-------------------------- output address generator --------------------------]

assign write_en_bar1 = (state == WRITE) ? 1'b1 : 1'b0;

// transpose the output data

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_addr <= 32'b0;
    end else begin
        if (state == WRITE) begin
            if (write_cnt == 3'd7) begin
                if (loop_cnt[3:0] == 4'b1111) begin
                    write_addr <= write_addr - 4*127 + 1;
                end else begin
                    write_addr <= write_addr + 4;
                end
            end
            else begin
                write_addr <= write_addr + 4;
            end
        end
    end
end

//TODO: modify quantization arigorithm
assign data_in_bar1 = {res[0][write_cnt][7:0], res[1][write_cnt][7:0], res[2][write_cnt][7:0], res[3][write_cnt][7:0],
                    res[4][write_cnt][7:0], res[5][write_cnt][7:0], res[6][write_cnt][7:0], res[7][write_cnt][7:0]};

// [-------------------------- fsm --------------------------]

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always_comb begin
    case (state)
        IDLE: begin
            if (start) begin
                next_state = READ;
            end else begin
                next_state = IDLE;
            end
        end
        READ: begin
            if (read_cnt == 8'd127) begin
                next_state = WAIT;
            end else begin
                next_state = READ;
            end
        end
        WAIT: begin
            if (wait_cnt == 4'd15) begin
                next_state = WRITE;
            end else begin
                next_state = WAIT;
            end
        end
        WRITE: begin
            if (write_cnt == 3'd7) begin
                next_state = IDLE;
            end else begin
                next_state = WRITE;
            end
        end
        default: next_state = IDLE;
    endcase
end

// [------------------------ctrl signal------------------------]

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bar_valid <= 0;
    end else if (state == READ) begin
        bar_valid <= 1;
    end else begin
        bar_valid <= 0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flush <= 0;
    end else if (state == IDLE) begin
        flush <= 1;
    end else begin
        flush <= 0;
    end
end

assign done = (loop_cnt == 6'd63) && (write_cnt == 3'd7);


// [------------------------ systolic instantiation ------------------------]

mm_systolic mm_systolic_inst(
    .clk(clk),
    .rst_n(rst_n),

    .row_bar(data_out_bar0),
    .col_bar(data_out_bar1),
    .bar_valid(bar_valid),

    .res(res),

    .flush(flush)                // pull up one cycle to flush PE result
);

// [-------------------------- print for test --------------------------]
// always_ff @(posedge clk) begin
//     if(state == WRITE && next_state == IDLE) begin
//         for (int i = 0; i < 8; i = i + 1) begin
//             for (int j = 0; j < 8; j = j + 1) begin
//                 $write("%0d  ",$signed(res[i][j]));
//             end
//             $write("\n"); 
//         end
//         $write("========================================\n");
//     end
// end

// always_ff @(posedge clk) begin
//     if(write_en_bar1) begin
//         $display("write addr: %0d, data: %h", addr_bar1 , data_in_bar1);
//     end
// end


endmodule