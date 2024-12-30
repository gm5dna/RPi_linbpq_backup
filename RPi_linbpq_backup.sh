#!/bin/bash

# This script was adapted from one by Robin (M0JQQ) and performs a backup of LinBPQ, 
# removes old backups (keeping only the last 10 backups), and optionally syncs the backups 
# to cloud storage (using rclone). It also ensures that the backup process is logged and 
# that the BPQ service is properly stopped and restarted during the backup.

# You will need to modify some of the variables (typically DESDIR and CLOUD_TARGET) to 
# suit your personal circumstances.

# Once set up, schedule the script to run daily using `crontab -e` and add a line similar 
# to this to run the script daily at 0100 hrs: 
# `0 1 * * * /bin/bash ~/RPi_linbpq_backup/RPi_linbpq_backup.sh`

# Set up
set -e  # Exit immediately if any command exits with a non-zero status.

# Variables:
# DESDIR: The destination directory where backups will be stored (could be an SMB share)
# LOGFILE: The location of the log file that records the backup process.
# CLOUD_TARGET: The target location for cloud backup using rclone
# RETENTION_COUNT: The number of backups to retain (default: 10 backups).
# SRCDIR: The source directory that contains the files to be backed up.
# BPQCFG: The LinBPQ configuration file (bpq32.cfg) to be included in the backup.
# FILE: The name of the backup file to be created, based on the current date and time (YYYYMMDD_HHMMSS).

DESDIR=~/bpq-backup
LOGFILE=$DESDIR/bpq-backup.log
CLOUD_TARGET=onedrive:/Backups/LinBPQ
RETENTION_COUNT=10
SRCDIR=/opt/oarc/bpq/
BPQCFG=/etc/bpq32.cfg
FILE=bpq_$(date +%Y%m%d_%H%M%S).tar.gz

# Logging function to write log messages with timestamps to the log file
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOGFILE
}

# Ensure destination directory exists (create if it doesn't exist)
mkdir -p $DESDIR || { log "Failed to create backup directory $DESDIR"; exit 1; }

log "Starting backup process."

# Check available disk space in the destination directory (ensure at least 512MB free)
AVAILABLE_SPACE=$(df $DESDIR | awk 'NR==2 {print $4}')
if (( AVAILABLE_SPACE < 512 )); then
    log "Insufficient disk space for backup. Exiting."
    exit 1
fi

# Stop the BPQ service before creating the backup to ensure consistency
log "Stopping BPQ service."
if sudo systemctl stop linbpq.service; then
    log "BPQ service stopped successfully."
else
    log "Failed to stop BPQ service, exiting."
    exit 1
fi

# Create the backup by archiving the source directory and configuration file
log "Creating backup."
sudo tar --exclude='*.sock' -caf $DESDIR/$FILE $SRCDIR $BPQCFG || { log "Backup failed"; exit 1; }

# Delete backups exceeding the retention count (keep only the last 10 backups)
log "Deleting backups beyond the last $RETENTION_COUNT backups."
ls -1t $DESDIR/bpq*.tar.gz | tail -n +$((RETENTION_COUNT + 1)) | xargs rm -f && log "Old backups deleted successfully."

# Restart the BPQ service after the backup is completed
log "Restarting BPQ service."
if sudo systemctl start linbpq.service; then
    log "BPQ service started successfully."
else
    log "Failed to start BPQ service"
fi

# Sync the backup directory to cloud storage if rclone is installed
if command -v rclone &> /dev/null; then
    log "Starting cloud sync."
    if rclone sync $DESDIR $CLOUD_TARGET --progress; then
        log "Rclone sync to $CLOUD_TARGET completed successfully."
    else
        log "Rclone sync failed."
        exit 1
    fi
else
    log "Rclone not found; skipping cloud sync."
fi

log "Backup process completed successfully."