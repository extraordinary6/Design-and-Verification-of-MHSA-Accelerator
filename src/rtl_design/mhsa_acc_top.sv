//===================================================================== 
// Description: 
// mhsa_acc_top
//  |-- FSM
//  |-- linear(pre)
//  |   |-- linear_q
//  |   |-- linear_k
//  |   |-- linear_v 
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date:Initial version @ 2024/3/28
// V1 date:Instantiate linear @ 2024/4/21
// V2 data:Add qkmm attmm arbiter @ 2024/4/24
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
localparam SCALE = 3'b011;
localparam SOFTMAX = 3'b100;
localparam ATTMM = 3'b101;       //attention matmul
localparam POOL = 3'b110;
localparam DONE = 3'b111;

logic [2:0] state, next_state; 

logic start_linear;
logic start_qkmm;
logic start_scale;
logic start_softmax;
logic start_attmm;
logic start_pool;

logic done_linear;
logic done_qkmm;
logic done_scale;
logic done_softmax;
logic done_attmm;
logic done_pool;

// [----------------- fsm -------------------]

assign start_linear = (state == LINERA) ? 1'b1 : 1'b0;
assign start_qkmm = (state == QKMM) ? 1'b1 : 1'b0;
assign start_scale = (state == SCALE) ? 1'b1 : 1'b0;
assign start_softmax = (state == SOFTMAX) ? 1'b1 : 1'b0;
assign start_attmm = (state == ATTMM) ? 1'b1 : 1'b0;
assign start_pool = (state == POOL) ? 1'b1 : 1'b0;
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
                next_state = SCALE;
            end else begin
                next_state = QKMM;
            end
        end
        SCALE: begin
            if (done_scale) begin
                next_state = SOFTMAX;
            end else begin
                next_state = SCALE;
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
                next_state = POOL; 
            end else begin 
                next_state = ATTMM; 
            end 
        end 
        POOL: begin 
            if (done_pool) begin 
                next_state = DONE; 
            end else begin 
                next_state = POOL; 
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

logic bar1_write_en_linear;
logic [WIDTH - 1 : 0] bar1_data_in_linear;
logic [31 : 0] bar1_addr_linear;

logic bar2_write_en_linear;
logic [WIDTH - 1 : 0] bar2_data_in_linear;
logic [31 : 0] bar2_addr_linear;

linear linear_q(
    .clk(clk),
    .rst_n(rst_n),

    .start(start_linear),
    .done(done_linear),

    .write_en_bar0(),
    .data_in_bar0(),
    .addr_bar0(bar0_addr),
    .data_out_bar0(bar0_data_out),                  // data_out global broadcast

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

    .write_en_bar1(bar3_write_en),
    .data_in_bar1(bar3_data_in),
    .addr_bar1(bar3_addr),
    .data_out_bar1(bar3_data_out)
);

// [----------------- qkmm ----------------- ]

logic bar1_write_en_qkmm;
logic [WIDTH - 1 : 0] bar1_data_in_qkmm;
logic [31 : 0] bar1_addr_qkmm;

logic bar2_write_en_qkmm;
logic [WIDTH - 1 : 0] bar2_data_in_qkmm;
logic [31 : 0] bar2_addr_qkmm;

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
    .data_out_bar1(bar2_data_out)
);

// [----------------- attmm ----------------- ]

// [----------------- bar arbiter ----------------- ]
always_comb begin
    case(state)
        LINERA: begin
            bar1_write_en = bar1_write_en_linear;
            bar1_data_in = bar1_data_in_linear;
            bar1_addr = bar1_addr_linear;

            bar2_write_en = bar2_write_en_linear;
            bar2_data_in = bar2_data_in_linear;
            bar2_addr = bar2_addr_linear;
        end
        QKMM: begin
            bar1_write_en = bar1_write_en_qkmm;
            bar1_data_in = bar1_data_in_qkmm;
            bar1_addr = bar1_addr_qkmm;

            bar2_write_en = bar2_write_en_qkmm;
            bar2_data_in = bar2_data_in_qkmm;
            bar2_addr = bar2_addr_qkmm;
        end
        default: begin
            bar1_write_en = 1'b0;
            bar1_data_in = '0;
            bar1_addr = '0;

            bar2_write_en = 1'b0;
            bar2_data_in = '0;
            bar2_addr = '0;
        end
    endcase
end

assign bar0_write_en = 1'b0;
assign bar0_data_in = '0;

endmodule