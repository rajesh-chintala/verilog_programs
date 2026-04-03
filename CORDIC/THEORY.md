# CORDIC Algorithm Theory: Arcsine and Arccosine Computation

### **1. Objective**
The primary goal is to find an unknown angle $\theta$ given a **target value** $t_0$. 
*   **Input:** $t_0$, which represents either $\cos(\theta)$ or $\sin(\theta)$.
*   **Output:** The angle $\theta$.

### **2. Initial Setup and Constraints**
To ensure the algorithm converges correctly, certain initial conditions must be met:
*   **Input Range:** The target value $t_0$ should be within the range $[-1, 1]$.
*   **Normalization:** By taking absolute values, the problem is simplified to finding $\theta$ within the range $[0, \pi/2]$.
*   **Initial Vector:** The process begins with a starting vector $(x_0, y_0) = (1, 0)$ and an initial angle $z_0 = 0^\circ$.
*   **Convergence:** The total rotation angle $\theta_c$, which is the sum of individual iterative rotations ($d_i \theta_i$), must fall within $[-\pi/2, \pi/2]$ to ensure the algorithm finds the correct result.

### **3. The Iterative Rotation Process**
The algorithm works by rotating the initial vector in small increments until it aligns with the target value. For each iteration $i$, the vector is rotated by a specific angle $\theta_i$.

#### **Mathematical Foundation**
The standard rotation equations for a vector are:
1.  $x_{i+1} = x_i \cos \theta_i - y_i \sin \theta_i$
2.  $y_{i+1} = y_i \cos \theta_i + x_i \sin \theta_i$

At any given iteration, the vector coordinates $(x, y)$ represent $(\cos z_i, \sin z_i)$.

### **4. Hardware Optimization (The "CORDIC Trick")**
To make the algorithm efficient for hardware (using only bit-shifts and additions rather than complex multiplications), the rotation angle $\theta_i$ is chosen such that:
$$\tan \theta_i = \pm 2^{-i}$$
Where **$d_i$** ($\pm 1$) represents the **direction of rotation**.

#### **Simplifying the Equations**
By factoring out $\cos \theta_i$, the equation for $x_{i+1}$ becomes:
$$x_{i+1} = \cos \theta_i (x_i - y_i \tan \theta_i)$$

Substituting the hardware-friendly values:
*   $\tan \theta_i = d_i 2^{-i}$
*   $\cos \theta_i = \frac{1}{\sqrt{1 + \tan^2 \theta_i}} = \frac{1}{\sqrt{1 + 2^{-2i}}}$

This results in the final iterative formula:
$$x_{i+1} = \frac{1}{\sqrt{1 + 2^{-2i}}} (x_i - y_i d_i 2^{-i})$$

### **5. Understanding the Gain ($A_i$)**
The term $A_i = \sqrt{1 + 2^{-2i}}$ represents the **gain of the vector**. Because each rotation slightly increases the magnitude (length) of the vector, this gain factor is used to normalize the result at each iteration, ensuring the final output is highly accurate.

Building on the initial explanation of the CORDIC algorithm's rotation and gain, the following sections detail how the process is optimized for minimal hardware usage while maintaining high accuracy.

### **6. Shifting Gain Management**
In the standard CORDIC implementation, the gain ($A_i$) must be removed or reduced at each iteration to keep the vector magnitude constant. To simplify this for hardware, the algorithm instead **multiplies the gain with the target value ($t$)** to increase its magnitude, rather than performing complex division on the $x$ and $y$ coordinates. 

### **7. Hardware-Efficient Update Equations**
The algorithm updates its parameters using only **bit shifts and additions**, which are computationally "cheap" operations for digital hardware:
*   **Vector Coordinates ($x, y$):** The coordinates are updated as:
    *   $x_{i+1} = x_i - d_i y_i 2^{-i}$
    *   $y_{i+1} = y_i + d_i x_i 2^{-i}$
    These equations allow for rotation without explicit multiplication.
