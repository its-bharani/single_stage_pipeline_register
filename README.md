# Single-Stage Pipeline Register (Valid/Ready Handshake)

This repository contains a **single-stage pipeline register** implemented in **SystemVerilog** using a standard **valid/ready handshake** mechanism.  
The module safely transfers data between an input and output interface while correctly handling **backpressure**, ensuring **no data loss or duplication**.

---

## Overview

- One-deep pipeline register (stores one data item)
- Uses valid/ready flow control
- Fully synthesizable RTL
- Clean reset behavior
- Supports back-to-back data transfers

This type of module is commonly used as a **pipeline stage**, **skid buffer**, or **flow-control element** in processors, interconnects, and streaming interfaces.

---

## Module Interface

### Inputs

- `clk`  
  Clock signal.

- `rst_n`  
  Active-low asynchronous reset. Clears the pipeline to an empty state.

- `in_data [DATA_WIDTH-1:0]`  
  Input data bus.

- `in_valid`  
  Indicates that `in_data` is valid and can be accepted if `in_ready` is high.

- `out_ready`  
  Indicates that the downstream logic is ready to accept output data.

---

### Outputs

- `in_ready`  
  Indicates that the pipeline register is ready to accept new input data.

- `out_data [DATA_WIDTH-1:0]`  
  Output data bus (stored pipeline data).

- `out_valid`  
  Indicates that `out_data` is valid.

---

## Internal Signals

- `data_reg`  
  Register that stores the data value.

- `valid_reg`  
  Indicates whether the pipeline register currently holds valid data.
  - `0` → empty
  - `1` → full

---

## Functional Description

The module acts as a **single storage element** between input and output:

- Accepts data from the input when allowed by handshake signals.
- Holds data when downstream is not ready.
- Releases data to output when downstream is ready.
- Allows simultaneous input and output transfer in the same clock cycle.

---

## Ready Logic

in_ready = ~valid_reg || out_ready;
The pipeline is ready to accept new input data when:

the register is empty, or

the current data is being accepted by the output in the same cycle.

---

## Output Logic

out_data  = data_reg;
out_valid = valid_reg;


When valid_reg is high, the stored data is presented on the output.
When valid_reg is low, the pipeline is empty and output data is invalid.

---

## Input Handshake (Data Acceptance)

if (in_valid && in_ready)


When both signals are high:

Input data is captured into data_reg

valid_reg is set to 1

Pipeline becomes full

This occurs whether the pipeline was previously empty or the output is consuming data in the same cycle.

---

## Output Handshake (Without New Input)

else if (out_ready && out_valid)


When:

Output is ready, and

No new input data is being written

Then:

Stored data is considered consumed

valid_reg is cleared

Pipeline becomes empty

---


## Reset Behavior
if (!rst_n)
    valid_reg <= 1'b0;


On reset, the pipeline starts in a clean empty state

No stale or invalid data remains

---

## Testbench Description

A simple directed **SystemVerilog testbench** is provided to verify the functionality of the **single-stage pipeline register**.  
The testbench focuses on validating:

- Correct **valid/ready handshake behavior**
- Proper **backpressure handling**
- Correct **reset operation**

---

### Testbench Structure

The testbench performs the following tasks:

- Instantiates the pipeline register as the **Design Under Test (DUT)**
- Generates a free-running clock
- Applies reset and stimulus signals
- Monitors input and output behavior

---

### Clock Generation

A periodic clock with a **10 ns period** is generated to drive the synchronous logic.

always #5 clk = ~clk;
### Reset Sequence

- Reset (`rst_n`) is asserted at the start of simulation
- The pipeline register is cleared to an empty state
- Reset is deasserted before applying any stimulus

This verifies correct reset behavior of the design.

---

### Test Scenarios

#### 1. Normal Data Transfer

- `in_valid` and `out_ready` are asserted
- Data is successfully transferred through the pipeline
- `out_valid` is asserted with the correct output data

This confirms basic valid/ready handshake functionality.

---

#### 2. Backpressure Handling

- `out_ready` is deasserted to simulate downstream stall
- The pipeline holds the data without loss or duplication
- Once `out_ready` is asserted again, data transfer resumes

This verifies correct backpressure handling.

---

#### 3. Back-to-Back Transfers

- Multiple input data values are applied in consecutive clock cycles
- The pipeline accepts new data every cycle
- No idle (bubble) cycles occur

This confirms zero-bubble throughput capability.

---

### Signal Monitoring

A monitor prints key signals during simulation, allowing observation of:

- Input and output handshakes
- Valid and ready behavior
- Data flow through the pipeline

---

### Simulation End

The simulation is terminated after all test cases complete using the `$finish` system task.

---

### Waveform

<img width="1677" height="322" alt="image" src="https://github.com/user-attachments/assets/346d0c8b-3813-4780-b497-5ab8833b4932" />


---

### EDA-PLAYGROUND

https://www.edaplayground.com/x/tDSE

