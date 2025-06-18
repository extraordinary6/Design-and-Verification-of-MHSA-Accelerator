//===================================================================== 
// Description: 
// Interface manage unit
// Generates data/address for the Usram & input_base signals for CSR
// Designer : wangziyao1@sjtu.edu.cn, extraordinary.h@sjtu.edu.cn
// Revision History: 
// V0 date: Initial version @ 2025/5/27
// V1 date: Swap the reading order of usram, change the address of reg.
// ==================================================================== 

`define START              20'h70000
`define DONE               20'h70004
`define INPUT_BASE         20'h70008
`define OUTPUT_BASE        20'h7000c

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
    output   [31:0]     icb_rsp_rdata,
    output              icb_rsp_err,

    // clk & rst_n
    input           clk,
    input           rst_n,

    // CSR output
    output  reg [31:0]  start,
    input   reg [31:0]  acc_done,
    output  reg [31:0]  input_base,
    output  reg [31:0]  output_base,

    // usram interface
    output  reg [31:0]  usram_addr,
    output  reg [63:0]  usram_wdata,
    output  reg         usram_write_en,
    input   [63:0]      usram_rdata
);

wire is_low_part;
wire icb_write_en;
wire usram_sel;
reg  [31:0] done;

// [------------------------------- addr decoder -------------------------------]
//assign usram_addr = {16'b0,icb_cmd_addr[18:3]} - 'ha000;    // usram width 64 bit = 8 byte -> low 3 bits for byte offset
always@(posedge clk)
begin
    if(!rst_n) begin
        usram_addr <= 1'b0;
    end
	else begin
		usram_addr <= {16'b0,icb_cmd_addr[18:3]} - 'ha000;
	end
end

assign is_low_part = (icb_cmd_addr[2] == 1'b0);
assign icb_write_en = icb_cmd_valid & icb_cmd_ready & !icb_cmd_read;
assign usram_sel = (usram_addr >= 'h0000 && usram_addr < 'h4000);
reg is_low_part_reg;

// [------------------------------- icb -------------------------------]
assign icb_rsp_err = 1'b0;

always@(posedge clk)
begin
    is_low_part_reg <= is_low_part;
end
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
            case(icb_cmd_addr[19:0])
                `START:  start <= icb_cmd_wdata;
                `DONE:  done <= icb_cmd_wdata;
                `INPUT_BASE:  input_base <= icb_cmd_wdata;
                `OUTPUT_BASE: output_base <= icb_cmd_wdata;
            endcase
        end
        else if (acc_done) begin
            start <= 32'b0;
            done <= 32'h1;
            input_base <= 32'b0;
            output_base <= 32'b0;
        end else begin
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
reg [31:0] icb_rsp_rdata_reg;

always@(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_rdata_reg <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & icb_cmd_read) begin
            case(icb_cmd_addr[19:0])
                `START:  icb_rsp_rdata_reg <= start;
                `DONE:  icb_rsp_rdata_reg <= done;
                `INPUT_BASE:  icb_rsp_rdata_reg <= input_base;
                `OUTPUT_BASE: icb_rsp_rdata_reg <= output_base;
                default: begin
                    icb_rsp_rdata_reg <= 32'h0;         // default return 0
                end
            endcase
        end
        else begin
            icb_rsp_rdata_reg <= 32'h0;
        end
    end
end

assign icb_rsp_rdata = usram_sel ? 
                        (is_low_part_reg ? usram_rdata[63:32] : usram_rdata[31:0]) :  // read usram data
                        icb_rsp_rdata_reg;  // read CSR data

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