*   **Angle ($z$):** The angle is updated using pre-calculated values stored in a **look-up table**:
    *   $z_{i+1} = z_i + d_i \tan^{-1}(2^{-i})$.
*   **Target Value ($t$):** The target value is initially updated as $t_{i+1} = t_i \sqrt{1 + 2^{-2i}}$.

### **8. Optimizing Gain Calculation through Approximation**

To avoid the computational expense of calculating square roots in hardware, the algorithm replaces the exact gain factor with a hardware-friendly approximation. This allows the target value update to be performed using only bit shifts and additions.,

**Step 1: The Exact Gain Factor**
At each iteration $i$, the target value $t$ is ideally updated by the gain factor resulting from the rotation:
$$t_{i+1} = t_i \sqrt{1 + 2^{-2i}}$$,

**Step 2: The Approximation**
The square root term is approximated to simplify the calculation:
$$\sqrt{1 + 2^{-2i}} \approx 1 + 2^{-2i-1}$$

**Step 3: Mathematical Justification (S.O.B.S. - Squaring On Both Sides)**
To prove the validity of this approximation, we compare the squared values of both sides:
*   **Left Side Squared:** $(\sqrt{1 + 2^{-2i}})^2 = \mathbf{1 + 2^{-2i}}$
*   **Right Side Squared:** $(1 + 2^{-2i-1})^2 = 1 + 2(2^{-2i-1}) + (2^{-2i-1})^2 = \mathbf{1 + 2^{-2i} + 2^{-4i-2}}$

**Step 4: Analyzing the Error Term**
Comparing the two results, we see an extra error term of $2^{-4i-2}$. The sources note that:
$$2^{-4i-2} \ll 2^{-2i} \quad \text{for all } i > 0$$
Because this error term is significantly smaller than the primary terms, the approximation is considered highly accurate for the algorithm's needs.

**Step 5: Final Hardware-Efficient Equation**
Substituting the approximation back into the update formula results in an equation that requires only **bit shifts and additions**:
$$t_{i+1} = t_i (1 + 2^{-2i-1})$$
$$t_{i+1} = t_i + t_i 2^{-2i-1}$$,

### **9. Pre-Scaled Initialization for Maximum Accuracy**
Because the approximation ($1 + 2^{-2i-1}$) introduces a slight difference compared to the true gain, the algorithm uses a **pre-scaled initialization** to maintain high accuracy in the final result. 

The vector is initialized as follows:
*   **$x_0 = A'_m \times 1$**
*   **$y_0 = A'_m \times 0$**
*   **$z_0 = 0^\circ$**

Here, **$A'_m$** represents the total accumulated gain over $M$ iterations, calculated as the product of the individual gain error terms ($A'_i$):
$$A'_m = \prod_{i=0}^{M-1} \frac{1 + 2^{-2i-1}}{\sqrt{1 + 2^{-2i}}}$$.

By starting with this pre-scaled vector and performing the iterations using the simplified equations for $x, y, z,$ and $t$, the algorithm achieves **highly accurate results** with the **least amount of hardware resources**.

### **10. Determining the Rotation Direction ($d_i$)**
The decision to rotate the vector clockwise or anti-clockwise depends on whether the current coordinate is above or below the target value ($t_i$).

*   **For Arccosine ($t_0 = \cos \theta$):**
    *   The direction is set as $d_i = 1$ if $x_i > t_i$, and $d_i = -1$ otherwise.
    *   **Logic:** If the current $x$-coordinate is greater than the target, it needs to be decreased. To decrease the cosine value in the first quadrant, the vector must be rotated in an **anti-clockwise** direction.
*   **For Arcsine ($t_0 = \sin \theta$):**
    *   The direction is set as $d_i = 1$ if $y_i < t_i$, and $d_i = -1$ otherwise.
    *   **Logic:** If the current $y$-coordinate is less than the target, it needs to be increased. This is achieved by rotating the vector in an **anti-clockwise** direction.

