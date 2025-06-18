//===================================================================== 
// Description: 
// mhsa_acc_top
//  |-- FSM
//  |-- MHSA cmpt
//  |   |-- linear
//  |   |   |-- linear_q
//  |   |   |-- linear_k
//  |   |   |-- linear_v
//  |   |-- qkmm
//  |   |-- softmax
//  |   |-- attmm
//  |   |-- connect
//  |-- arbiter
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2025/3/28
// V1 date:Instantiate linear @ 2025/4/21
// V2 data:Add qkmm attmm arbiter @ 2025/4/24
// V3 data:add conncet @ 2025/5/8
// ==================================================================== 

module mhsa_acc_top#(
    parameter WIDTH = 64,
    parameter LENGTH = 4096
)(
    input logic clk,
    input logic rst_n,

    // control signals
    input logic start,
    output logic done,
    input logic [31:0] input_base,
    input logic [31:0] output_base,

    // unified sram interface
    output logic bar0_write_en,
    output logic [WIDTH - 1 : 0] bar0_data_in,
    output logic [31 : 0] bar0_addr,
    input logic [WIDTH - 1 : 0] bar0_data_out,

    output logic bar1_write_en,
    output logic [WIDTH - 1 : 0] bar1_data_in,
    output logic [31 : 0] bar1_addr,
    input logic [WIDTH - 1 : 0] bar1_data_out,

    output logic bar2_write_en,
    output logic [WIDTH - 1 : 0] bar2_data_in,
    output logic [31 : 0] bar2_addr,
    input logic [WIDTH - 1 : 0] bar2_data_out,

    output logic bar3_write_en,
    output logic [WIDTH - 1 : 0] bar3_data_in,
    output logic [31 : 0] bar3_addr,
    input logic [WIDTH - 1 : 0] bar3_data_out
);

localparam IDLE = 3'b000;
localparam LINERA = 3'b001;
localparam QKMM = 3'b010;
localparam SOFTMAX = 3'b011;
localparam ATTMM = 3'b100;       //attention matmul
localparam CONNECT = 3'b101;
localparam DONE = 3'b110;

logic [2:0] state, next_state; 

logic start_linear;
logic start_qkmm;
logic start_softmax;
logic start_attmm;
logic start_connect;

logic done_linear;
logic done_qkmm;
logic done_softmax;
logic done_attmm;
logic done_connect;

// [----------------- fsm -------------------]

assign start_linear = (state == LINERA) ? 1'b1 : 1'b0;
assign start_qkmm = (state == QKMM) ? 1'b1 : 1'b0;
assign start_softmax = (state == SOFTMAX) ? 1'b1 : 1'b0;
assign start_attmm = (state == ATTMM) ? 1'b1 : 1'b0;
assign start_connect = (state == CONNECT) ? 1'b1 : 1'b0;
assign done = (state == DONE) ? 1'b1 : 1'b0;

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
                next_state = LINERA;
            end else begin
                next_state = IDLE;
            end
        end
        LINERA: begin
            if (done_linear) begin
                next_state = QKMM;
            end else begin
                next_state = LINERA;
            end
        end
        QKMM: begin
            if (done_qkmm) begin
                next_state = SOFTMAX;
            end else begin
                next_state = QKMM;
            end
        end
        SOFTMAX: begin
            if (done_softmax) begin
                next_state = ATTMM;
            end else begin
                next_state = SOFTMAX;
            end
        end 
        ATTMM: begin 
            if (done_attmm) begin 
                next_state = CONNECT; 
            end else begin 
                next_state = ATTMM; 
            end 
        end 
        CONNECT: begin 
            if (done_connect) begin 
                next_state = DONE; 
            end else begin 
                next_state = CONNECT; 
            end 
        end 
        DONE: begin 
            if (!start) begin 
                next_state = IDLE; 
            end else begin 
                next_state = DONE; 
            end 
        end 
        default: next_state = IDLE;
    endcase
end

// [----------------- linear ----------------- ]
logic bar0_write_en_linear;
logic [WIDTH - 1 : 0] bar0_data_in_linear;
logic [31 : 0] bar0_addr_linear;

logic bar1_write_en_linear;
logic [WIDTH - 1 : 0] bar1_data_in_linear;
logic [31 : 0] bar1_addr_linear;

logic bar2_write_en_linear;
logic [WIDTH - 1 : 0] bar2_data_in_linear;
logic [31 : 0] bar2_addr_linear;

logic bar3_write_en_linear;
logic [WIDTH - 1 : 0] bar3_data_in_linear;
logic [31 : 0] bar3_addr_linear;


