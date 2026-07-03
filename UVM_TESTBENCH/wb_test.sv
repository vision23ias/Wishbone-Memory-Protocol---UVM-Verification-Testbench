class wb_test extends uvm_test;
  `uvm_component_utils(wb_test)
  wb_env env;
  wb_master_seq mseq;
  function new(string name="wb_test",uvm_component parent=null);
     super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     env = wb_env::type_id::create("env",this);
  endfunction
task run_phase(uvm_phase phase);

  slave_sequence sseq;

  phase.raise_objection(this);

  sseq = slave_sequence::type_id::create("sseq");
  mseq = wb_master_seq::type_id::create("mseq");
 

  // Start slave responder in background
  fork
    sseq.start(env.slave_agent.seqr);
  join_none

  // Run master sequence and wait for it to finish
  mseq.start(env.master_agent.seqr);

  phase.drop_objection(this);

endtask
endclass

   
