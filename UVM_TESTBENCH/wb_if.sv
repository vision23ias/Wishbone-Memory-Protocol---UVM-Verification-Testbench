interface wb_if(input logic clk,input logic rst);
  logic start_req_i;
  logic done_o;
  logic [31:0] ADR_I;
  logic [31:0] DAT_O;
  logic WE_I;
  logic STB_I;
  logic CYC_I;
  logic [2:0] CTI_I;
  logic [1:0] BTE_I;
  logic [31:0] DAT_I;
  logic [31:0] reg_ctrl_i;
  logic [31:0] reg_addr_i;
  logic [31:0] wr_data_i;
  logic ACK_O;
  logic ERR_O;
  logic RTY_O;
  logic busy_o;
  logic err_i;
  logic [31:0] rd_data_o;
  clocking master_cb @(posedge clk);
    // Driven by driver
    output start_req_i;
    output reg_addr_i;
    output wr_data_i;
    output reg_ctrl_i;

    // Sampled by driver
    input done_o;
    input busy_o;
    input err_i;
  endclocking
  clocking slave_cb @(posedge clk);
     // Observe master requests
    input ADR_I;
    input DAT_O;
    input WE_I;
    input STB_I;
    input CYC_I;
    input CTI_I;
    input BTE_I;

  // Drive slave responses
    output DAT_I;
    output ACK_O;
    output ERR_O;
    output RTY_O;
  endclocking
 modport MASTER(
  input  clk,
  input  rst,

  input  done_o,
  input  busy_o,
  input  err_i,

  output start_req_i,
  output reg_ctrl_i,
  output reg_addr_i,
  output wr_data_i
);
 modport SLAVE(
  input clk,
  input rst,

  input ADR_I,
  input DAT_O,
  input WE_I,
  input STB_I,
  input CYC_I,
  input CTI_I,
  input BTE_I,

  output DAT_I,
  output ACK_O,
  output ERR_O,
  output RTY_O
);
endinterface

  
  
  
  
  