linear linear_q(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_linear),
    .done(done_linear),

    .write_en_bar0(bar0_write_en_linear),
    .data_in_bar0(bar0_data_in_linear),
    .addr_bar0(bar0_addr_linear),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar1_write_en_linear),
    .data_in_bar1(bar1_data_in_linear),
    .addr_bar1(bar1_addr_linear),
    .data_out_bar1(bar1_data_out)
);

linear linear_k(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_linear),
    .done(),

    .write_en_bar0(),
    .data_in_bar0(),
    .addr_bar0(),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar2_write_en_linear),
    .data_in_bar1(bar2_data_in_linear),
    .addr_bar1(bar2_addr_linear),
    .data_out_bar1(bar2_data_out)
);

linear linear_v(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_linear),
    .done(),

    .write_en_bar0(),
    .data_in_bar0(),
    .addr_bar0(),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar3_write_en_linear),
    .data_in_bar1(bar3_data_in_linear),
    .addr_bar1(bar3_addr_linear),
    .data_out_bar1(bar3_data_out)
);

// [----------------- qkmm ----------------- ]

logic bar1_write_en_qkmm;
logic [WIDTH - 1 : 0] bar1_data_in_qkmm;
logic [31 : 0] bar1_addr_qkmm;

logic bar2_write_en_qkmm;
logic [WIDTH - 1 : 0] bar2_data_in_qkmm;
logic [31 : 0] bar2_addr_qkmm;

logic bar0_write_en_qkmm;
logic [WIDTH - 1 : 0] bar0_data_in_qkmm;
logic [31 : 0] bar0_addr_qkmm;

qkmm qkmm_inst(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_qkmm),
    .done(done_qkmm),

    .write_en_bar0(bar1_write_en_qkmm),
    .data_in_bar0(bar1_data_in_qkmm),
    .addr_bar0(bar1_addr_qkmm),
    .data_out_bar0(bar1_data_out),

    .write_en_bar1(bar2_write_en_qkmm),
    .data_in_bar1(bar2_data_in_qkmm),
    .addr_bar1(bar2_addr_qkmm),
    .data_out_bar1(bar2_data_out),

    .write_en_bar2(bar0_write_en_qkmm),
    .data_in_bar2(bar0_data_in_qkmm),
    .addr_bar2(bar0_addr_qkmm),
    .data_out_bar2(bar0_data_out)
);

// [----------------- softmax ----------------- ]
logic bar0_write_en_softmax;
logic [WIDTH - 1 : 0] bar0_data_in_softmax;
logic [31 : 0] bar0_addr_softmax;

logic bar1_write_en_softmax;
logic [WIDTH - 1 : 0] bar1_data_in_softmax;
logic [31 : 0] bar1_addr_softmax;

softmax softmax_inst(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_softmax),
    .done(done_softmax),

    .write_en_bar0(bar0_write_en_softmax),
    .data_in_bar0(bar0_data_in_softmax),
    .addr_bar0(bar0_addr_softmax),
    .data_out_bar0(bar0_data_out),

    .write_en_bar1(bar1_write_en_softmax),
    .data_in_bar1(bar1_data_in_softmax),
    .addr_bar1(bar1_addr_softmax),
    .data_out_bar1(bar1_data_out)
);

// [----------------- attmm ----------------- ]

logic bar1_write_en_attmm;
logic [WIDTH - 1 : 0] bar1_data_in_attmm;
logic [31 : 0] bar1_addr_attmm;

logic bar2_write_en_attmm;
logic [WIDTH - 1 : 0] bar2_data_in_attmm;
logic [31 : 0] bar2_addr_attmm;

logic bar3_write_en_attmm;
logic [WIDTH - 1 : 0] bar3_data_in_attmm;
logic [31 : 0] bar3_addr_attmm;

attmm attmm_inst(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_attmm),
    .done(done_attmm),

    .write_en_bar0(bar1_write_en_attmm),
    .data_in_bar0(bar1_data_in_attmm),
    .addr_bar0(bar1_addr_attmm),
    .data_out_bar0(bar1_data_out),

    .write_en_bar1(bar3_write_en_attmm),
    .data_in_bar1(bar3_data_in_attmm),
    .addr_bar1(bar3_addr_attmm),
    .data_out_bar1(bar3_data_out),

    .write_en_bar2(bar2_write_en_attmm),
    .data_in_bar2(bar2_data_in_attmm),
    .addr_bar2(bar2_addr_attmm),
    .data_out_bar2(bar2_data_out)
);

// [----------------- connect ----------------- ]

logic bar0_write_en_connect;
logic [WIDTH - 1 : 0] bar0_data_in_connect;
logic [31 : 0] bar0_addr_connect;

