from tabulate import tabulate

# Function to compare the expected and calculated results
def read_test_vectors(file_path):
    test_vectors = []
    with open(file_path, 'r') as file:
        for line in file:
            # Each line contains a test vector: a, b, sum, cout
            vector = line.strip().split()
            a = vector[0]
            b = vector[1]
            sum_val = vector[2]
            cout = vector[3]
            test_vectors.append((a, b, sum_val, cout))
    return test_vectors

# Function to perform the OR addition on the lower 4 bits and return carry
def or_addition(a, b):
    # Extract the lower 4 bits
    a_low = int(a[-4:], 2)
    b_low = int(b[-4:], 2)
    
    # OR-based approximation for the lower 4 bits
    sum_low = a_low | b_low
    
    # Calculate carry like in the Verilog code: if both MSBs are 1
    carry_low = (a_low & b_low & 0b1000) >> 3  # Check if both MSBs are 1
    
    # Return the 4-bit binary sum and the carry
    return bin(sum_low)[2:].zfill(4), carry_low

# Function to perform accurate addition on the upper part with carry from the lower part
def accurate_addition(a, b, carry_in):
    a_high = int(a[:-4], 2) if a[:-4] else 0  # Extract the upper bits
    b_high = int(b[:-4], 2) if b[:-4] else 0  # Extract the upper bits
    sum_high = a_high + b_high + carry_in  # Add carry_in to the sum of the upper parts
    sum_high_bin = bin(sum_high)[2:].zfill(4)  # Get the sum as a binary string
    cout = (sum_high >> 4) & 1  # Carry out from the upper part
    return sum_high_bin[-4:], cout

# Main function to read test vectors and compare results
def process_test_vectors(file_path):
    test_vectors = read_test_vectors(file_path)
    table_data = []
    total_tests = len(test_vectors)
    passed_tests = 0
    failed_tests = 0

    for idx, (a, b, expected_sum, expected_cout) in enumerate(test_vectors):
        # Perform OR addition on lower 4 bits and get carry
        calculated_sum_low, carry_low = or_addition(a, b)
        
        # Perform accurate addition on the upper part with carry from the lower part
        calculated_sum_high, calculated_cout = accurate_addition(a, b, carry_low)
        
        # Combine the results and cap to 8 bits
        calculated_sum = (calculated_sum_high + calculated_sum_low)[-8:]
        
        # Compare expected vs calculated results
        sum_match = calculated_sum == expected_sum
        cout_match = str(calculated_cout) == expected_cout
        status = "Pass" if sum_match and cout_match else "Fail"
        
        # Color status
        if status == "Pass":
            status = f"\033[92m{status}\033[0m"  # Green
            passed_tests += 1
        else:
            status = f"\033[91m{status}\033[0m"  # Red
            failed_tests += 1

        # Color mismatched results
        if not sum_match:
            calculated_sum = f"\033[91m{calculated_sum}\033[0m"  # Red for mismatch
        if not cout_match:
            calculated_cout = f"\033[91m{calculated_cout}\033[0m"  # Red for mismatch
        
        # Color carry propagation
        carry_info = f"\033[94mPropagated\033[0m" if carry_low else "No"
        
        # Add the result to the table
        table_data.append([
            f"\033[93m{idx + 1}\033[0m",  # Yellow Test Number
            a, 
            b, 
            expected_sum, 
            expected_cout, 
            calculated_sum, 
            calculated_cout, 
            carry_info, 
            status
        ])
    
    # Highlighted Headers
    headers = ["Test #", "a", "b", "Expected Sum", "Expected Cout", 
               "Calculated Sum", "Calculated Cout", "Carry Propagation", 
               "Status"]
    headers = [f"\033[93m{h}\033[0m" for h in headers]  # Yellow headers

    # Print the results in a table format
    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    
    # Summary
    print("\nSummary:")
    print(f"Total Tests: {total_tests}")
    print(f"Passed: \033[92m{passed_tests}\033[0m")  # Green for Passed
    print(f"Failed: \033[91m{failed_tests}\033[0m")  # Red for Failed

# File path for test vectors
file_path = 'test_vectors.txt'
process_test_vectors(file_path)
