`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class wb_slave_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(
    wb_slave_scoreboard)

  uvm_analysis_imp_expected
    #(wb_txn,
      wb_slave_scoreboard)
      expected_imp;

  uvm_analysis_imp_actual
    #(wb_txn,
      wb_slave_scoreboard)
      actual_imp;

  wb_txn expected_q[$];
  wb_txn actual_q[$];

  function new(string name =
               "wb_slave_scoreboard",
               uvm_component parent =
               null);

    super.new(name,parent);

    expected_imp =
      new("expected_imp",this);

    actual_imp =
      new("actual_imp",this);

  endfunction


  function void write_expected(
    wb_txn tx);

    wb_txn temp;

    temp =
      wb_txn::type_id::create(
      "temp");

    temp.copy(tx);

    expected_q.push_back(
      temp);

    compare();

  endfunction


  function void write_actual(
    wb_txn tx);

    wb_txn temp;

    temp =
      wb_txn::type_id::create(
      "temp");

    temp.copy(tx);

    actual_q.push_back(
      temp);

    compare();

  endfunction


 function void compare();

  wb_txn exp_tx;
  wb_txn act_tx;

  if(expected_q.size() == 0 ||
     actual_q.size()   == 0)
    return;

  exp_tx = expected_q.pop_front();
  act_tx = actual_q.pop_front();

  // Address check
  if(exp_tx.addr != act_tx.addr)
    `uvm_error(
      "SLAVE_SB",
      $sformatf(
        "ADDR mismatch exp=%h act=%h",
        exp_tx.addr,
        act_tx.addr))

  // Data check
  if(exp_tx.data != act_tx.data)
    `uvm_error(
      "SLAVE_SB",
      $sformatf(
        "DATA mismatch exp=%h act=%h",
        exp_tx.data,
        act_tx.data))

  // Write enable check
  if(exp_tx.we != act_tx.we)
    `uvm_error(
      "SLAVE_SB",
      $sformatf(
        "WE mismatch exp=%0d act=%0d",
        exp_tx.we,
        act_tx.we))

  // Success only if everything matches
  if((exp_tx.addr == act_tx.addr) &&
     (exp_tx.data == act_tx.data) &&
     (exp_tx.we   == act_tx.we))
  begin
    `uvm_info(
      "SLAVE_SB",
      $sformatf(
        "Transaction matched addr=%h data=%h we=%0d",
        act_tx.addr,
        act_tx.data,
        act_tx.we),
      UVM_MEDIUM)
  end
   `uvm_info("EXP",
  $sformatf("EXP addr=%h data=%h we=%0d",
            exp_tx.addr,
            exp_tx.data,
            exp_tx.we),
  UVM_MEDIUM)

`uvm_info("ACT",
  $sformatf("ACT addr=%h data=%h we=%0d",
            act_tx.addr,
            act_tx.data,
            act_tx.we),
  UVM_MEDIUM)

endfunction

endclass
