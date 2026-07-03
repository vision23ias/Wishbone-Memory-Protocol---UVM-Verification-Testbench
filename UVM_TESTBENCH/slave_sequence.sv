class slave_sequence extends uvm_sequence #(wb_txn);
  `uvm_object_utils(slave_sequence)
  function new(string name = "slave_sequence");
    super.new(name);
  endfunction
  task body();
    wb_txn rsp;
    repeat(1000) begin
    rsp=wb_txn::type_id::create("rsp");
    start_item(rsp);
    rsp.data=32'hDEADBEEF;
    finish_item(rsp);
    end
  endtask
endclass
