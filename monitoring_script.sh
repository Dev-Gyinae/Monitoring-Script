#!/bin/bash

REPORT="report.txt"  # File to store the system metrics report
LOG_DIR="/var/log"  # Directory containing log files (modify if needed)

# Start report with a timestamp
echo "System Metrics Report - $(date)" > "$REPORT"

# Function to capture system metrics
capture_metrics() {
    echo "=== $1 ===" >> "$REPORT"  # Section header for readability
    echo "Free Memory:" >> "$REPORT"
    free -h >> "$REPORT"  # Display free and used memory in a human-readable format
    echo "CPU Utilization:" >> "$REPORT"
    top -b -n1 | grep "Cpu(s)" >> "$REPORT"  # Extract CPU usage summary
    echo "Disk Space Usage:" >> "$REPORT"
    df -h >> "$REPORT"  # Show disk space usage in a human-readable format
    echo "" >> "$REPORT"  # Add a blank line for readability
}

# Capture system metrics before cleanup
capture_metrics "Before Clearing Caches and Logs"

# Clear system caches
echo "Clearing system caches..."
sudo su -c "free -h && sync && echo 3 > /proc/sys/vm/drop_caches && free -h" >> "$REPORT"
# `sync` ensures pending disk writes are completed before clearing caches
# `echo 3 > /proc/sys/vm/drop_caches` clears page cache, dentries, and inodes
# The second `free -h` checks the memory status after clearing caches

# Check top memory-consuming processes
echo "=== Top 10 Memory-Consuming Processes ===" >> "$REPORT"
ps aux --sort=-%mem | head -n 10 >> "$REPORT"
# `ps aux` lists all running processes with resource usage
# `--sort=-%mem` sorts them by memory usage (descending order)
# `head -n 10` limits the output to the top 10 processes

# Check top space-consuming files
echo "=== Top 10 Space-Consuming Files ===" >> "$REPORT"
find / -type f -exec du -h {} + | sort -rh | head -n 10 >> "$REPORT"
# `find / -type f` finds all files in the system
# `-exec du -h {} +` calculates their sizes in human-readable format
# `sort -rh` sorts results by size in descending order
# `head -n 10` limits output to the top 10 largest files

# Remove log files older than 1 week
echo "Removing old log files..."
sudo find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec rm -rf {} \;
# `find "$LOG_DIR" -type f -name "*.log"` finds log files
# `-mtime +7` selects files older than 7 days
# `-exec rm -rf {} \;` deletes them

# Capture system metrics after cleanup
capture_metrics "After Clearing Caches and Old Logs"

# Display processor usage
echo "=== Processor Usage ===" >> "$REPORT"
top -b -n1 | head -n 10 >> "$REPORT"
# `top -b -n1` runs `top` in batch mode, capturing only one iteration
# `head -n 10` limits output to the first 10 lines (includes CPU usage summary)

echo "Logs older than 1 week cleared. Caches cleared. Report saved to $REPORT."

