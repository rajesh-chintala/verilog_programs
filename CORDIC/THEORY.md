# CORDIC Algorithm Theory: Arcsine and Arccosine Computation

## Aim

Compute arcsine and arccosine functions with minimal hardware overhead and high accuracy.

**Given:** A targeted value: $t = \frac{\cos(\theta)}{\sin(\theta)}$

**Goal:** Find $\theta$

---

## Procedure

### Step 1: Domain Constraint

Restrict the input $\theta$ to be in the range $[-1, 1]$ for valid arcsine/arccosine computation.

### Step 2: Absolute Value Handling

Taking absolute values for $D \in [0, 1]$ implies $\theta \in [0, \frac{\pi}{2}]$

**Initialize the vector:**
```
(x₀, y₀) = (1, D)
z₀ = 0°
```

**Note:** There is no issue of convergence angle for CORDIC (i.e., $\theta_C$).

---

## Step 3: CORDIC Iterative Rotation

The angle accumulation follows:

$$Q_i = \sum_{i=0}^{n} d_i\theta_i, \quad Q_i \in \left[-\frac{\pi}{2}, \frac{\pi}{2}\right]$$

where $z_p = z_0 + Q_i$

### Basic CORDIC Rotation Equations

Rotating the vector with angle $\theta_i$ at each iteration $i$ yields:

$$x_{i+1} = x_i \cos\theta_i - y_i \sin\theta_i$$

$$y_{i+1} = y_i \cos\theta_i + x_i \sin\theta_i$$

---

## Step 4: Shift-and-Add Implementation

### Angle Assumption

Assume: $\tan\theta_i = \pm 2^{-i}$ (enabling shift-and-add architecture)

### Cosine Approximation

$$\cos\theta_i = \frac{1}{\sqrt{1 + \tan^2\theta}} = \frac{1}{\sqrt{1 + 2^{-2i}}}$$

### Simplified Iteration Equations

$$x_{i+1} = \frac{1}{\sqrt{1 + 2^{-2i}}} \left(x_i - y_i \cdot d_i \cdot 2^{-i}\right)$$

$$y_{i+1} = \frac{1}{\sqrt{1 + 2^{-2i}}} \left(y_i + x_i \cdot d_i \cdot 2^{-i}\right)$$

where $d_i \in \{-1, +1\}$ determines the rotation direction.

---

## Step 5: Gain Compensation

### Scaling Factor

At each iteration, the magnitude scaling factor is:

$$A_i = \sqrt{1 + 2^{-2i}}$$

This represents the gain introduced by the rotation operation.

### Cumulative Gain

The total gain after $n$ iterations:

$$A_{total} = \prod_{i=0}^{n-1} A_i = \prod_{i=0}^{n-1} \sqrt{1 + 2^{-2i}} \approx 1.6467...$$

**Important:** This scaling factor must be compensated at each iteration to maintain accuracy and ensure proper convergence.

---

## Mathematical Formulation

### Vector Rotation at Each Stage

At every iteration, the angle $\theta_{i+1}$ where $(x, y) = (\cos(z), \sin(z))$:

$$x_{i+1} = \cos\theta_i \left(x_i - y_i \tan\theta_i\right)$$

Substituting the shift-and-add approximation:

$$x_{i+1} = \frac{1}{\sqrt{1 + 2^{-2i}}} \left(x_i - y_i d_i 2^{-i}\right)$$

### Angle Accumulation

The output angle is built iteratively:

$$z_{i+1} = z_i + d_i \cdot \arctan(2^{-i})$$

Initial condition: $z_0 = 0°$ for arcsine/arccosine computation.

---

## Algorithm Summary

### Initialization
```
Input: D ∈ [0, 1] (normalized sine or cosine value)
(x₀, y₀) = (1, D)
z₀ = 0°
```

### Iteration (for i = 0 to n-1)
```
d_i = sign(target - y_i)  // Direction of rotation

x_{i+1} = (x_i - y_i × d_i × 2^{-i}) / √(1 + 2^{-2i})

y_{i+1} = (y_i + x_i × d_i × 2^{-i}) / √(1 + 2^{-2i})

z_{i+1} = z_i + d_i × arctan(2^{-i})
```

### Output
```
θ_output = z_n (converged angle in radians)
```

---

## Hardware Advantages

✅ **No Multiplication:** Only shift and add operations (except gain compensation)

✅ **Minimal Area:** Efficient FPGA/ASIC implementation with minimal gates

✅ **High Accuracy:** Convergence guaranteed for valid input range [-1, 1]

✅ **Pipelinable:** Each iteration can be pipelined for high throughput

✅ **Low Power:** Shift operations consume minimal power compared to multipliers

---

## Convergence Analysis

The CORDIC algorithm converges when:

$$\sum_{i=0}^{\infty} \arctan(2^{-i}) = \frac{\pi}{2}$$

After $n$ iterations with properly compensated gain, the error is approximately:

$$\epsilon \approx 2^{-2n}$$

This means **each additional iteration doubles the effective precision**.

---

## Key Equations Reference

| Operation | Equation |
|-----------|----------|
| Gain Factor | $A_i = \sqrt{1 + 2^{-2i}}$ |
| X Update | $x_{i+1} = \frac{1}{A_i}(x_i - y_i d_i 2^{-i})$ |
| Y Update | $y_{i+1} = \frac{1}{A_i}(y_i + x_i d_i 2^{-i})$ |
| Angle Update | $z_{i+1} = z_i + d_i \arctan(2^{-i})$ |
| Cumulative Gain | $\prod_{i=0}^{n-1} A_i \approx 1.6467$ |

---

## Applications

- **Trigonometric Functions:** $\sin(\theta)$, $\cos(\theta)$, $\tan(\theta)$
- **Inverse Trigonometric:** $\arcsin(x)$, $\arccos(x)$, $\arctan(y/x)$
- **Hyperbolic Functions:** $\sinh(\theta)$, $\cosh(\theta)$, $\tanh(\theta)$
- **Coordinate Transformations:** Cartesian ↔ Polar
- **Signal Processing:** Phase detection, angle computation

---

## References

1. Volder, J.E. (1959). "The CORDIC Trigonometric Computing Technique"
2. Andraka, R. (1998). "A Survey of CORDIC Algorithms for FPGA Based Computers"
3. Walther, J.S. (1971). "A Unified Algorithm for Elementary Functions"

---

## Notes

- All angles are in radians unless otherwise specified
- Input domain $D \in [0, 1]$ maps to angle range $[0, \frac{\pi}{2}]$
- The algorithm can be extended to full $2\pi$ range using quadrant selection
- Gain compensation is critical for maintaining accuracy across all iterations