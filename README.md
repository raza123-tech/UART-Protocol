UART Protocol Implementation on FPGA (Verilog)
 Overview

This project implements a complete UART (Universal Asynchronous Receiver–Transmitter) communication system in Verilog, suitable for FPGA deployment as well as simulation-based verification.

The design includes:

UART Transmitter

UART Receiver with ×4 oversampling

Self-checking testbenches for transmitter and receiver

End-to-end UART verification using different clocks

Ready for FPGA testing with Tera Term

 Key Features

Fully parameterized design (clock & baud rate configurable)

UART frame format: 1 Start bit + 8 Data bits + 1 Stop bit

Receiver with ×4 oversampling for better noise tolerance

Independent transmitter and receiver clocks

Memory-based data loading

Suitable for FPGA and RTL simulation

 Specifications
Parameter	Value (Default)
Clock Frequency	100 MHz
Baud Rate	9600 bps
Receiver Oversampling	×4
Data Width	8 bits (1 byte)
FPGA Board	Xilinx Spartan-7 (Edge)
Terminal Software	Tera Term
 Project Structure
UART_PROTOCOL/
│
├── transmitter.sv        # UART transmitter module
├── receiver.sv           # UART receiver with oversamplin
├── mem.txt               # Memory file (1 byte: 1000_0001)
│
├── Testbench/
│   ├── receiver.sv       # Receiver testbench
│   └── transmitter.sv    # Transmitter testbench
│
├── top.sv                # Self-checking testbench (TX + RX, different clocks)
└── README.md             # Project documentation

 Module Descriptions
 UART Transmitter (transmitter.sv)

Converts 8-bit parallel data into a serial UART stream.

Frame Format

Start Bit (0) → 8 Data Bits (LSB first) → Stop Bit (1)


Parameters

CLK_FREQ – System clock frequency (default: 100 MHz)

BAUD_RATE – UART baud rate (default: 9600)

Outputs

txd – Serial transmit line

busy – High during transmission

 UART Receiver (receiver.sv)

Receives serial UART data using ×4 oversampling and reconstructs the original byte.

Parameters

CLK_FREQ – System clock frequency (default: 100 MHz)

BAUD_RATE – UART baud rate (default: 9600)

DIV_SAMPLE – Oversampling factor (default: 4)

Outputs

rxddata – Received 8-bit data

rdone – Pulses high when a byte is successfully received

 Data Flow
Transmitter
Parallel Data → Shift Register → UART Frame → txd

Receiver
rxd → Oversampling → Bit Recovery → Byte Assembly → rxddata

Diagram
<img width="640" height="437" alt="image" src="https://github.com/user-attachments/assets/feec3b37-ee2a-4039-9ffb-2bd73a30e3a2" />

 Parameter Overview
Parameter	Module	Description	Default
CLK_FREQ	TX, RX	System clock frequency (Hz)	100_000_000
BAUD_RATE	TX, RX	UART baud rate	9600
DIV_SAMPLE	RX	Oversampling factor	4
WIDTH	Memory	Data width (bits)	8
 Simulation & Verification

Individual testbenches for transmitter and receiver

top.sv performs end-to-end UART verification

Self-checking logic ensures correct data reception

Supports different clock domains for TX and RX

 FPGA & Hardware Testing

Synthesizable on Xilinx Spartan-7

UART output can be monitored using Tera Term

Ideal for hardware protocol verification

 Applications

FPGA-based UART debugging

Embedded systems training

Digital communication learning

RTL design and verification practice

Interview and academic projects

