class wb_sequencer extends uvm_sequencer #(wb_txn);
  `uvm_component_utils(wb_sequencer)
  function new(string name="wb_master_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
endclass
