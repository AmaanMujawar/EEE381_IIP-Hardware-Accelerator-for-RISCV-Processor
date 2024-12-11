`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Amaan Mujawar
// 
// Create Date: 10/23/2024 02:58:32 PM
// Design Name: 8-Bit Pipeline MAC TestBench
// Module Name: mac8Bit_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fixed testbench with synchronous feedback for acc_in.
// 
//////////////////////////////////////////////////////////////////////////////////

module mac8Bit_TB;
    reg clk;
    reg rst_n;
    reg [7:0] a;
    reg [7:0] b;
    reg [15:0] acc_in;
    wire [15:0] acc_out;
    
    // Instantiate the pipelined MAC module
    mac8Bit uut(
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .acc_in(acc_in),
        .acc_out(acc_out)
    );
    
    // Clock generation @ 50MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock -> 20ns period
    end
    
    // Simulate
    initial begin
        // Initialize inputs
        rst_n = 0;
        a = 0;
        b = 0;
        acc_in = 0;
        
        // Reset the module
        #20;
        rst_n = 1;
        
        // Test Case 1
        @(posedge clk); // Wait for a clock edge
        a = 8'd5;
        b = 8'd3;
        acc_in = 0; // Initialize accumulator

        // Test Case 2
        @(posedge clk); // Wait for the next clock edge
        a = 8'd10;
        b = 8'd4;
        acc_in = acc_out; // Update acc_in synchronously with the clock

        // Test Case 3
        @(posedge clk); // Wait for the next clock edge
        a = 8'd7;
        b = 8'd2;
        acc_in = acc_out; // Update acc_in synchronously with the clock

        // Wait a few clock cycles for final results
        #100;
        $stop;
    end
    
    // Monitor the outputs
    initial begin
        $monitor("Time: %0t | a = %d, b = %d, acc_in = %d, acc_out = %d",
            $time, a, b, acc_in, acc_out);
    end
endmodule
