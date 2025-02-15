`timescale 1ns / 1ps

module Testbench_LowerApproxCLA;
    // Testbench variables
    reg [7:0] a, b;
    wire [7:0] sum;
    wire cout;
    
    integer file; // File handle
    integer i; // Loop counter

    // Instantiate the module under test
    LowerApproxCLA UUT (
        .sum(sum),
        .cout(cout),
        .a(a),
        .b(b)
    );

    // Test vector procedure
    initial begin
        // Open the file for appending (this prevents it from being overwritten)
        file = $fopen("test_vectors.txt", "a");

        // Check if the file was opened successfully
        if (file == 0) begin
            $display("Error opening the file.");
            $finish;
        end
        
        // Generate 1000 random test vectors
        for (i = 0; i < 1000; i = i + 1) begin
            // Generate random values for a and b (8-bit values)
            a = $random;
            b = $random;
            
            #10; // Wait for some time to allow the output to stabilize

            // Write the test vector to the file (append mode)
            $fdisplay(file, "%b %b %b %b", a, b, sum, cout);
        end

        // Close the file after all the test vectors are written
        $fclose(file);
        
        // End simulation
        $finish;
    end
endmodule
