# UART_PROTOCOL
UART Protocol Implementation with Shared Memory in Verilog

# Overview
This project is a complete UART communication system written in Verilog, designed for FPGA or simulation-based testing.
It includes:
UART Transmitter
UART Receiver with oversampling
Button Debouncing
Shared Memory for TX–RX data storage
Loopback testbench for verification

# Key Specs
Clock Frequency: 1 MHz (configurable)
Baud Rate: 9600 bps (configurable)
Receiver Oversampling: ×4
Memory Depth: 16 bytes

 # Project Structure
UART_PROTOCOL/

│

├── transmitter.sv     # UART transmitter

├── receiver.sv        # UART receiver with oversampling

├── debouncing.sv      # Debounces button press to avoid false triggers

├── shared_mem.sv      # Shared synchronous memory

├── topmodule.sv       # Integrates all modules

└── tb_uart_shared.sv  # Self-checking loopback testbench

# Module Descriptions
1. Transmitter (transmitter.sv)
Converts 8-bit parallel data into serial UART format.
Frame: 1 Start bit → 8 Data bits → 1 Stop bit.
Parameters:
CLK_FREQ (default 1 MHz)
BAUD_RATE (default 9600 bps)
 Outputs:
txd: Serial data line
tx_done: Transmission complete flag

2. Receiver (receiver.sv)
Receives UART serial data with ×4 oversampling.
Assembles bits into an 8-bit data word.
Parameters:
CLK_FREQ (default 1 MHz)
BAUD_RATE (default 9600)
DIV_SAMPLE (default 4)
Outputs:
rxddata: Received byte
data_ready: High when a full byte is received

3. Debouncing (debouncing.sv)
Cleans noisy mechanical button input.
Outputs a stable transmit signal when the button is pressed.
Parameter:
THRESHOLD: Number of stable clock cycles required.

4. Shared Memory (shared_mem.sv)
Synchronous single-port RAM for TX–RX data storage.
Parameters:
WIDTH – Data width (default: 8 bits)
DEPTH – Memory depth (default: 16 bytes)
ADDR_WIDTH – Address width (default: 4 bits)

5. Top Module (topmodule.sv)
Connects:
Button → Debouncer → Transmitter
TX output → Receiver
TX and RX → Shared Memory
Controls memory writes when TX completes and reads when RX has data ready.

# Data Flow Diagram
<img width="1536" height="1024" alt="4c746bb5-c842-44bb-ac91-ff853dc19113" src="https://github.com/user-attachments/assets/6fce821d-c0d1-44b5-8672-111839b44dee" />

# Testbench (tb_uart_shared.sv)
Clock generation: 1 MHz
Loopback mode: TX output connected to RX input
Test pattern: {0x55, 0xA5, 0x00, 0xFF}
Self-checking: Compares sent and received bytes
Timeout detection for TX and RX stages
Dumps waveform to uart_iv.vcd

# Sample Output:
TB: TX done for byte 0: 55 at time 123400 ns
PASS: Sent 55, Received 55 (time 145600 ns)
TB: TX done for byte 1: A5 at time 300000 ns
PASS: Sent A5, Received A5 (time 322200 ns)
All tests finished at time 600000 ns

# Parameters Overview
Parameter	Module	Description	Default
CLK_FREQ	TX, RX	System clock frequency (Hz)	1_000_000
BAUD_RATE	TX, RX	UART baud rate	9600
DIV_SAMPLE	RX	Oversampling factor	4
THRESHOLD	Debouncer	Debounce threshold (cycles)	100
WIDTH	Memory	Data width (bits)	8
DEPTH	Memory	Number of memory entries	16
ADDR_WIDTH	Memory	Address width (bits)	4

# Applications
FPGA-based UART debugging
Embedded systems training

Educational projects in digital communication

Hardware protocol verification
