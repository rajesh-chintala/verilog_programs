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
