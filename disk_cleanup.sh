#!/bin/bash

# Directories to monitor (space-separated)
MONITOR_DIRS=("/var/log" "/home/ec2-user/dev1/centralrepo/git-work")  # change as needed

# Disk usage threshold in percentage (e.g., 80%)
THRESHOLD=80

# Log file for cleanup actions
LOGFILE="/var/log/disk_cleanup.log"

# Archive location
ARCHIVE_DIR="/tmp/old_logs_archive"
mkdir -p "$ARCHIVE_DIR"

# Check each directory
for DIR in "${MONITOR_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        USAGE=$(df -h "$DIR" | awk 'NR==2 {gsub("%",""); print $5}')
        
        echo "Checking usage for $DIR: $USAGE%" | tee -a "$LOGFILE"

        if [ "$USAGE" -gt "$THRESHOLD" ]; then
            TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$TIMESTAMP] Disk usage for $DIR exceeded $THRESHOLD%" | tee -a "$LOGFILE"

            # 1. Archive and compress old files (e.g., files not modified in last 10 days)
            find "$DIR" -type f -mtime +10 -print0 | while IFS= read -r -d '' file; do
                gzip -c "$file" > "$ARCHIVE_DIR/$(basename "$file").gz" && echo "Archived: $file" | tee -a "$LOGFILE"
            done

            # 2. Delete .log files older than 5 days
            find "$DIR" -name "*.log" -type f -mtime +5 -exec rm -v {} \; | tee -a "$LOGFILE"

            # 3. Send alert message
            echo "Alert: Disk usage in $DIR exceeded $THRESHOLD%. Cleanup performed." | tee -a "$LOGFILE"

            # (Optional) You can replace the console message with a mail command like:
            # echo "Disk usage alert for $DIR" | mail -s "Disk Usage Alert" you@example.com
        fi
    else
        echo "Directory $DIR does not exist." | tee -a "$LOGFILE"
    fi
done
