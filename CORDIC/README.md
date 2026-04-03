# CORDIC Based Computation of Arcsine and Arccosine functions on FPGA

## 1. Introduction
The primary objective of this algorithm is to determine an unknown angle $\theta$ given a target value $t_0$, where $t_0 = \cos(\theta)$ or $t_0 = \sin(\theta)$. The algorithm is specifically designed to work with **minimal hardware** by replacing complex multiplications with iterative bit-shifting and addition.

## 2. Theoretical Foundation
The CORDIC algorithm operates by rotating an initial vector through a series of specific angles $\theta_i$. 

### Rotation Equations
The standard vector rotation is defined by:
- $x_{i+1} = x_i \cos \theta_i - y_i \sin \theta_i$
- $y_{i+1} = y_i \cos \theta_i + x_i \sin \theta_i$

### The CORDIC "Trick"
To eliminate the need for multipliers, we choose rotation angles such that:
$$\tan \theta_i = \pm 2^{-i} = d_i 2^{-i}$$
where $d_i \in \{1, -1\}$ represents the **direction of rotation**. This substitution allows the hardware to perform rotations using only **bit-shifts** ($2^{-i}$).

---

## 3. Hardware Optimization & Gain Management
Every rotation increases the magnitude of the vector by a gain factor $A_i = \sqrt{1 + 2^{-2i}}$.

### Gain Approximation
To avoid square root calculations in real-time, the gain is approximated as:
$$\sqrt{1 + 2^{-2i}} \approx 1 + 2^{-2i-1}$$
**Justification:** Squaring both sides shows that $1 + 2^{-2i} \approx 1 + 2^{-2i} + 2^{-4i-2}$. Since $2^{-4i-2} \ll 2^{-2i}$ for all $i > 0$, the error is negligible.

### Pre-Scaled Initialization
To maintain high accuracy without real-time division, the initial vector is pre-scaled by the total gain $A'_m$:
- $x_0 = A'_m \times 1$
- $y_0 = A'_m \times 0$
- $z_0 = 0^\circ$

Where the total gain is:
$$A'_m = \prod_{i=0}^{M-1} \frac{1 + 2^{-2i-1}}{\sqrt{1 + 2^{-2i}}}$$

---

## 4. Iteration Logic
The algorithm proceeds through $M$ iterations. To save hardware cycles, the **0th iteration can be bypassed** by pre-calculating initial values for $x_1, y_1,$ and $z_1$.

### Update Equations
For each iteration $i$ from 1 to $M-1$:
1. **$x_{i+1} = x_i - d_i y_i 2^{-i}$**
2. **$y_{i+1} = y_i + d_i x_i 2^{-i}$**
3. **$z_{i+1} = z_i + d_i \tan^{-1}(2^{-i})$** (Angle from a lookup table)
4. **$t_{i+1} = t_i + t_i 2^{-2i-1}$** (Updating target magnitude)

### Decision Logic for Direction ($d_i$)
The rotation direction is determined by comparing the current coordinates to the target value $t_i$:
- **For Arccosine:** $d_i = 1$ if $x_i > t_i$; otherwise $d_i = -1$.
- **For Arcsine:** $d_i = 1$ if $y_i < t_i$; otherwise $d_i = -1$.

---

## 5. Domain Mapping and Final Output
The algorithm handles input values $g_0 \in [-1, 1]$ by initially operating on the absolute value $t_0 = |g_0|$ to ensure convergence within the domain $[0, \pi/2]$.

After $M$ iterations, the final angle $\theta$ is determined as follows:

| Input Condition | Final Angle Calculation | Function |
| :--- | :--- | :--- |
| $g_0 \geq 0$ | $\theta = z_m$ | Both |
| $g_0 < 0$ | $\theta = -z_m$ | $\sin^{-1}(g_0)$ |
| $g_0 < 0$ | $\theta = 180^\circ - z_m$ | $\cos^{-1}(g_0)$ |



---

