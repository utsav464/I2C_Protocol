# I2C Controller (Inter-Integrated Circuit)

## Overview
This project implements an I2C (Inter-Integrated Circuit) communication protocol using Verilog HDL. The design includes both I2C Master and I2C Slave modules with support for serial data communication over SDA and SCL lines.

The controller supports I2C write transactions, START/STOP condition generation, ACK/NACK handling, and slave address matching. The design was verified using Verilog testbenches and tested on FPGA hardware for write transactions.

---

## Features
- I2C Master Design
- I2C Slave Design
- Serial Communication using SDA and SCL
- START and STOP Condition Generation
- ACK and NACK Handling
- Slave Address Detection
- Bidirectional Data Transfer
- Verilog RTL Design
- Vivado Simulation Verification
- FPGA Hardware Testing for Write Transactions

---

## I2C Interface Signals

| Signal | Description |
|--------|-------------|
| SDA | Serial Data Line |
| SCL | Serial Clock Line |

---

## I2C Communication Process

### Write Transaction
1. Master generates START condition.
2. Slave address is transmitted.
3. Slave sends ACK signal.
4. Master transmits data through SDA.
5. Slave acknowledges received data.
6. Master generates STOP condition.

---

## START and STOP Conditions

### START Condition
- SDA transitions from HIGH to LOW while SCL remains HIGH.

### STOP Condition
- SDA transitions from LOW to HIGH while SCL remains HIGH.

---

## ACK/NACK Handling

### ACK
- Receiver pulls SDA LOW during acknowledgment clock pulse.

### NACK
- SDA remains HIGH during acknowledgment clock pulse.

---

## Project Structure

```text
├── rtl/
│   ├── I2C_slave.v
│   ├── I2c_master.v
│   └── top.v
│
├── testbench/
│   └── tb.v
│
├── simulation/
│   └── waveform.png
│
└── README.md
