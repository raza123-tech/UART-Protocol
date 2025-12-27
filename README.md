UART Transmitter & Receiver (Verilog HDL)
📌 Overview

This project implements a UART (Universal Asynchronous Receiver Transmitter) using Verilog HDL, including:

UART Transmitter

UART Receiver with oversampling

Multiple testbenches for standalone and loopback verification

The design is fully synthesizable and verified using waveform-based simulation.

⚙️ Features

Configurable clock frequency and baud rate

UART frame format:

1 start bit

8 data bits (LSB first)

1 stop bit

Receiver uses oversampling for reliable data capture

Busy and done flags for handshaking

File-based and loopback-based testbenches

Suitable for FPGA and ASIC learning projects

🧩 Module Description
1️⃣ UART Transmitter

File: transmitter.v

Functionality:

Accepts 8-bit parallel data

Serializes data into UART format

Generates start bit, data bits, and stop bit

Uses baud-rate counter for timing control

Key Signals:

Signal	Description
clk	System clock
reset	Synchronous reset
data[7:0]	Parallel input data
transmit	Start transmission
txd	Serial output
busy	Indicates transmission in progress
2️⃣ UART Receiver

File: receiver.v

Functionality:

Detects start bit

Uses oversampling (default 4×) for noise immunity

Samples data at mid-bit position

Outputs received byte and done flag

Key Signals:

Signal	Description
clk	System clock
rst	Reset
rxd	Serial input
rxddata[7:0]	Received data
rdone	Data valid flag
3️⃣ Testbenches
🔹 Transmitter Testbench

Sends multiple bytes

Observes txd waveform and busy signal

Verifies correct framing and timing

🔹 Receiver Testbench (File-Based)

Reads binary data from a file

Sends serial stream manually

Verifies correct data reconstruction

🔹 UART Loopback Testbench

Transmitter output connected to receiver input

Uses different clock domains (100 MHz TX, 25 MHz RX)

Automatically checks received data

Includes timeout protection

🔄 Data Flow Summary
Parallel Data → Transmitter → Serial Line → Receiver → Parallel Data

📊 Simulation & Waveforms

Waveforms generated using GTKWave

Key signals observed:

txd

busy

rxd

rxddata

rdone

🛠 Tools Used

Verilog HDL

Icarus Verilog

GTKWave

EDA Playground / Local Linux Simulation

🎯 Learning Outcomes

Understanding UART protocol timing

Baud rate generation

FSM-based serial communication

Oversampling technique in receivers

Writing robust Verilog testbenches

📌 Future Improvements

Parity bit support

Configurable data length

FIFO buffering

AXI/UART bridge

Interrupt-based receiver

👤 Author

Raza Abbas
Digital Design | VLSI | Embedded Systems

📄 License

This project is open-source and free to use for learning purposes.

✅ Data Flow Diagram (UART)
🔷 High-Level Data Flow Diagram
        +------------------+
        |   Parallel Data  |
        |   (8-bit)        |
        +--------+---------+
                 |
                 v
        +------------------+
        | UART TRANSMITTER |
        | - Start Bit      |
        | - Data Bits      |
        | - Stop Bit       |
        | - Baud Counter   |
        +--------+---------+
                 |
                 v
        +------------------+
        |  SERIAL LINE     |
        |      (txd)       |
        +--------+---------+
                 |
                 v
        +------------------+
        | UART RECEIVER    |
        | - Start Detect   |
        | - Oversampling   |
        | - Shift Register |
        +--------+---------+
                 |
                 v
        +------------------+
        | Parallel Output  |
        | (rxddata[7:0])  |
        +------------------+

🔷 Transmitter Internal Flow
data[7:0]
   |
   v
Shift Register (Start + Data + Stop)
   |
   v
Baud Counter
   |
   v
txd (Serial Output)

🔷 Receiver Internal Flow
rxd
 |
 v
Start Bit Detection
 |
 v
Oversampling Counter
 |
 v
Mid-bit Sampling
 |
 v
Shift Register
 |
 v
rxddata + rdone
