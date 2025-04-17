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

    for idx, (a_bin, b_bin, verilog_p_bin) in enumerate(test_vectors):
        # Calculate the exact product
        exact_p_bin = calculate_exact_product(a_bin, b_bin)
        
        # Calculate the product using the algorithm (calculated product)
        calculated_p_bin = calculate_calculated_product(a_bin, b_bin)
        
        # Calculate the difference between the Verilog Product and the Exact Product
        diff = int(verilog_p_bin, 2) - int(exact_p_bin, 2)
        differences.append(diff)
        
        # Compare Verilog product vs exact product
        p_match = calculated_p_bin == exact_p_bin
        status = "Pass" if p_match else "Fail"
        
        # Color status
        if status == "Pass":
            status = f"\033[92m{status}\033[0m"  # Green
            passed_tests += 1
        else:
            status = f"\033[91m{status}\033[0m"  # Red
            failed_tests += 1
        
        # Color differences
        diff_color = ""
        if diff == 0:
            diff_color = "\033[92m"  # Green for Zero Error
        elif -3 <= diff <= 3:
            diff_color = "\033[96m"  # Cyan for Small Errors
        elif -6 <= diff <= -4 or 4 <= diff <= 6:
            diff_color = "\033[95m"  # Magenta for Moderate Errors
        else:
            diff_color = "\033[91m"  # Red for Larger Errors
        
        # Add the result to the table
        table_data.append([
            f"\033[93m{idx + 1}\033[0m",  # Yellow Test Number
            a_bin, 
            b_bin, 
            verilog_p_bin,  # Verilog Product
            calculated_p_bin,  # Calculated Product
            exact_p_bin,  # Exact Product
            status,
            f"{diff_color}{diff}\033[0m"
        ])
    
    # Highlighted Headers
    headers = ["Test #", "A (binary)", "B (binary)", "Verilog Product", 
               "Calculated Product", "Exact Product", "Status", "Difference"]
    headers = [f"\033[93m{h}\033[0m" for h in headers]  # Yellow headers

    # Print the results in a table format
    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    
    # Summary
    print("\nSummary:")
    print(f"Total Tests: {total_tests}")
    print(f"Passed: \033[92m{passed_tests}\033[0m")  # Green for Passed
    print(f"Failed: \033[91m{failed_tests}\033[0m")  # Red for Failed

    # Difference Analysis
    diff_counter = Counter(differences)
    diff_table = []

    for diff, freq in sorted(diff_counter.items()):
        percentage = (freq / total_tests) * 100
        color = ""
        if diff == 0:
            color = "\033[92m"  # Green for Zero Error
        elif -3 <= diff <= 3:
            color = "\033[96m"  # Cyan for Small Errors
        elif -6 <= diff <= -4 or 4 <= diff <= 6:
            color = "\033[95m"  # Magenta for Moderate Errors
        else:
            color = "\033[91m"  # Red for Larger Errors
        
        diff_table.append([
            f"{color}{diff}\033[0m", 
            freq, 
            f"{color}{percentage:.2f}%\033[0m"
        ])
    
    print("\nDifference Analysis:")
    print(tabulate(diff_table, headers=["Difference", "Frequency", "Percentage"], tablefmt="grid"))

# File path for test vectors
file_path = 'test_vectors.txt'
process_test_vectors(file_path)