logic bar2_write_en_connect;
logic [WIDTH - 1 : 0] bar2_data_in_connect;
logic [31 : 0] bar2_addr_connect;

connect connect_inst(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_connect),
    .done(done_connect),

    .write_en_bar0(bar2_write_en_connect),
    .data_in_bar0(bar2_data_in_connect),
    .addr_bar0(bar2_addr_connect),
    .data_out_bar0(bar2_data_out),

    .write_en_bar1(bar0_write_en_connect),
    .data_in_bar1(bar0_data_in_connect),
    .addr_bar1(bar0_addr_connect),
    .data_out_bar1(bar0_data_out)
);

// [----------------- bar arbiter ----------------- ]

// data_out global broadcast

always_comb begin
    case(state)
        LINERA: begin
            bar0_write_en = bar0_write_en_linear;
            bar0_data_in = bar0_data_in_linear;
            bar0_addr = bar0_addr_linear;

            bar1_write_en = bar1_write_en_linear;
            bar1_data_in = bar1_data_in_linear;
            bar1_addr = bar1_addr_linear;

            bar2_write_en = bar2_write_en_linear;
            bar2_data_in = bar2_data_in_linear;
            bar2_addr = bar2_addr_linear;

            bar3_write_en = bar3_write_en_linear;
            bar3_data_in = bar3_data_in_linear;
            bar3_addr = bar3_addr_linear;
        end
        QKMM: begin
            bar0_write_en = bar0_write_en_qkmm;
            bar0_data_in = bar0_data_in_qkmm;
            bar0_addr = bar0_addr_qkmm;

            bar1_write_en = bar1_write_en_qkmm;
            bar1_data_in = bar1_data_in_qkmm;
            bar1_addr = bar1_addr_qkmm;

            bar2_write_en = bar2_write_en_qkmm;
            bar2_data_in = bar2_data_in_qkmm;
            bar2_addr = bar2_addr_qkmm;

            bar3_write_en = 1'b0;
            bar3_data_in = '0;
            bar3_addr = '0;
        end
        SOFTMAX: begin
            bar0_write_en = bar0_write_en_softmax;
            bar0_data_in = bar0_data_in_softmax;
            bar0_addr = bar0_addr_softmax;

            bar1_write_en = bar1_write_en_softmax;
            bar1_data_in = bar1_data_in_softmax;
            bar1_addr = bar1_addr_softmax;

            bar2_write_en = 1'b0;
            bar2_data_in = '0;
            bar2_addr = '0;

            bar3_write_en = 1'b0;
            bar3_data_in = '0;
            bar3_addr = '0;
        end
        ATTMM: begin
            bar0_write_en = 1'b0;
            bar0_data_in = '0;
            bar0_addr = '0;

            bar1_write_en = bar1_write_en_attmm;
            bar1_data_in = bar1_data_in_attmm;
            bar1_addr = bar1_addr_attmm;

            bar2_write_en = bar2_write_en_attmm;
            bar2_data_in = bar2_data_in_attmm;
            bar2_addr = bar2_addr_attmm;

            bar3_write_en = bar3_write_en_attmm;
            bar3_data_in = bar3_data_in_attmm;
            bar3_addr = bar3_addr_attmm;
        end
        CONNECT: begin
            bar0_write_en = bar0_write_en_connect;
            bar0_data_in = bar0_data_in_connect;
            bar0_addr = bar0_addr_connect;

            bar1_write_en = 1'b0;
            bar1_data_in = '0;
            bar1_addr = '0;

            bar2_write_en = bar2_write_en_connect;
            bar2_data_in = bar2_data_in_connect;
            bar2_addr = bar2_addr_connect;

            bar3_write_en = 1'b0;
            bar3_data_in = '0;
            bar3_addr = '0;
        end
        DONE: begin
            bar0_write_en = 1'b0;
            bar0_data_in = '0;
            bar0_addr = '0;

            bar1_write_en = 1'b0;
            bar1_data_in = '0;
            bar1_addr = '0;

            bar2_write_en = 1'b0;
            bar2_data_in = '0;
            bar2_addr = '0;

            bar3_write_en = 1'b0;
            bar3_data_in = '0;
            bar3_addr = '0;
        end
        default: begin
            bar0_write_en = 1'b0;
            bar0_data_in = '0;
            bar0_addr = '0;

            bar1_write_en = 1'b0;
            bar1_data_in = '0;
            bar1_addr = '0;

            bar2_write_en = 1'b0;
            bar2_data_in = '0;
            bar2_addr = '0;

            bar3_write_en = 1'b0;
            bar3_data_in = '0;
            bar3_addr = '0;
        end
    endcase
end

endmodule