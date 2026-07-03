`include "wb_if.sv"

package pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // Base transaction
  `include "wb_txn.sv"

  // Sequences
  `include "master_sequence.sv"
  `include "slave_sequence.sv"

  // Sequencers
  `include "wb_sequencer.sv"
  `include "wb_slave_sequencer.sv"

  // Drivers
  `include "wb_master_driver.sv"
  `include "wb_slave_driver.sv"

  // Monitors
  `include "wb_mon_master.sv"
  `include "wb_mon_slave.sv"

  // Reference model
  `include "wb_reference_model.sv"

  // Scoreboards
  `include "wb_master_scoreboard.sv"
  `include "wb_slave_scoreboard.sv"

  // Agents
  `include "wb_master_agent.sv"
  `include "wb_slave_agent.sv"

  // Environment
  `include "wb_env.sv"

  // Test
  `include "wb_test.sv"

endpackage
