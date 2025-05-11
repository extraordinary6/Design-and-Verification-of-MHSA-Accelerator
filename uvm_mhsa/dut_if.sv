//=====================================================================
// Description:
// DUT interface
// Designer : Huang Chaofan, extraordinary.h@sjtu.edu.cn
// Revision History:
// V0 date: 4.2 Initial version, Huang Chaofan
// ====================================================================

`timescale 1ns/1ps

interface dut_if(
  input logic        clk,
  input logic        rst_n
);
  
  logic              done;
  logic              start;
  logic [31:0]       input_base;
  logic [31:0]       output_base;
  logic              soc_write_en;
  logic [63:0]       soc_data_in;
  logic [31:0]       soc_addr;
  logic [63:0]       soc_data_out;

  clocking mst_cb @(posedge clk);
    default input #1ns output #1ns;
    
    input  done;
    output start;
    output input_base;
    output output_base;
    output soc_write_en;
    output soc_data_in;
    output soc_addr;
    input  soc_data_out;
  endclocking : mst_cb

  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    
    input  done;
    input  start;
    input  input_base;
    input  output_base;
    input  soc_write_en;
    input  soc_data_in;
    input  soc_addr;
    input  soc_data_out;
  endclocking : mon_cb

  // modport
  modport slave (
  input  clk,
  input  rst_n,

  output done,
  input  start,
  input  input_base,
  input  output_base,
  input  soc_write_en,
  input  soc_data_in,
  input  soc_addr,
  output soc_data_out
  );

  modport master (
  clocking mst_cb,
  input  clk,
  input  rst_n,

  input  done,
  output start,
  output input_base,
  output output_base,
  output soc_write_en,
  output soc_data_in,
  output soc_addr,
  input  soc_data_out
  );

  modport others (
  clocking mon_cb,
  input  clk,
  input  rst_n,

  input  done,
  input  start,
  input  input_base,
  input  output_base,
  input  soc_write_en,
  input  soc_data_in,
  input  soc_addr,
  input  soc_data_out
  );

endinterface : dut_if

  