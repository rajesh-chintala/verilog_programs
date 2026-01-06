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

<img width="796" height="1024" alt="image" src="https://github.com/user-attachments/assets/a92dd180-85df-4c79-b1ec-1fe8ee38bd26" />


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

The control path is implemented as a **3-bit Finite State Machine (FSM)**.
Each state generates a specific set of control signals that coordinate datapath
operations for the repeated-subtraction division algorithm.

<img width="958" height="322" alt="b695e6825907b6fecbba032de955d104_Untitled" src="https://github.com/user-attachments/assets/746d6393-3c8b-4892-9106-f53cb75991c1" />


The FSM uses **seven states (s0–s6)**. All control signals are deasserted by
default and asserted only in the states where they are required.

---

### FSM State Encoding

| State | Binary | Description |
|------|--------|-------------|
| s0 | 000 | Initialization / Idle state |
| s1 | 001 | Load dividend |
| s2 | 010 | Load divisor and initialize accumulator |
| s3 | 011 | Comparison state |
| s4 | 100 | Subtract and increment quotient |
| s5 | 101 | Loop-back state |
| s6 | 110 | Done state |

---

### FSM Control Signal Table

| State | lda | ldb | ldp | ldc | sel | inc | done | Datapath Operation |
|------|-----|-----|-----|-----|-----|-----|------|-------------------|
| s0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | Reset quotient counter |
| s1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | Load dividend |
| s2 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | Load divisor and accumulator |
| s3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | Compare accumulator and divisor |
| s4 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | Subtract divisor and increment quotient |
| s5 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | Loop-back / pipeline state |
| s6 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | Division complete |

---

### FSM State Transition Table

| Current State | Condition | Next State |
|--------------|-----------|------------|
| s0 | `start = 1` | s1 |
| s1 | — | s2 |
| s2 | — | s3 |
| s3 | `lt = 0` | s4 |
| s3 | `lt = 1` | s6 |
| s4 | — | s5 |
| s5 | — | s3 |
| s6 | — | s6 |

---

### FSM Behavior Summary

- **s0** initializes the quotient counter using `ldc`.
- **s1** loads the dividend into the datapath.
- **s2** loads the divisor and initializes the accumulator.
- **s3** evaluates the comparison between accumulator and divisor.
- **s4** performs subtraction and increments the quotient.
- **s5** provides a loop-back transition to re-enter comparison.
- **s6** asserts `done` and holds the final quotient and remainder stable.

This FSM implements a **multi-cycle integer division algorithm** using
repeated subtraction, with clear separation between datapath execution
and control sequencing.

## Notes:
---
- Remember there are both Asynchronous and Synchronous inputs present as control signals. Synchronous signals wait for the clock to come. So they are effecting only in the next cycle. Thus some empty states had been included in the FSM. Asynchronous signals appy as usual in the same clock period.
