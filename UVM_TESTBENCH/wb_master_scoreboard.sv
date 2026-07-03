class wb_master_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(wb_master_scoreboard)

  uvm_analysis_imp #(wb_txn,
                     wb_master_scoreboard)
                     sb_port;

  function new(string name =
               "wb_master_scoreboard",
               uvm_component parent = null);

    super.new(name, parent);

    sb_port =
      new("sb_port", this);

  endfunction


  function void write(wb_txn tx);

    if(tx.addr === 'x)
      `uvm_error("MASTER_SB",
        "Address contains X")

    if(tx.data === 'x)
      `uvm_error("MASTER_SB",
        "Data contains X")

    if(tx.we !== 0 &&
       tx.we !== 1)
      `uvm_error("MASTER_SB",
        "Invalid WE signal")

    if(!(tx.cti inside
      {3'b000,3'b001,
       3'b010,3'b111}))
      `uvm_error("MASTER_SB",
        $sformatf(
        "Invalid CTI = %0d",
        tx.cti))

    if(!(tx.bte inside
      {2'b00,2'b01,
       2'b10,2'b11}))
      `uvm_error("MASTER_SB",
        $sformatf(
        "Invalid BTE = %0d",
        tx.bte))

    `uvm_info("MASTER_SB",
      $sformatf(
      "Master txn addr=%h data=%h we=%0d",
      tx.addr,
      tx.data,
      tx.we),
      UVM_MEDIUM)

  endfunction

endclass
