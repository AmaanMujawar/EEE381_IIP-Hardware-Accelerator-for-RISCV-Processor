# Investigate the feasibility of integration approximate computing arithmetic unit into a RISC-V SoC

## 1. Approximate Computing

**Definition:** Approximate point computing leverages tolerable errors in computations to achieve benifits of power, performance and efficiency.
**Applications:** Common in domains such as image processing, machine learning, and signal processing where accuracy may not be critical.
**Benefits:** 
- **Energy Efficiency:** Reducing the precision or complexity of computations can significantly lower energy use
- **Increased Performance:** Approximate computations can run faster due to simpler circuitry
- **Reduced Area:** Less complex hardware can lead to smaller chip sizes

## 2. RISC-V Architecture Overview

**Modular Design:** RISC-V's open architecture allows for the addition of custom instructions and units.
**Compatability:** Ensure that the new unit can interact with existing RISC-V components such as ALU and memory.

## 3. Designing the Approximate Arithmetic Unit

### 3.1 Specification:

**Type:** Considering a 32-bit integer-based unit focused on operations like multiply-accumulate (MAC)
**Error Management:** Decide on acceptable error levels and how to control them such as fixed precision, dynamic precision

### 3.2 Approximate Techniques:

**Bit Reduction:** Lowering precision
**Stochastic Computing:** Using probabilities to represent numbers
**Faulty Logic Circuits:** Introducing intentionally faults in logic to save power while managing error rates

## 4. Integration 

**Interface Design:** Create interfaces for the the new unit to connect with the CPU and memory
**Control Logic:** Develop control mechanisms for the approximate unit, ensuring power operation alongside traditional units
**Simulation:** Use simulation tools to evaluate the functionality and performance impact of the new unit

## 5. Performance Evaluation

**Benchmarking:** A suitable benchmark application such as a Finite Impulse Responce (FIR) filter
**Measure key performance:** Speed, energy consumption, accuracy loss
**Comparison:** Analyze the performance of the approximate unit against traditional implementations, focusing on trade-offs