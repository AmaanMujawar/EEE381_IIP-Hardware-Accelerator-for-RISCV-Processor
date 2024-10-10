def write_log_to_file(week_of, activities_this_week, activities_next_week, signature, filename='log.txt'):
    with open(filename, 'a') as file:
        file.write(f'Week of: {week_of}\n\n')
        
        file.write('THIS WEEK\'S ACTIVITIES:\n')
        for date, description in activities_this_week:
            file.write(f'  - {date}: {description}\n')
        
        file.write('\nNEXT WEEK\'S PLAN:\n')
        for date, activity in activities_next_week:
            file.write(f'  - {date}: {activity}\n')
        
        file.write(f'\nSIGNATURE: {signature}\n')
        file.write('\n' + '-'*40 + '\n')

# Example usage
week_of = "Sept 30 - Oct 4, 2024"
activities_this_week = [
    ("Oct 1", "Researched existing hardware accelerators."),
    ("Oct 2", "Designed initial schematic for the accelerator."),
    ("Oct 3", "Ordered necessary components for prototype."),
    ("Oct 4", "Began coding for control logic."),
    ("Oct 5", "Reviewed literature on RISCV architecture."),
]
activities_next_week = [
    ("Oct 8", "Continue coding for control logic."),
    ("Oct 9", "Start assembling the prototype hardware."),
    ("Oct 10", "Test the initial design and make adjustments."),
    ("Oct 11", "Document findings and prepare for review."),
    ("Oct 12", "Meet with supervisor for project feedback."),
]
signature = "Amaan Mujawar"

# Write the log to the file
write_log_to_file(week_of, activities_this_week, activities_next_week, signature)

# Optional: Print to console
with open('log.txt', 'r') as file:
    print(file.read())