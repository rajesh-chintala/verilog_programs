# CORDIC Based Computation of Arcsine and Arccosine functions on FPGA

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

This Repository consists of 
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
