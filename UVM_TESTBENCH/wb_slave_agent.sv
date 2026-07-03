class wb_slave_agent extends uvm_agent;
  `uvm_component_utils(wb_slave_agent)
  wb_slave_driver drv;
  wb_mon_slave mon;
  wb_slave_sequencer seqr;
  function new(string name="wb_slave_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=wb_slave_driver::type_id::create("drv",this);
    mon=wb_mon_slave::type_id::create("mon",this);
    seqr=wb_slave_sequencer::type_id::create("seqr",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
