`timescale 1ns / 1ps

module approx_mac8Bit_TB;
    reg clk;
    reg rst;
    reg [7:0] a;
    reg [7:0] b;
    reg [15:0] acc_in;
    wire [15:0] acc_out;
    wire [15:0] mult_result; // Wire to capture multiplication result
    
    // Instantiate the approximate MAC module (renamed correctly)
    ApproxMAC uut (
        .clk(clk),
        .rst(rst),
        .A(a),
        .B(b),
        .AccIn(acc_in),
        .AccOut(acc_out),
        .mult_result(mult_result)  // Connect the output to capture multiplication result
    );
    
    integer i;
    // Clock generation @ 50MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock -> 20ns period
    end
    
    // Simulate
    initial begin
        // Initialize inputs
        rst = 1; // Reset initially high
        a = 0;
        b = 0;
        acc_in = 0;
        
        // Apply reset
        #20;
        rst = 0; // Release reset
        
        // Run through multiple test cases
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk); // Wait for a clock edge
            
            // Generate random values for inputs
            a = $random % 256; // 8-bit random value
            b = $random % 256; // 8-bit random value
            acc_in = acc_out; // Feed last accumulator output as input to next cycle
            
            // Log the values of a, b, acc_in, acc_out, and multiplication result
            $display("Cycle %0d: a = %d, b = %d, acc_in = %d, mult_result = %d, acc_out = %d", 
                     i, a, b, acc_in, mult_result, acc_out);
        end
        
        // Wait a few clock cycles for final results to propagate
        #100;
        
        // Stop simulation after all cycles
        $stop;
    end
    
    // Monitor the outputs for every clock cycle
    initial begin
        $monitor("Time: %0t | a = %d, b = %d, acc_in = %d, mult_result = %d, acc_out = %d", 
                 $time, a, b, acc_in, mult_result, acc_out);
    end
endmodule
