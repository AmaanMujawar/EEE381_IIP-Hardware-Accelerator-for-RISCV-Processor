module ApproxMAC(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input [15:0] AccIn,
    output reg [15:0] AccOut,
    output [15:0] mult_result
);

    reg [15:0] mult_reg;
    reg [15:0] acc_reg;
    wire [15:0] acc_result;
    wire cout;
    
    // LUT for fuzzy memoization (storing recent computations)
    reg [7:0] lut_A [0:3];
    reg [7:0] lut_B [0:3];
    reg [15:0] lut_P [0:3];
    reg [1:0] lut_index;
    reg match_found;
    reg [15:0] fuzzy_result;

    integer i;

    // Check LUT for approximate match
    always @(*) begin
        match_found = 0;
        fuzzy_result = 0;
        for (i = 0; i < 4; i = i + 1) begin
            // Relaxing the match condition slightly
            if ((A - lut_A[i]) < 2 && (B - lut_B[i]) < 2) begin
                match_found = 1;
                fuzzy_result = lut_P[i];
            end
        end
    end

    // Approximate multiplier with fuzzy memoization
    wire [15:0] computed_mult;
    dadda_PPAM_1_3 multiplier (
        .A(A),
        .B(B),
        .P(computed_mult)
    );

    assign mult_result = match_found ? fuzzy_result : computed_mult;

    // Update LUT if no match found
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                lut_A[i] <= 0;
                lut_B[i] <= 0;
                lut_P[i] <= 0;
            end
            lut_index <= 0;
        end else if (!match_found) begin
            lut_A[lut_index] <= A;
            lut_B[lut_index] <= B;
            lut_P[lut_index] <= computed_mult;
            lut_index <= lut_index + 1;
            if (lut_index == 3) begin
                lut_index <= 0;  // Wrap around to index 0
            end
        end
    end

    // Pipeline stage 1: Register multiplication result
    always @(posedge clk or posedge rst) begin
        if (rst)
            mult_reg <= 0;
        else
            mult_reg <= mult_result;
    end

    // Approximate adder
    LowerApproxCLA adder (
        .a(mult_reg[7:0]),
        .b(acc_reg[7:0]),
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
            AccOut <= acc_reg;
    end

endmodule
