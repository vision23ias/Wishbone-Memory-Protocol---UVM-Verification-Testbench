class wb_reference_model extends uvm_component;

  `uvm_component_utils(wb_reference_model)

  uvm_analysis_imp #(wb_txn,
                     wb_reference_model) ref_port;

  uvm_analysis_port #(wb_txn) expected_port;

  bit [31:0] mem [256];

  function new(string name = "wb_reference_model",
               uvm_component parent = null);

    super.new(name, parent);

    ref_port = new("ref_port", this);
    expected_port = new("expected_port", this);

  endfunction


  function void write(wb_txn tx);

    wb_txn exp_tx;
    int index;

    exp_tx =
      wb_txn::type_id::create("exp_tx");

    exp_tx.copy(tx);

    index = tx.addr[9:2];

    if(tx.we)
      mem[index] = tx.data;
    else
      exp_tx.data = mem[index];

    expected_port.write(exp_tx);

  endfunction

endclass
