class wb_env extends uvm_env;

  `uvm_component_utils(wb_env)

  wb_master_agent master_agent;
  wb_slave_agent  slave_agent;

  wb_master_scoreboard master_sb;
  wb_slave_scoreboard  slave_sb;

  wb_reference_model ref_model;

  function new(string name =
               "wb_env",
               uvm_component parent =
               null);

    super.new(name,parent);

  endfunction


  function void build_phase(
    uvm_phase phase);

    super.build_phase(
      phase);

    master_agent =
      wb_master_agent::
      type_id::create(
      "master_agent",
      this);

    slave_agent =
      wb_slave_agent::
      type_id::create(
      "slave_agent",
      this);

    master_sb =
      wb_master_scoreboard::
      type_id::create(
      "master_sb",
      this);

    slave_sb =
      wb_slave_scoreboard::
      type_id::create(
      "slave_sb",
      this);

    ref_model =
      wb_reference_model::
      type_id::create(
      "ref_model",
      this);

  endfunction


  function void connect_phase(
    uvm_phase phase);

    super.connect_phase(
      phase);

    master_agent.mon.mon_ap
      .connect(
      master_sb.sb_port);

    master_agent.mon.mon_ap
      .connect(
      ref_model.ref_port);

    ref_model.expected_port
      .connect(
      slave_sb.expected_imp);

    slave_agent.mon.mon_ap
      .connect(
      slave_sb.actual_imp);

  endfunction

endclass
