`timescale 1ns / 1ps

module approx_mac8Bit_TB;
    reg clk;
    reg rst;
    reg [7:0] a;
    reg [7:0] b;
    reg [15:0] acc_in;
    wire [15:0] acc_out;
    wire [15:0] mult_result;
    
    reg memoization_used;
    reg [15:0] last_mult_result;

    // Instantiate the approximate MAC module
    ApproxMAC uut (
        .clk(clk),
        .rst(rst),
        .A(a),
        .B(b),
        .AccIn(acc_in),
        .AccOut(acc_out),
        .mult_result(mult_result)
    );
    
    integer i;
    // Clock generation @ 50MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Simulate
    initial begin
        // Initialize inputs
        rst = 1;
        a = 0;
        b = 0;
        acc_in = 0;
        last_mult_result = 0;
        memoization_used = 0;
        
        // Apply reset
        #20;
        rst = 0;
        
        // Step 1: Provide distinct values to populate LUT
        // Providing some initial values to populate the LUT
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            a = i * 10;  // 0, 10, 20, 30
            b = i * 15;  // 0, 15, 30, 45
            acc_in = acc_out;
            last_mult_result = mult_result;
            memoization_used = 0;
            
            // Wait for LUT to populate
            #10;
        end

        // Display LUT contents after Step 1 (populating LUT)
        $display("LUT Contents after populating:");
        $display("LUT_A[0] = %d, LUT_A[1] = %d, LUT_A[2] = %d, LUT_A[3] = %d", 
                 uut.lut_A[0], uut.lut_A[1], uut.lut_A[2], uut.lut_A[3]);
        $display("LUT_B[0] = %d, LUT_B[1] = %d, LUT_B[2] = %d, LUT_B[3] = %d", 
                 uut.lut_B[0], uut.lut_B[1], uut.lut_B[2], uut.lut_B[3]);
        $display("LUT_P[0] = %d, LUT_P[1] = %d, LUT_P[2] = %d, LUT_P[3] = %d", 
                 uut.lut_P[0], uut.lut_P[1], uut.lut_P[2], uut.lut_P[3]);

        // Step 2: Provide approximate values to trigger fuzzy memoization
        // Check how fuzzy memoization behaves with small changes
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            // Provide values close to the ones previously given (small variations)
            a = (i * 10) + 1; // Small variation from stored values (e.g., 1, 11, 21, 31)
            b = (i * 15) + 1; // Small variation from stored values (e.g., 1, 16, 31, 46)
            acc_in = acc_out;

            // Check if memoization is used
            if (mult_result == last_mult_result) begin
                memoization_used = 1;
            end else begin
                memoization_used = 0;
            end
            
            // Display results to verify memoization is used
            $display("Cycle %0d: a = %d, b = %d, acc_in = %d, mult_result = %d, acc_out = %d, Memoization Used: %b", 
                     i, a, b, acc_in, mult_result, acc_out, memoization_used);
            
            last_mult_result = mult_result;
        end
        
        // Display LUT contents after Step 2 (approximate values with memoization)
        $display("LUT Contents after approximate matching:");
        $display("LUT_A[0] = %d, LUT_A[1] = %d, LUT_A[2] = %d, LUT_A[3] = %d", 
                 uut.lut_A[0], uut.lut_A[1], uut.lut_A[2], uut.lut_A[3]);
        $display("LUT_B[0] = %d, LUT_B[1] = %d, LUT_B[2] = %d, LUT_B[3] = %d", 
                 uut.lut_B[0], uut.lut_B[1], uut.lut_B[2], uut.lut_B[3]);
        $display("LUT_P[0] = %d, LUT_P[1] = %d, LUT_P[2] = %d, LUT_P[3] = %d", 
                 uut.lut_P[0], uut.lut_P[1], uut.lut_P[2], uut.lut_P[3]);

        // Step 3: Provide values that are a larger variation to avoid memoization
        // Provide larger variations to show no fuzzy memoization occurs
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            // Provide a larger variation
            a = (i * 10) + 5; // Larger change (e.g., 5, 15, 25, 35)
            b = (i * 15) + 5; // Larger change (e.g., 5, 20, 35, 50)
            acc_in = acc_out;

            // Ensure no memoization is used since the variation is larger
            if (mult_result == last_mult_result) begin
                memoization_used = 1;
            end else begin
                memoization_used = 0;
            end
            
            // Display results showing no memoization
            $display("Cycle %0d: a = %d, b = %d, acc_in = %d, mult_result = %d, acc_out = %d, Memoization Used: %b", 
                     i, a, b, acc_in, mult_result, acc_out, memoization_used);
            
            last_mult_result = mult_result;
        end

        // Display final LUT contents
        $display("Final LUT Contents:");
        $display("LUT_A[0] = %d, LUT_A[1] = %d, LUT_A[2] = %d, LUT_A[3] = %d", 
                 uut.lut_A[0], uut.lut_A[1], uut.lut_A[2], uut.lut_A[3]);
        $display("LUT_B[0] = %d, LUT_B[1] = %d, LUT_B[2] = %d, LUT_B[3] = %d", 
                 uut.lut_B[0], uut.lut_B[1], uut.lut_B[2], uut.lut_B[3]);
        $display("LUT_P[0] = %d, LUT_P[1] = %d, LUT_P[2] = %d, LUT_P[3] = %d", 
                 uut.lut_P[0], uut.lut_P[1], uut.lut_P[2], uut.lut_P[3]);

        // Wait for final propagation
        #100;
        $stop;
    end

    // Monitor values at each clock cycle
    initial begin
        $monitor("Time: %0t | a = %d, b = %d, acc_in = %d, mult_result = %d, acc_out = %d, Memoization Used: %b", 
                 $time, a, b, acc_in, mult_result, acc_out, memoization_used);
    end
endmodule
