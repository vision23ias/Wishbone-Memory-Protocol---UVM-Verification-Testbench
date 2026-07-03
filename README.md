# Wishbone-Memory-Protocol---UVM-Verification-Testbench

## Overview

This project implements a complete UVM-based verification environment for a Wishbone Memory Protocol design. The objective is to verify the functionality of a Wishbone Master communicating with a Wishbone Slave using reusable UVM components and a layered verification architecture.

The project includes custom RTL for the Wishbone Master and Wishbone Slave along with a complete UVM testbench consisting of sequences, drivers, monitors, scoreboards, agents, environment, and reference model.

---

## Features

- Wishbone Master RTL
- Wishbone Slave RTL (Memory Model)
- UVM Transaction Class
- Master and Slave Sequences
- Master and Slave Drivers
- Master and Slave Monitors
- Master and Slave Agents
- Master and Slave Scoreboards
- Reference Model
- UVM Environment
- Burst Write Transaction Support
- Address, Data and Control Signal Verification
- End-to-End Transaction Checking

---

## Project Structure

```
Design
│
├── wishbone_master.sv
└── wishbone_slave.sv

Verification
│
├── wb_txn.sv
├── master_sequence.sv
├── slave_sequence.sv
├── wb_sequencer.sv
├── wb_slave_sequencer.sv
├── wb_master_driver.sv
├── wb_slave_driver.sv
├── wb_mon_master.sv
├── wb_mon_slave.sv
├── wb_master_scoreboard.sv
├── wb_slave_scoreboard.sv
├── wb_reference_model.sv
├── wb_master_agent.sv
├── wb_slave_agent.sv
├── wb_env.sv
├── wb_test.sv
├── wb_if.sv
├── wb_pkg.sv
└── testbench.sv
```

---

## Verification Architecture

```
Sequence
    │
    ▼
Sequencer
    │
    ▼
Driver
    │
    ▼
Wishbone Master RTL
    │
Wishbone Bus
    │
Wishbone Slave RTL
    │
    ▼
Monitors
    │
    ▼
Reference Model
    │
    ▼
Scoreboards
```

---

## Verification Flow

1. The master sequence generates Wishbone transactions.
2. The master driver applies transactions to the DUT.
3. The Wishbone Master initiates bus transfers.
4. The Wishbone Slave responds with acknowledgements and data.
5. Master and Slave monitors capture bus activity.
6. The reference model generates expected results.
7. The scoreboards compare expected and actual transactions.
8. Any mismatch is reported using UVM messaging.

---

## Supported Transactions

- Single Write
- Single Read
- Incrementing Burst Transfers
- End-of-Burst Detection
- Address Alignment Checking
- Memory Read/Write Verification

---

## UVM Components Used

| Component | Purpose |
|-----------|---------|
| Transaction | Defines Wishbone packet fields |
| Sequence | Generates stimulus |
| Sequencer | Sends transactions to driver |
| Driver | Drives DUT interface |
| Monitor | Captures DUT activity |
| Scoreboard | Verifies transaction correctness |
| Reference Model | Generates expected outputs |
| Agent | Groups driver, monitor and sequencer |
| Environment | Connects all verification components |
| Test | Runs verification scenarios |

---

## Tools Used

- SystemVerilog
- Universal Verification Methodology (UVM 1.2)
- EDA Playground
- Riviera-PRO Simulator

---

## Future Improvements

- Functional Coverage
- Constrained Random Testing
- Multiple Burst Types
- Error and Retry Transaction Verification
- Regression Test Suite

---

## Contributors

### Shri Ram Lakshmi Narasimhan - 20234511
### Anuj Deep - 20234503

---

## License

This project is intended for educational and learning purposes.
