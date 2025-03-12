module ApproxMAC(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input [15:0] AccIn, // Changed to 16-bit to match accumulation width
    output reg [15:0] AccOut,
    output [15:0] mult_result // Add this output for mult_result
);

    reg [15:0] mult_reg;    // Store multiplication result
    reg [15:0] acc_reg;     // Store accumulation result
    
    wire [15:0] acc_result;
    wire cout;

    // Approximate multiplier
    dadda_PPAM_1_3 multiplier (
        .A(A),
        .B(B),
        .P(mult_result)  // This should drive the mult_result wire
    );

    // Pipeline stage 1: Register multiplication result
    always @(posedge clk or posedge rst) begin
        if (rst)
            mult_reg <= 0;
        else
            mult_reg <= mult_result;
    end

    // Approximate adder: Add previous acc_out to new multiplication result
    LowerApproxCLA adder (
        .a(mult_reg[7:0]),
        .b(acc_reg[7:0]),  // Accumulate previous stored value
        .sum(acc_result[7:0]),
        .cout(cout)
    );

    assign acc_result[15:8] = mult_reg[15:8] + acc_reg[15:8] + cout;

    // Pipeline stage 2: Register accumulation result
    always @(posedge clk or posedge rst) begin
        if (rst)
            acc_reg <= 0;
        else
            acc_reg <= acc_result;
    end

    // Final pipeline stage: Output the accumulated value
    always @(posedge clk or posedge rst) begin
        if (rst)
            AccOut <= 0;
        else
            AccOut <= acc_reg;  // Store accumulated value
    end

endmodule
