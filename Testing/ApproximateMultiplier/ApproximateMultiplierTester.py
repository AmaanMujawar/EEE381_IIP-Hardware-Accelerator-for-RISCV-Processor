import numpy as np
from tabulate import tabulate
from collections import Counter

# Function to read binary test vectors from file and process them
def read_test_vectors(file_path):
    test_vectors = []
    with open(file_path, 'r') as file:
        for line in file:
            # Each line contains a test vector: A, B, Verilog Product
            vector = line.strip().split()
            a_bin = vector[0]
            b_bin = vector[1]
            verilog_p_bin = vector[2]
            test_vectors.append((a_bin, b_bin, verilog_p_bin))
    return test_vectors

# Function to calculate the exact product of A and B (exact multiplication)
def calculate_exact_product(a_bin, b_bin):
    # Convert binary strings to integers
    a_val = int(a_bin, 2)
    b_val = int(b_bin, 2)
    
    # Calculate the exact product
    p_exact = a_val * b_val
    
    # Convert the exact product to a 16-bit binary string
    p_bin = bin(p_exact)[2:].zfill(16)
    return p_bin

# Function to perform the multiplication of A and B and approximate the product
def calculate_calculated_product(a_bin, b_bin):
    # ! Needs implementation
    return calculate_exact_product(a_bin, b_bin)

# Function to process the test vectors and compare results
def process_test_vectors(file_path):
    test_vectors = read_test_vectors(file_path)
    table_data = []
    total_tests = len(test_vectors)
    passed_tests = 0
    failed_tests = 0
    differences = []

    # For error metrics
    abs_errors = []
    rel_errors = []
    non_zero_errors = []

    for idx, (a_bin, b_bin, verilog_p_bin) in enumerate(test_vectors):
        exact_p_bin = calculate_exact_product(a_bin, b_bin)
        calculated_p_bin = calculate_calculated_product(a_bin, b_bin)

        exact_val = int(exact_p_bin, 2)
        verilog_val = int(verilog_p_bin, 2)

        diff = verilog_val - exact_val
        differences.append(diff)
        abs_errors.append(abs(diff))
        non_zero_errors.append(1 if diff != 0 else 0)

        # Avoid divide-by-zero for relative error
        rel_error = abs(diff) / exact_val if exact_val != 0 else 0
        rel_errors.append(rel_error)

        p_match = calculated_p_bin == exact_p_bin
        status = "Pass" if p_match else "Fail"

        if status == "Pass":
            status = f"\033[92m{status}\033[0m"
            passed_tests += 1
        else:
            status = f"\033[91m{status}\033[0m"
            failed_tests += 1

        if diff == 0:
            diff_color = "\033[92m"
        elif -3 <= diff <= 3:
            diff_color = "\033[96m"
        elif -6 <= diff <= -4 or 4 <= diff <= 6:
            diff_color = "\033[95m"
        else:
            diff_color = "\033[91m"

        table_data.append([
            f"\033[93m{idx + 1}\033[0m",
            a_bin, 
            b_bin, 
            verilog_p_bin,
            calculated_p_bin,
            exact_p_bin,
            status,
            f"{diff_color}{diff}\033[0m"
        ])
    
    headers = ["Test #", "A (binary)", "B (binary)", "Verilog Product", 
               "Calculated Product", "Exact Product", "Status", "Difference"]
    headers = [f"\033[93m{h}\033[0m" for h in headers]
    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    
    print("\nSummary:")
    print(f"Total Tests: {total_tests}")
    print(f"Passed: \033[92m{passed_tests}\033[0m")
    print(f"Failed: \033[91m{failed_tests}\033[0m")

    diff_counter = Counter(differences)
    diff_table = []
    for diff, freq in sorted(diff_counter.items()):
        percentage = (freq / total_tests) * 100
        if diff == 0:
            color = "\033[92m"
        elif -3 <= diff <= 3:
            color = "\033[96m"
        elif -6 <= diff <= -4 or 4 <= diff <= 6:
            color = "\033[95m"
        else:
            color = "\033[91m"
        diff_table.append([
            f"{color}{diff}\033[0m", 
            freq, 
            f"{color}{percentage:.2f}%\033[0m"
        ])
    print("\nDifference Analysis:")
    print(tabulate(diff_table, headers=["Difference", "Frequency", "Percentage"], tablefmt="grid"))

    # Final error metrics
    mae = np.mean(abs_errors)
    mre = np.mean(rel_errors)
    wce = max(abs_errors)
    error_rate = (sum(non_zero_errors) / total_tests) * 100

    print("\nError Metrics:")
    print(f"Mean Absolute Error (MAE): {mae:.4f}")
    print(f"Mean Relative Error (MRE): {mre:.4f}")
    print(f"Worst Case Error (WCE): {wce}")
    print(f"Error Rate: {error_rate:.2f}%")

# File path for test vectors
file_path = 'test_vectors.txt'
process_test_vectors(file_path)
