class wb_txn extends uvm_sequence_item;

  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        we;
  rand bit [2:0]  cti;
  rand bit [1:0]  bte;

  constraint cti_c {
    cti inside {3'b000,3'b001,3'b010,3'b111};
  }

  `uvm_object_utils_begin(wb_txn)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
    `uvm_field_int(we,UVM_ALL_ON)
    `uvm_field_int(cti,UVM_ALL_ON)
    `uvm_field_int(bte,UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="wb_txn");
    super.new(name);
  endfunction

endclass
