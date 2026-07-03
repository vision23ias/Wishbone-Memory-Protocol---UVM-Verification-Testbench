class wb_master_seq extends uvm_sequence #(wb_txn);
  `uvm_object_utils(wb_master_seq)
  wb_txn tx;
  rand bit [31:0] base_addr;
  rand int burst_len;
  function new(string name="wb_master_seq");
    super.new(name);
  endfunction
  task body();
    `uvm_info("MASTER_SEQ",
            "MASTER SEQUENCE STARTED",
            UVM_NONE)
    base_addr=32'h1000;
    burst_len=8;
    repeat(burst_len) begin
      tx=wb_txn::type_id::create("tx");
      start_item(tx);
      tx.addr=base_addr;
      tx.data=$random;
      tx.we=1'b1;
      tx.cti=3'b010;
      tx.bte=2'b00;
      finish_item(tx);
      base_addr=base_addr+4;
    end
    tx=wb_txn::type_id::create("tx");
    start_item(tx);
    tx.addr=base_addr;
    tx.data=$random;
    tx.we=1'b1;
    tx.cti=3'b111;
    tx.bte=2'b00;
    finish_item(tx);
  endtask
endclass
