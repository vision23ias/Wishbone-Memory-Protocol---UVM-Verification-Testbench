class wb_master_driver extends uvm_driver #(wb_txn);

  `uvm_component_utils(wb_master_driver)

  virtual wb_if vif;
  wb_txn tx;

  function new(string name = "wb_master_driver",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual wb_if)::get(
         this,"","vif",vif))
      `uvm_fatal("NOVIF",
        "MASTER DRIVER VIF NOT FOUND")
  endfunction


  task run_phase(uvm_phase phase);

    reset_signals();

    forever begin

      seq_item_port.get_next_item(tx);
       `uvm_info("MASTER_DRIVER",
            "GOT TRANSACTION",
            UVM_NONE)

      drive_transfer(tx);

      seq_item_port.item_done();

    end

  endtask


  task reset_signals();

   vif.start_req_i <= 0;
   vif.reg_addr_i  <= 0;
   vif.wr_data_i   <= 0;
   vif.reg_ctrl_i  <= 0;

 endtask


  task drive_transfer(wb_txn tx);

    @(posedge vif.clk);
      `uvm_info("MASTER_DRV","Driving transaction",UVM_NONE)
        vif.reg_addr_i <= tx.addr;
        vif.wr_data_i  <= tx.data;
        vif.reg_ctrl_i <= '0;

        vif.reg_ctrl_i[2:0]   <= tx.cti;
        vif.reg_ctrl_i[4:3]   <= tx.bte;
        vif.reg_ctrl_i[5]     <= tx.we;
        vif.reg_ctrl_i[15:6]  <= 1;     // req_num
        vif.reg_ctrl_i[23:16] <= 1;     // burst_len

     
     `uvm_info("MASTER_DRIVER",
            "ASSERTING start_req_i",
            UVM_NONE)


    vif.master_cb.start_req_i <= 1'b1;
    `uvm_info("DRV","Got transaction",UVM_NONE)

    repeat(2) @(posedge vif.clk);
    `uvm_info("DRV","Driving start_req_i",UVM_NONE)


    vif.master_cb.start_req_i <= 0;
      `uvm_info("MASTER_DRV","Waiting for done_o",UVM_NONE)


    // wait till master finishes transfer
   fork
   begin
     while(!vif.done_o)
       @(posedge vif.clk);
   end

   begin
     repeat(100) @(posedge vif.clk);
      `uvm_fatal("MASTER_DRV",
               "Timeout waiting for done_o");
  end
  join_any

  disable fork;

    if(!tx.we)
      tx.data = vif.DAT_I;

    `uvm_info("MASTER_DRIVER",
      $sformatf(
      "MASTER TXN addr=%h data=%h we=%0d",
      tx.addr,
      tx.data,
      tx.we),
      UVM_MEDIUM)

  endtask

endclass
