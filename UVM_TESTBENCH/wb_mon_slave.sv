class wb_mon_slave extends uvm_monitor;
  `uvm_component_utils(wb_mon_slave)
  virtual wb_if vif;
  uvm_analysis_port #(wb_txn) mon_ap;
  wb_txn tx;
  function new(string name = "wb_mon_slave",
               uvm_component parent = null);

    super.new(name,parent);

    mon_ap = new("mon_ap", this);

  endfunction
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(virtual wb_if)::get(
         this,"","vif",vif))
    begin
      `uvm_fatal("NOVIF",
        "SLAVE MONITOR VIF NOT FOUND")
    end

  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk iff (vif.CYC_I && vif.STB_I && vif.ACK_O));

       tx = wb_txn::type_id::create("tx");
       tx.addr = vif.ADR_I;
       tx.we   = vif.WE_I;
       if(vif.WE_I) begin
          tx.data = vif.DAT_O;
       end
       else begin

        wait(vif.ACK_O);

        tx.data = vif.DAT_I;

       end
       mon_ap.write(tx);
       `uvm_info("SLAVE_MONITOR",
        $sformatf(
        "SLAVE TXN addr=%h data=%h we=%0d",
        tx.addr,
        tx.data,
        tx.we),
        UVM_MEDIUM)
      @(posedge vif.clk);

    end

  endtask

endclass

