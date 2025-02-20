import subprocess
import datetime
from tabulate import tabulate

# Function to run git command and return output
def run_git_command(command):
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip().splitlines()

# Function to get the latest branch (most up-to-date branch)
def get_latest_branch():
    command = ['git', 'branch', '--sort=-committerdate']
    branches = run_git_command(command)
    
    if branches:
        # The first branch in the list will be the latest branch by commit date
        latest_branch = branches[0].strip('* ').strip()
        return latest_branch
    return None

# ANSI Escape Code Colors (for terminal display)
COLORS = {
    "reset": "\033[0m",
    "cyan": "\033[36m",
    "green": "\033[32m",
    "yellow": "\033[33m",  # Yellow for commit numbers
    "red": "\033[31m",
    "blue": "\033[34m",
    "magenta": "\033[35m",
    "white": "\033[37m",
    "bold": "\033[1m"
}

# Function to get all commits except merges from a specific branch
def get_commits(branch):
    # Use a unique delimiter '|' to separate fields
    command = [
        'git', 'log', '--no-merges',
        '--pretty=format:%H|%s|%an|%ad',
        '--date=iso', branch
    ]
    commits = run_git_command(command)
    
    commit_details = []
    
    for i, commit in enumerate(commits, 1):
        # Split the commit string by the delimiter '|'
        commit_parts = commit.split('|')
        
        if len(commit_parts) < 4:
            continue
        
        commit_hash = commit_parts[0]
        commit_message = commit_parts[1]
        author_name = commit_parts[2]
        commit_date = commit_parts[3]
        
        try:
            # Parse the ISO 8601 date format
            commit_date = datetime.datetime.strptime(
                commit_date.strip(), "%Y-%m-%d %H:%M:%S %z"
            ).strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            commit_date = "Invalid Date Format"
        
        # Apply colors using ANSI escape codes for terminal display
        commit_number_colored = COLORS["yellow"] + str(i) + COLORS["reset"]
        commit_hash_colored = COLORS["cyan"] + commit_hash + COLORS["reset"]
        commit_message_colored = COLORS["green"] + commit_message + COLORS["reset"]
        author_name_colored = COLORS["yellow"] + author_name + COLORS["reset"]
        commit_date_colored = COLORS["magenta"] + commit_date + COLORS["reset"]
        
        # Append the commit details without colors for file output
        commit_details.append([
            str(i), commit_hash, commit_message,
            author_name, commit_date
        ])
    
    return commit_details

# Function to generate a clean table of commits for the most up-to-date branch
def generate_commit_table():
    latest_branch = get_latest_branch()
    
    if latest_branch:
        print(f"Fetching commits from the latest branch: {latest_branch}")
        commits = get_commits(latest_branch)
        
        # Define headers
        headers = ['Commit #', 'Commit Hash', 'Commit Message', 'Author', 'Commit Date']
        
        # Define column alignments: 'left' for 'Commit Message', 'center' for others
        colalign = ('center', 'center', 'left', 'center', 'center')
        
        # Generate table for terminal display with colors
        table_with_colors = tabulate(
            [[COLORS["yellow"] + str(i) + COLORS["reset"],
              COLORS["cyan"] + commit_hash + COLORS["reset"],
              COLORS["green"] + commit_message + COLORS["reset"],
              COLORS["yellow"] + author_name + COLORS["reset"],
              COLORS["magenta"] + commit_date + COLORS["reset"]]
             for i, commit_hash, commit_message, author_name, commit_date in commits],
            headers=[COLORS["blue"] + COLORS["bold"] + header + COLORS["reset"] for header in headers],
            tablefmt='simple', numalign="center", stralign=colalign
        )
        
        # Print the colored table to the terminal
        print(table_with_colors)
        
        # Generate table without colors for file output
        table_without_colors = tabulate(
            commits,
            headers=headers,
            tablefmt='simple', numalign="center", stralign=colalign
        )
        
        # Write the table to a log.txt file
        with open('log.txt', 'w') as file:
            file.write(table_without_colors)
    else:
        print("No branches found or unable to fetch branches.")


# Run the function to generate and print the commit table
if __name__ == "__main__":
    generate_commit_table()
