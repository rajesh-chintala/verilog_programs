<img width="1638" height="878" alt="image" src="https://github.com/user-attachments/assets/1e9dec26-b31d-49f8-9abe-b1adecf0cf61" />  

### Theoretical Explanation of the CORDIC Algorithm

The **CORDIC (COordinate Rotation DIgital Computer)** algorithm is an efficient method for computing trigonometric and inverse trigonometric functions using only **simple additions and bit-shifts**. Instead of performing a single large rotation, it breaks the process down into a series of **small microrotations**.

#### 1. Fundamental Rotation Equations

The basic mathematical framework for CORDIC microrotations is defined by the following equations:
*   $X_{i+1} = X_i - \delta_i Y_i 2^{-i}$
*   $Y_{i+1} = Y_i + \delta_i X_i 2^{-i}$
*   $Z_{i+1} = Z_i + \delta_i \alpha_i$

In these equations, **$\delta_i$ determines the direction of rotation** ($\pm 1$). The value $2^{-i}$ represents a **right shift by $i$ bits**, which is hardware-efficient because it avoids expensive multipliers. The rotation angles are pre-calculated using the formula $\alpha_i = \tan^{-1}(2^{-i})$.

#### 2. The Innovation: Gain Compensation
A significant challenge in traditional CORDIC is that every microrotation increases the magnitude of the vector by a factor of $\sqrt{1 + 2^{-2i}}$. While "Direct CORDIC" fails to handle this gain accurately, the new proposed solution uses a **novel gain compensation approximation**:
$$\sqrt{1 + 2^{-2i}} \approx 1 + 2^{-2i-1}$$

This approximation is justified because squaring the right side yields $1 + 2^{-2i} + 2^{-4i-2}$, and for $i \ge 0$, the term $2^{-4i-2}$ is small enough to be **negligible**. This allows the reference value ($T$) to be updated using only one shift and one addition:
$$T_{i+1} = T_i + T_i \cdot 2^{-2i-1}$$

#### 3. Arcsine and Arccosine Logic
The algorithm calculates inverse functions by adjusting the vector step-by-step until it matches a target value.
*   **Arcsine Calculation:** The direction $\delta_i$ is chosen by comparing $Y_i$ with the reference value $T_i$. If $Y_i < T_i$, $\delta_i = 1$; otherwise, $\delta_i = -1$. The final angle is stored in the **Z path**.
*   **Arccosine Calculation:** The process is identical, but the algorithm compares the **$X$ value** instead of $Y$.

#### 4. Initialization and Optimization
To improve efficiency, the first iteration is often skipped, and the system is initialized with specific starting values.
*   **$X_1$ and $Y_1$** are initialized using a constant $A'_M$ that accounts for the cumulative gain.
*   **$Z_1$** starts at an initial angle of $45^\circ$ or $\pi/4$.
*   **$T_1$** is set to the input sine or cosine value being processed.

By adding or subtracting the pre-calculated set of angles, the algorithm can reach any target angle with **high precision** while maintaining **low hardware complexity**.
