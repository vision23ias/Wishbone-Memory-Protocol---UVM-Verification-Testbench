`include "uvm_macros.svh"
`include "wb_pkg.sv"
import uvm_pkg::*;
import pkg::*;
module top;
  logic clk;
  logic rst;
  wb_if vif(clk,rst);
  logic [31:0] reg_ctrl;
  logic [31:0] reg_addr;
  logic [31:0] wr_data;
  logic [31:0] rd_data;
  logic busy;
  logic done;
  logic error;
  logic [31:0] read_count;
  logic [31:0] write_count;
  logic [31:0] error_count;
  logic [31:0] retry_count;
  wishbone_master dut(

    //------------------------------------------------
    // Clock / Reset
    //------------------------------------------------
    .clk_i(clk),
    .rst_n(~rst),

    //------------------------------------------------
    // Control Interface
    //------------------------------------------------
    .start_req_i(vif.start_req_i),

    .reg_ctrl_i(vif.reg_ctrl_i),
    .reg_addr_i(vif.reg_addr_i),

    .wr_data_i(vif.wr_data_i),

    .rd_data_o(vif.rd_data_o),

    .busy_o(vif.busy_o),
    .done_o(vif.done_o),
    .error_o(vif.err_i),

    //------------------------------------------------
    // Wishbone Bus
    //------------------------------------------------
    .dat_i(vif.DAT_I),

    .adr_o(vif.ADR_I),
    .dat_o(vif.DAT_O),

    .sel_o(),

    .we_o(vif.WE_I),
    .stb_o(vif.STB_I),
    .cyc_o(vif.CYC_I),

    .ack_i(vif.ACK_O),
    .err_i(vif.ERR_O),
    .rty_i(vif.RTY_O),

    .cti_o(vif.CTI_I),
    .bte_o(vif.BTE_I),

    //------------------------------------------------
    // Statistics
    //------------------------------------------------
    .read_count_o(read_count),
    .write_count_o(write_count),
    .error_count_o(error_count),
    .retry_count_o(retry_count)

 );
  
  initial begin
    clk=0;
    forever #5 clk=~clk;
  end
  initial begin
    rst=1;
    #20;
    rst=0;
  end
  initial begin
    uvm_config_db #(virtual wb_if)::set(
      null,
      "*",
      "vif",
      vif
    );

  end
  initial begin
    run_test("wb_test");
  end
  initial begin
    #5000;
    $display("SIMULATION TIMEOUT");
    $finish;
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end
endmodule
   