## 6. Summary of Benefits
*   **Multiplier-less:** Uses only bit-shifts and additions.
*   **High Accuracy:** Compensates for gain through pre-scaling ($A'_m$) and precise approximations.
*   **Efficient:** Bypasses initial iterations to reduce total clock cycles.

---

## 7. Implementation Details: Fixed-Point Arithmetic
To maintain the "least hardware" requirement mentioned in the sources, this project utilizes **Fixed-Point Notation (Q2.18 format)**.

*   **Hardware Compatibility:** Since the algorithm relies on bit-shifts and additions rather than floating-point units, fixed-point arithmetic is the natural choice for digital hardware implementation.
*   **Precision:** The Q2.18 format provides 2 bits for the integer part and 18 bits for the fractional part. This high fractional precision is essential for maintaining the accuracy of the iterative updates for $x, y,$ and $t$.
*   **Bit-Shift Alignment:** The hardware "trick" of using $2^{-i}$ for rotations aligns perfectly with fixed-point shifts, allowing the iterative logic to be executed with high speed and low power consumption.

*(Note: The specific Q2.18 format is not mentioned in the sources but is a standard method for implementing the bit-shift logic described in the text.)*

## 8. Development & Simulation (Python)
Python was used as the primary tool for the development and simulation phase of this project to bridge the gap between theory and hardware.

*   **Theory Understanding:** Python scripts were used to simulate the $M$ iterations of the algorithm, allowing for a step-by-step visualization of how the vector $(x, y)$ converges toward the target value $t_0$.
*   **Pre-calculation:** Python is used to pre-calculate the following constant values required by the hardware:
    *   **The Lookup Table:** Pre-computing $\tan^{-1}(2^{-i})$ values for each iteration $i$.
    *   **The Gain Constant ($A'_m$):** Calculating the high-accuracy product $A'_m = \prod_{i=0}^{M-1} \frac{1 + 2^{-2i-1}}{\sqrt{1 + 2^{-2i}}}$ used for vector initialization.
*   **Validation:** By simulating the domain mapping logic—such as reflecting negative input angles for arccosine ($\theta = 180^\circ - z_m$)—we ensured the algorithm produces mathematically sound results across the entire $[-1, 1]$ input range.

*(Note: While the algorithmic logic is detailed in the sources, the use of Python for simulation and pre-calculation is an external project feature and should be independently verified.)*

---

To incorporate your recent findings into the GitHub repository, I have added a section on **Precision and Error Analysis**. This section highlights the limitations of fixed-point implementations discovered during your Python simulations and explains why transitioning to floating-point formats may be necessary for high-bit-width applications.

***

## 9. Critical Observations: Precision and Error Analysis

Based on Python simulations utilizing 100 decimal places of precision, several key observations were made regarding the convergence and saturation of the gain constant $A'_m$ relative to the vector coordinates ($x$).

### **Saturation and Bit-Width Comparison**
The point at which the initial coordinate $x$ and the pre-calculated gain $A'_m$ (defined in the sources as the product of iterative gain corrections) saturate depends heavily on the bit-size of the variables:

*   **20-bit size:** The coordinate $x$ saturates quickly at $m=3$ (Value: `20'd 186611`), whereas $A'_m$ continues to vary until $m=10$.
*   **32-bit size:** The coordinate $x$ reaches saturation at $m=7$ (Value: `32'd 764356231`), but $A'_m$ continues to change until $m=12$.
*   **256-bit size:** At this high precision, both $x$ and $A'_m$ saturate at $m=12$.

### **The Case for Floating-Point Format**
While the algorithm is designed for "least hardware" using bit-shifts and additions, these observations reveal a significant limitation of fixed-point notation in specific contexts:

1.  **Exponential Decay of Gain Changes:** Because the incremental changes to $A'_m$ decrease exponentially with each iteration, they eventually fall below the resolution of standard fixed-point nets in hardware (such as Verilog variables). 
2.  **Verilog vs. Python Precision:** Even when Python simulations use 100 decimal places to maintain accuracy, the very small changes in $A'_m$ do not effectively impact fixed-point nets in Verilog once they fall below the least significant bit. 
3.  **Resulting Error:** In cases where $A'_m$ has not yet saturated but $x$ has, the fixed-point implementation fails to capture the remaining precision required for a "highly accurate" result.

**Conclusion:** For applications requiring extreme precision (such as those approaching 256-bit parity), **floating-point formats** are recommended. This ensures that the exponentially decreasing changes in $A'_m$ are preserved, preventing the loss of accuracy that occurs when these small values are truncated in a fixed-point environment.


<img width="1235" height="542" alt="Screenshot 2025-10-24 231532" src="https://github.com/user-attachments/assets/33b0e2b8-6479-464b-bf23-a23917df95f8" />

<img width="1490" height="849" alt="Screenshot 2025-10-24 234217" src="https://github.com/user-attachments/assets/56aac2e4-4fff-49a8-b307-0638ed08b2cc" />

<img width="1064" height="632" alt="Screenshot 2025-10-24 234440" src="https://github.com/user-attachments/assets/292b7a04-1618-491e-b014-18bde7e02d49" />

<img width="1066" height="636" alt="Screenshot 2025-10-24 234509" src="https://github.com/user-attachments/assets/a4ef182c-3b9e-4159-88b2-e5b6924d2773" />

<img width="1059" height="557" alt="Screenshot 2025-10-24 234558" src="https://github.com/user-attachments/assets/d2c89d68-910e-4629-a373-ed13754fb518" />

<img width="1504" height="862" alt="Screenshot 2025-10-24 234655" src="https://github.com/user-attachments/assets/fdadd6c2-c6ba-4580-b58a-507437b9ffce" />

<img width="1500" height="861" alt="Screenshot 2025-10-24 234747" src="https://github.com/user-attachments/assets/bbbe1fc3-1593-42ec-b50d-aa62d5e821bf" />

<img width="1123" height="575" alt="Screenshot 2025-10-24 235051" src="https://github.com/user-attachments/assets/ee22bf15-86ed-4543-8e34-1251e79cd911" />

<img width="1488" height="842" alt="Screenshot 2025-10-25 004041" src="https://github.com/user-attachments/assets/b732f22b-393a-474b-ab94-c14abe204e87" />

<img width="1616" height="844" alt="Screenshot 2025-10-25 005232" src="https://github.com/user-attachments/assets/66792678-99d7-4d87-8c08-dfd21b4ec269" />
