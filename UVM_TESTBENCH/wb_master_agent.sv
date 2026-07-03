class wb_master_agent extends uvm_agent;
  `uvm_component_utils(wb_master_agent)
  wb_master_driver drv;
  wb_mon_master mon;
  wb_sequencer seqr;
  function new(string name="wb_master_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=wb_master_driver::type_id::create("drv",this);
    mon=wb_mon_master::type_id::create("mon",this);
    seqr=wb_sequencer::type_id::create("seqr",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
  
    
  
