class wb_slave_driver extends uvm_driver #(wb_txn);

  `uvm_component_utils(wb_slave_driver)

  virtual wb_if vif;
  wb_txn tx;

  function new(string name="wb_slave_driver",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual wb_if)::get(
         this,"","vif",vif))
      `uvm_fatal("NOVIF",
        "SLAVE DRIVER VIF NOT FOUND")
  endfunction


  task run_phase(uvm_phase phase);

    reset_signals();

    forever begin

      seq_item_port.get_next_item(tx);

      respond_transfer(tx);

      seq_item_port.item_done();

    end

  endtask


  task reset_signals();

    vif.ACK_O <= 0;
    vif.DAT_I <= 0;
    vif.ERR_O <= 0;
    vif.RTY_O <= 0;

  endtask


  task respond_transfer(wb_txn tx);
    `uvm_info("SLAVE","Waiting for request",UVM_NONE)
     `uvm_info("SLAVE_DRV",
            "Waiting for CYC_I && STB_I",
            UVM_NONE)

    // wait till master requests
    wait(vif.CYC_I && vif.STB_I);
    `uvm_info("SLAVE_DRV",
   $sformatf("REQ DETECTED: CYC=%0b STB=%0b ACK=%0b ADR=%h",
          vif.CYC_I,
          vif.STB_I,
          vif.ACK_O,
          vif.ADR_I),
    UVM_NONE)
     `uvm_info("SLAVE_DRV",
               $sformatf("WE_I=%0b ADR_I=%h DAT_O=%h",
              vif.WE_I,
              vif.ADR_I,
              vif.DAT_O),
    UVM_NONE)
      `uvm_info("SLAVE_DRV",
            "Request detected",
            UVM_NONE)

    @(posedge vif.clk);

    //--------------------------------
    // WRITE RESPONSE
    //--------------------------------
    if(vif.WE_I) begin

      tx.addr = vif.ADR_I;
      tx.data = vif.DAT_O;
      tx.we   = 1;
      @(posedge vif.clk);

      vif.ACK_O <= 1'b1;

      @(posedge vif.clk);

      vif.ACK_O <= 0;

      `uvm_info("SLAVE_DRIVER",
        $sformatf(
        "WRITE addr=%h data=%h",
        tx.addr,
        tx.data),
        UVM_MEDIUM)

    end

    //--------------------------------
    // READ RESPONSE
    //--------------------------------
    else begin

      vif.DAT_I <= tx.data;
      vif.ACK_O <= 1'b1;

      @(posedge vif.clk);

      vif.ACK_O <= 0;

      `uvm_info("SLAVE_DRIVER",
        $sformatf(
        "READ RESPONSE data=%h",
        tx.data),
        UVM_MEDIUM)

    end

  endtask

endclass
