`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Amaan Mujawar 
// 
// Create Date: 10/23/2024 02:36:09 PM
// Design Name: 32-Bit Pipeline MAC module
// Module Name: mac32Bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Implementing an 32-Bit mac module
module mac32Bit(
    input clk, // Clock input
    input rst_n, // Negated reset input
    input [31:0] a, // First 32-bit input
    input [31:0] b, // Second 32-bit input
    input [63:0] acc_in, // 64-bit accumulator input
    output reg [63:0] acc_out // 64-bit accumulator output
    );
    
    // Pipeline registers
    reg [31:0] a_reg, b_reg;
    reg [63:0] mult_reg, add_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            // Reset all registers
            a_reg <= 0;
            b_reg <= 0;
            mult_reg <= 0;
            add_reg <= 0;
            acc_out <= 0;
        end else begin
            // Stage 1: Register the inputs
            a_reg <= a;
            b_reg <= b;
            
            // Stage 2: Multiply the inputs
            mult_reg <= a_reg * b_reg;
            
            // Stage 3: Add the result to the accumulator
            add_reg <= mult_reg + acc_in;
            
            // Output the final accumulated value
            acc_out <= add_reg;
        end
    end
endmodule
