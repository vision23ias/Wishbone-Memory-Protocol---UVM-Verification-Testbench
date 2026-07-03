class wb_mon_master extends uvm_monitor;
  `uvm_component_utils(wb_mon_master)
  virtual wb_if vif;
  uvm_analysis_port #(wb_txn) mon_ap;
  wb_txn tx;
  function new(string name="wb_mon_master",uvm_component parent=null);
    super.new(name,parent);
    mon_ap=new("mon_ap",this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual wb_if)::get(this,"","vif",vif))
      begin
        `uvm_fatal("NO_VIF","MASTER MONITOR VIF NOT FOUND")
      end
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      wait(vif.start_req_i) begin
        tx=wb_txn::type_id::create("tx");
        tx.addr = vif.reg_addr_i;
        tx.data = vif.wr_data_i;
        tx.cti = vif.reg_ctrl_i[2:0];
        tx.bte = vif.reg_ctrl_i[4:3];
        tx.we  = vif.reg_ctrl_i[5];
        wait(vif.done_o);
        if(!tx.we)
          tx.data=vif.rd_data_o;
          mon_ap.write(tx);
          `uvm_info("Master_Monitor",
                    $sformatf("MONITOR TXN addr=%h data=%h we=%0d",
                               tx.addr,
                               tx.data,
                               tx.we),
                    UVM_MEDIUM)
      end
    end
  endtask
endclass