### **11. Bypassing the Initial Iteration**
To further reduce hardware cycles, the algorithm can bypass the 0th iteration by pre-calculating the initial values for $x$, $y$, and $z$. By assuming the first rotation direction ($d_0$) is always 1, the vector can be initialized as follows:
*   **$x_0 = A'_m \cos(\tan^{-1}(2^0))$**
*   **$y_0 = A'_m \sin(\tan^{-1}(2^0))$**
*   **$z_0 = \tan^{-1}(2^0)$**
This shortcut allows the physical hardware to start directly from the first iteration ($i=1$) instead of $i=0$.

### **12. Final Angle Calculation and Range Mapping**
Once all iterations are complete, the resulting angle ($z_m$) is used to determine the final angle $\theta$ based on the original target value ($t_0$).

*   **Positive Target Values ($t_0 \in$):**
    *   The final angle $\theta$ is simply the resultant angle $z_m$, falling within $[0, \pi/2]$.
*   **Negative Target Values ($t_0 \in [-1, 0]$):**
    *   The algorithm first calculates a resultant angle ($z_m$) by using the **absolute value** of $t_0$.
    *   The final $\theta$ is then mapped as:
        *   **For Arcsine:** $\theta = -z_m$.
        *   **For Arccosine:** $\theta = 180^\circ - z_m$.

This ensures the final output adheres to the standard mathematical ranges for inverse trigonometric functions: $\sin^{-1}(t_0) \in [-\pi/2, \pi/2]$ and $\cos^{-1}(t_0) \in [0, \pi]$.

The fourth image provides a **comprehensive summary** of the CORDIC algorithm designed for arcsine and arccosine, focusing on achieving highly accurate results with minimal hardware. 

### **1. Input and Objective**
The algorithm starts with a **given value $g_0 \in [-1, 1]$**, which represents either $\cos(\theta)$ or $\sin(\theta)$. The goal is to find the angle $\theta$.

### **2. Pre-processing: Domain Reduction**
To ensure the algorithm converges correctly, the first step is to **take the absolute value** of the input:
*   $t_0 = |g_0| \in$.
*   This reduces the convergence domain to $[0, \pi/2]$.

### **3. Optimized Initialization**
The algorithm bypasses the first iteration ($i=0$) by using a **pre-calculated initial vector** to save hardware cycles. This vector is scaled by an accuracy constant to maintain high precision:
*   **Initial Coordinates:**
    *   $x_1 = A'_m \cos(\tan^{-1}(2^{-0}))$
    *   $y_1 = A'_m \sin(\tan^{-1}(2^{-0}))$
*   **Initial Angle:** $z_1 = \tan^{-1}(2^{-0})$
*   **Accuracy Constant ($A'_m$):** $A'_m = \prod_{i=0}^{M-1} \frac{1 + 2^{-2i-1}}{\sqrt{1 + 2^{-2i}}}$.

### **4. Iterative Rotation Process**
The vector is rotated for each iteration $i$ from $1$ to $m-1$. The algorithm is optimized for hardware by assuming $\theta_i = \tan^{-1}(2^{-i})$, which **converts real-time multiplications into simple bit shifts**. The update equations are:
*   **Coordinates:** $x_{i+1} = x_i - d_i y_i 2^{-i}$ and $y_{i+1} = y_i + d_i x_i 2^{-i}$.
*   **Angle:** $z_{i+1} = z_i + d_i \tan^{-1}(2^{-i})$.
*   **Target Magnitude:** $t_{i+1} = t_i + t_i 2^{-2i-1}$.

### **5. Resultant Angle and Final Calculation**
After $m$ iterations, **$z_m$ is identified as the resultant angle**. The final angle $\theta$ is determined based on the original input $g_0$:

*   **For Positive Inputs ($t_0 = g_0$):** 
    *   $\theta = z_m$.
*   **For Negative Inputs ($t_0 = -g_0$):**
    *   **Arcsine ($g_0 = \sin\theta$):** $\theta = -z_m$.
    *   **Arccosine ($g_0 = \cos\theta$):** $\theta = 180^\circ - z_m$.
