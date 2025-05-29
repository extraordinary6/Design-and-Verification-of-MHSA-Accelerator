//===================================================================== 
// Description: 
// Interface manage unit
// Generates data/address for the Usram & input_base signals for CSR
// Designer : wangziyao1@sjtu.edu.cn
// Revision History: 
// V0 date: Initial version @ 2024/5/27
// V1 date: Swap the reading order of usram, change the address of reg.
// ==================================================================== 

`define START              18'h20000
`define DONE               18'h20004
`define INPUT_BASE         18'h20008
`define OUTPUT_BASE        18'h2000c

module imu(
    // icb bus
    input               icb_cmd_valid,
    output  reg         icb_cmd_ready,
    input               icb_cmd_read,
    input       [31:0]  icb_cmd_addr,
    input       [31:0]  icb_cmd_wdata,
    input       [3:0]   icb_cmd_wmask,

    output  reg         icb_rsp_valid,
    input               icb_rsp_ready,
    output  reg [31:0]  icb_rsp_rdata,
    output              icb_rsp_err,

    // clk & rst_n
    input           clk,
    input           rst_n,

    // CSR output
    output  reg [31:0]  start,
    output  reg [31:0]  done,
    output  reg [31:0]  input_base,
    input   reg [31:0]  output_base,

    // usram interface
    output  [31:0]      usram_addr,
    output  reg [63:0]  usram_wdata,
    output  reg         usram_write_en,
    input   [63:0]      usram_rdata
);

wire is_low_part;
wire icb_write_en;
wire usram_sel;

// [------------------------------- addr decoder -------------------------------]
assign usram_addr = {16'b0,icb_cmd_addr[18:3]};    // usram width 64 bit = 8 byte -> low 3 bits for byte offset
assign is_low_part = (icb_cmd_addr[2] == 1'b0);
assign icb_write_en = icb_cmd_valid & icb_cmd_ready & !icb_cmd_read;
assign usram_sel = (usram_addr >= 'h0000 && usram_addr < 'h4000);

// [------------------------------- icb -------------------------------]
assign icb_rsp_err = 1'b0;

// cmd ready, icb_cmd_ready
always@(posedge clk)
begin
    if(!rst_n) begin
        icb_cmd_ready <= 1'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_cmd_ready <= 1'b0;
        end
        else if(icb_cmd_valid) begin
            icb_cmd_ready <= 1'b1;
        end
        else begin
            icb_cmd_ready <= icb_cmd_ready;
        end
    end
end

// ADDR and PARAM setting
always@(posedge clk)
begin
    if(!rst_n) begin
        start <= 32'h0;
        done <= 32'h0;
        input_base <= 32'h0;
        output_base <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read) begin
            case(icb_cmd_addr[17:0])
                `START:  start <= icb_cmd_wdata;
                `DONE:  done <= icb_cmd_wdata;
                `INPUT_BASE:  input_base <= icb_cmd_wdata;
                `OUTPUT_BASE: output_base <= icb_cmd_wdata;
            endcase
        end
        else begin
            start <= start;
            done <= done;
            input_base <= input_base;
            output_base <= output_base;
        end
    end
end


// response valid, icb_rsp_valid
always@(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_valid <= 1'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_rsp_valid <= 1'h1;
        end
        else if(icb_rsp_valid & icb_rsp_ready) begin
            icb_rsp_valid <= 1'h0;
        end
        else begin
            icb_rsp_valid <= icb_rsp_valid;
        end
    end
end

// read data, icb_rsp_rdata
always@(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_rdata <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & icb_cmd_read) begin
            case(icb_cmd_addr[17:0])
                `START:  icb_rsp_rdata <= start;
                `DONE:  icb_rsp_rdata <= done;
                `INPUT_BASE:  icb_rsp_rdata <= input_base;
                `OUTPUT_BASE: icb_rsp_rdata <= output_base;
                default: begin
                    if(usram_sel) begin
                        icb_rsp_rdata <= is_low_part ? usram_rdata[63:32] : usram_rdata[31:0];  // read usram data
                    end
                    else begin
                        icb_rsp_rdata <= 32'h0;         // default return 0
                    end
                end
            endcase
        end
        else begin
            icb_rsp_rdata <= 32'h0;
        end
    end
end

// [------------------------------- icb2usram -------------------------------]
// icb to usram interface : merge double-32bit-write to 64bit-write
// usram address : 0x0000_0000 ~ 0x0000_3FFF
always@(posedge clk) 
begin
    if(!rst_n) begin
        usram_wdata <= 64'h0;
    end
    else begin
        if(icb_write_en & usram_sel) begin
            if(is_low_part) begin
                usram_wdata[31:0] <= usram_wdata[31:0];
                usram_wdata[63:32] <= icb_cmd_wdata;
            end
            else begin
                usram_wdata[31:0] <= icb_cmd_wdata;
                usram_wdata[63:32] <= usram_wdata[63:32];   // hold
            end
        end
        else begin
            usram_wdata <= usram_wdata;  // hold
        end
    end
end

always@(posedge clk)
begin
    if(!rst_n) begin
        usram_write_en <= 1'b0;
    end
    else if(icb_write_en & usram_sel & !is_low_part) begin
        usram_write_en <= 1'b1;         // pull up 1 cycle
    end
    else begin
        usram_write_en <= 1'b0;
    end
end


endmodule
