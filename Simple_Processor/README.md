# Simple Processor – Verilog Design Brief

---

## Table of Contents

1. Objective
2. Processor Overview
3. Register Set
4. Instruction Encoding
5. Supported Operations
6. Control Signals
7. Timing Control (FSM)
8. Register Select Logic
9. Control Signal Equations
10. Verilog Module Breakdown
11. Testbench Strategy
12. Expected Outputs
13. Future Extensions
14. Repository Structure
15. Conclusion

---

# Simple Processor – Verilog Design Brief

## 1. Objective

This project implements a **simple multi-cycle processor** in **Verilog HDL**, intended for learning datapath and control design fundamentals. The processor supports **Load, Move, Add, and Subtract** operations using a shared internal bus, temporary registers, and a hardwired control unit.

---

## 2. Processor Overview

<img width="1525" height="593" alt="image" src="https://github.com/user-attachments/assets/b90fe815-9b92-4a2e-a451-547313a28d19" />


### Key Features

* **4 General Purpose Registers**: R0, R1, R2, R3 (n-bit wide)
* **Single shared internal bus**
* **Temporary Registers**: A and G
* **Multi-cycle execution** for arithmetic operations
* **Hardwired control unit** using time steps (T0–T3)

### Data Width

* Parameterized (`n` bits)
* Typical configurations: 8-bit or 16-bit

---

## 3. Register Set

| Register | Description                                |
| -------- | ------------------------------------------ |
| R0–R3    | General-purpose registers                  |
| A        | Operand register (holds first ALU operand) |
| G        | ALU result register                        |

All registers load data from the internal bus.

---

## 4. Instruction Encoding

<img width="759" height="665" alt="image" src="https://github.com/user-attachments/assets/862e8b06-0d1c-4650-97fe-c5706e70875b" />


### Function Select (`f1 f0`)

| f1 f0 | Operation |
| ----- | --------- |
| 00    | LOAD      |
| 01    | MOVE      |
| 10    | ADD       |
| 11    | SUB       |

### Operand Selection

* `Rx1 Rx0` → Selects destination register Rx
* `Ry1 Ry0` → Selects source register Ry

---

## 5. Supported Operations

### 5.1 LOAD Operation

**Operation:** `Rx ← Data`

* External data is placed on the bus
* Data is loaded directly into Rx
* **Completes in 1 clock cycle**

---

### 5.2 MOVE Operation

**Operation:** `Rx ← Ry`

* Ry drives the bus
* Rx captures bus value
* **Completes in 1 clock cycle**

---

### 5.3 ADD / SUB Operation

**Operation:** `Rx ← Rx ± Ry`

<img width="781" height="655" alt="image" src="https://github.com/user-attachments/assets/588ca281-fdb7-45ed-81aa-c92d60acb4ab" />


Executed in **3 clock cycles**:

| Time Step | Action                             |
| --------- | ---------------------------------- |
| T1        | Rx → Bus → A                       |
| T2        | Ry → Bus, ALU performs Add/Sub → G |
| T3        | G → Bus → Rx                       |

**Why multi-cycle?**

<img width="949" height="412" alt="image" src="https://github.com/user-attachments/assets/f94323b4-d5cf-48c2-9dda-4ae5e18204d3" />

* Single bus architecture
* Only one operand can be placed on the bus at a time

---

## 6. Control Signals

### Core Control Signals

| Signal | Function                       |
| ------ | ------------------------------ |
| Rin    | Register load enable           |
| Rout   | Register output enable         |
| Ain    | Load A register                |
| Gin    | Load G register                |
| Gout   | Enable G register onto bus     |
| AddSub | ALU control (0=Add, 1=Sub)     |
| Extern | Enable external data onto bus  |
| Done   | Indicates operation completion |
| W      | Start operation                |
| Clear  | Resets timing counter          |

---

## 7. Timing Control (FSM)

The processor uses a **2-bit timing counter**:

| State | Meaning             |
| ----- | ------------------- |
| T0    | Idle / No operation |
| T1    | Operand fetch       |
| T2    | Execute             |
| T3    | Write-back          |

* `Clear = 1` forces the counter to T0
* Load and Move finish at T1
* Add/Sub finish at T3

---

## 8. Register Select Logic

### X and Y Decode

* `X0–X3` → Select Rx
* `Y0–Y3` → Select Ry

### Register Load Mapping

* If `Rin = X`:

  * R0in = X0, R1in = X1, R2in = X2, R3in = X3
* If `Rin = Y`:

  * R0in = Y0, R1in = Y1, R2in = Y2, R3in = Y3

### Register Output Mapping

* If `Rout = X`:

  * R0out = X0, R1out = X1, R2out = X2, R3out = X3
* If `Rout = Y`:

  * R0out = Y0, R1out = Y1, R2out = Y2, R3out = Y3

---

## 9. Control Signal Equations (Examples)

* `Extern = I0 · T1`
* `Done = (I0 + I1)·T1 + (I2 + I3)·T3`
* `Ain = (I2 + I3)·T1`
* `Gin = (I2 + I3)·T2`
* `Gout = (I2 + I3)·T3`

(I0–I3 correspond to decoded instruction functions)

---

## 10. Verilog Module Breakdown

### RTL Modules

1. `register.v` – Generic n-bit register
2. `alu.v` – Add/Sub unit
3. `bus_mux.v` – Internal bus multiplexer
4. `control_unit.v` – FSM + control logic
5. `processor_top.v` – Datapath integration

---

## 11. Testbench Strategy

* Apply **reset initially** (mandatory)
* Apply `W=1` with function code
* Monitor:

  * Register values
  * Done signal
  * Bus activity

⚠️ **Common mistake**: Not asserting reset before starting simulation

---

## 12. Expected Outputs

* Correct register updates
* Proper Done assertion
* Clear timing transitions
* Verified waveforms in GTKWave / ModelSim

---

## 13. Future Extensions

* Instruction memory
* Program Counter
* Pipelining
* Control ROM instead of hardwired logic
* FPGA synthesis

---

## 14. Repository Structure (Suggested)

```
Simple-Processor/
│── rtl/
│   ├── register.v
│   ├── alu.v
│   ├── control_unit.v
│   ├── processor_top.v
│
│── tb/
│   ├── processor_tb.v
│
│── docs/
│   ├── architecture.md
│
│── README.md
```

---

## 15. Conclusion

This processor demonstrates **core CPU concepts** using minimal hardware. It provides a strong foundation for understanding how real processors execute instructions using shared datapaths and multi-cycle control.

---
