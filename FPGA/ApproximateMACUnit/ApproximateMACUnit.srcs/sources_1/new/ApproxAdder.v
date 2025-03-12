`timescale 1ns / 1ps

// PGGen module definition
module PGGen(
    output g, p,    // Generate and propagate outputs
    input a, b      // Inputs
);
    // Generate and propagate logic
    and  (g, a, b);  // Generate: AND of a and b
    xor  (p, a, b);  // Propagate: XOR of a and b
endmodule

// LowerApproxCLA module definition
module LowerApproxCLA(
    output [7:0] sum,  // 8-bit sum output
    output cout,        // Carry out output
    input [7:0] a, b    // 8-bit inputs
);
    wire [7:0] g, p, c;  // Generate, propagate, and carry wires
    wire [135:0] e;       // Intermediate wires for carry calculations
    
    // Generate PGGen instances for each bit pair of a and b
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pggen_loop
            PGGen pggen_inst (
                .g(g[i]), 
                .p(p[i]), 
                .a(a[i]), 
                .b(b[i])
            );
        end
    endgenerate
    
    // Accurate Upper 4 bits using CLA (Carry Look-Ahead logic)
    and (e[0], c[3], p[4]);
    or  (c[4], e[0], g[4]);
    
    and (e[1], c[3], p[4], p[5]);
    and (e[2], g[4], p[5]);
    or  (c[5], e[1], e[2], g[5]);
    
    and (e[3], c[3], p[4], p[5], p[6]);
    and (e[4], g[4], p[5], p[6]);
    and (e[5], g[5], p[6]);
    or  (c[6], e[3], e[4], e[5], g[6]);
    
    and (e[6], c[3], p[4], p[5], p[6], p[7]);
    and (e[7], g[4], p[5], p[6], p[7]);
    and (e[8], g[5], p[6], p[7]);
    and (e[9], g[6], p[7]);
    or  (c[7], e[6], e[7], e[8], e[9], g[7]);
    
    // Approximate Lower 4 bits using OR-based adder
    assign sum[3:0] = a[3:0] | b[3:0];  // OR-based approximation for lower bits
    assign c[3] = (a[3] & b[3]);        // Generate carry for lower bit
    assign c[0] = 0;  // No carry into the first bit

    // Accurate Sum Calculation for Upper 4 bits
    xor (sum[4], p[4], c[3]);
    xor (sum[5], p[5], c[4]);
    xor (sum[6], p[6], c[5]);
    xor (sum[7], p[7], c[6]);
    
    assign cout = c[7];  // Carry-out
    
endmodule
