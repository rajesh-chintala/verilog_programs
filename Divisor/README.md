## Introduction

This project implements an **integer division unit** using a **repeated subtraction**
approach in **Verilog HDL**.
The division operation is carried out over multiple clock cycles, making it
suitable for demonstrating **iterative hardware design**.

The design is organized using a **Datapath and Control Path architecture**.
The datapath contains the arithmetic and storage elements required to perform
division, while the control path sequences these operations using a
**Finite State Machine (FSM)**.

The datapath performs subtraction, comparison, and quotient accumulation.
The control path generates the necessary control signals to coordinate these
operations and determines when the division process is complete.

This structured separation closely reflects the design methodology used in
processors and digital arithmetic units.

## Datapath and Control Path Algorithms

### Datapath Algorithm
1. Load the dividend into the dividend register.
2. Load the divisor into the divisor register.
3. Compare the dividend and divisor values.
4. If dividend is greater than or equal to divisor:
   - Subtract divisor from dividend.
   - Store the result back into the dividend register.
5. Increment the quotient counter.
6. Repeat the comparison and subtraction steps until dividend is less than divisor.
7. Store the final dividend value as the remainder.

---

### Control Path Algorithm
1. Initialize the control unit and reset internal registers.
2. Assert load signals to store dividend and divisor values.
3. Enable comparison operation in the datapath.
4. If dividend is greater than or equal to divisor:
   - Enable subtraction in the datapath.
   - Enable increment of the quotient counter.
5. Return to comparison state.
6. If dividend is less than divisor:
   - Disable arithmetic operations.
   - Assert the `done` signal to indicate completion.


## Hardware Architecture

The hardware architecture of the integer division unit is organized into two
clearly separated blocks: the **Datapath** and the **Control Path**.
This separation allows arithmetic operations and control sequencing to be
designed, analyzed, and verified independently.

The **Datapath** contains all hardware elements responsible for data storage,
arithmetic computation, and comparison.
The **Control Path** is implemented as a Finite State Machine (FSM) that generates
control signals to coordinate datapath operations across clock cycles.

### Datapath Components
- Dividend Register (PIPO)
- Divisor Register (PIPO)
- Subtractor
- Comparator
- Multiplexer
- Quotient Counter (Up-counter)

### Control Path Components
- FSM-based control unit
- Control signal generation logic
- Completion (`done`) signal logic

The control path observes comparator outputs from the datapath and decides
whether to continue subtraction or terminate the division process.
## FSM States and Control Signal Mapping

The control path is implemented as a Finite State Machine (FSM) with
**3-bit encoded states (s0–s7)**.
Each state asserts a specific combination of control signals to drive
the datapath during the integer division operation.

### FSM State Encoding

| State | Binary | Description |
|------|--------|-------------|
| s0 | 000 | Idle / Initialization state |
| s1 | 001 | Load divisor |
| s2 | 010 | Load dividend |
| s3 | 011 | Initial subtraction preparation |
| s4 | 100 | Subtract and increment quotient |
| s5 | 101 | Intermediate state |
| s6 | 110 | Comparison and loop decision |
| s7 | 111 | Done state |

---

### FSM Control Signal Table

| State | lda | ldb | ldp | sel | inc | ldc | done | Datapath Operation |
|------|-----|-----|-----|-----|-----|-----|------|-------------------|
| s0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | Reset quotient counter |
| s1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | Load divisor |
| s2 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | Load dividend |
| s3 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | Load initial value into accumulator |
| s4 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | Subtract divisor and increment quotient |
| s5 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | Hold datapath values |
| s6 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | Evaluate comparator output |
| s7 | 0 | 0 | 0 | 1 | 0 | 0 | 1 | Division complete |

---

### FSM State Transition Table

| Current State | Condition | Next State |
|--------------|-----------|------------|
| s0 | `start = 1` | s1 |
| s1 | — | s2 |
| s2 | — | s3 |
| s3 | — | s4 |
| s4 | — | s5 |
| s5 | — | s6 |
| s6 | `gt = 1` | s4 |
| s6 | `gt = 0` | s7 |
| s7 | — | s7 |

---

### FSM Behavior Summary

- The FSM initializes the quotient counter in **s0**.
- Operand loading is performed in **s1 (divisor)** and **s2 (dividend)**.
- Subtraction and quotient increment occur in **s4**.
- The loop is controlled in **s6** using the comparator output `gt`.
- When the dividend becomes smaller than the divisor, the FSM transitions to **s7** and asserts `done`.

This FSM implements a **multi-cycle repeated subtraction division algorithm**
with explicit sequencing and deterministic control.

