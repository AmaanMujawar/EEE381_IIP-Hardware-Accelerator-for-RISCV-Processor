module tb_dadda_PPAM_1_3;

  // Declare inputs as reg type since we will drive them in the testbench
  reg [7:0] A, B;
  
  // Declare output as wire since it will be driven by the design under test (DUT)
  wire [15:0] P;
  
  // Instantiate the design under test (DUT)
  dadda_PPAM_1_3 dut (
    .A(A), 
    .B(B), 
    .P(P)
  );

  // Declare file for storing binary data
  integer file;
  
  // Random number generation seed
  initial begin
    // Open the file in append mode to write raw binary data as text
    file = $fopen("random_results.txt", "a"); // Open file in append mode
    
    // Check if file is opened correctly
    if (file == 0) begin
      $display("Error opening file!");
      $finish;
    end
    
    // Initialize inputs
    A = 8'b00000000; 
    B = 8'b00000000; 
    
    // Apply random test cases
    $display("Generating 1000 random test cases...");
    
    // Run 1000 test cases
    for (integer i = 0; i < 1000; i = i + 1) begin
      A = $random;
      B = $random;
      
      // Wait for some time to allow the DUT to compute the result
      #10;
      
      // Append the inputs and output as raw binary data (8 bits for A, 8 bits for B, 16 bits for product)
      $fwrite(file, "%b %b %b\n", A, B, P);  // Write A, B, and P (16-bit) as binary values with spaces and newline
      
      // Optional: Monitor progress in the simulation log
      if (i % 100 == 0) begin
        $display("Test case %d completed.", i);
      end
    end
    
    // Finish simulation after generating 1000 random cases
    #10;
    $fclose(file);  // Close the file after writing all data
    $finish;
  end
  
endmodule
