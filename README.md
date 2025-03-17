# System Metrics and Cleanup Script

## Overview
This Bash script collects system metrics, clears caches, removes old log files, and generates a detailed report. The report is saved in a file named `report.txt`.

## Features
- Captures system metrics before and after cleanup.
- Clears system caches.
- Identifies top memory-consuming processes.
- Identifies the top space-consuming files.
- Deletes log files older than one week.

## Script Breakdown

### Variables
```bash
REPORT="report.txt"  # File to store the system metrics report
LOG_DIR="/var/log"  # Directory containing log files
```

### Capturing System Metrics
The `capture_metrics` function gathers system information including:
- Free memory
- CPU utilization
- Disk space usage

```bash
capture_metrics() {
    echo "=== $1 ===" >> "$REPORT"  # Section header
    echo "Free Memory:" >> "$REPORT"
    free -h >> "$REPORT"  # Displays memory status in a human-readable format
    echo "CPU Utilization:" >> "$REPORT"
    top -b -n1 | grep "Cpu(s)" >> "$REPORT"  # Extracts CPU usage summary
    echo "Disk Space Usage:" >> "$REPORT"
    df -h >> "$REPORT"  # Displays disk space usage
    echo "" >> "$REPORT"  # Adds a blank line for readability
}
```

### Pre-Cleanup Metrics
Before making any changes, the script captures system metrics:
```bash
capture_metrics "Before Clearing Caches and Logs"
```

### Clearing System Caches
```bash
echo "Clearing system caches..."
sudo su -c "free -h && sync && echo 3 > /proc/sys/vm/drop_caches && free -h" >> "$REPORT"
```
This clears:
- Page cache
- Dentries
- Inodes

### Identifying Top Memory-Consuming Processes
```bash
echo "=== Top 10 Memory-Consuming Processes ===" >> "$REPORT"
ps aux --sort=-%mem | head -n 10 >> "$REPORT"
```
Lists the top 10 processes consuming the most memory.

### Identifying Top Space-Consuming Files
```bash
echo "=== Top 10 Space-Consuming Files ===" >> "$REPORT"
find / -type f -exec du -h {} + | sort -rh | head -n 10 >> "$REPORT"
```
Finds the 10 largest files on the system.

### Removing Old Log Files
```bash
echo "Removing old log files..."
sudo find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec rm -rf {} \;
```
Deletes log files older than one week.

### Post-Cleanup Metrics
```bash
capture_metrics "After Clearing Caches and Old Logs"
```
Captures system metrics again after the cleanup.

### Processor Usage Summary
```bash
echo "=== Processor Usage ===" >> "$REPORT"
top -b -n1 | head -n 10 >> "$REPORT"
```
Displays a processor usage summary.

### Final Output Message
```bash
echo "Logs older than 1 week cleared. Caches cleared. Report saved to $REPORT."
```
Indicates the successful execution of the script.

## Usage
1. Save the script as `system_metrics.sh`.
2. Give execution permission:
   ```bash
   chmod +x system_metrics.sh
   ```
3. Run the script:
   ```bash
   sudo ./system_metrics.sh
   ``` 

## Notes
- The script requires `sudo` privileges to clear caches and delete logs.
- Be cautious when removing files, as incorrect modifications can delete important data.
- Modify `LOG_DIR` to target different log directories if necessary.

