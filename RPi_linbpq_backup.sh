#!/bin/bash

# LinBPQ Backup Script
# This script backs up LinBPQ, retains only the last 10 backups, and optionally syncs to cloud storage using rclone.
# Adapted from a script by Robin (M0JQQ).

set -e  # Exit immediately if any command exits with a non-zero status.

# Variables
DESDIR=~/bpq-backup                     # Destination directory for backups
LOGFILE=$DESDIR/bpq-backup.log          # Log file path
CLOUD_TARGET=onedrive:/Backups/LinBPQ   # Cloud storage target for rclone
RETENTION_COUNT=10                      # Number of backups to retain
SRCDIR=/opt/oarc/bpq/                   # Source directory to back up
BPQCFG=/etc/bpq32.cfg                   # LinBPQ configuration file to include
FILE=bpq_$(date +%Y%m%d_%H%M%S).tar.gz  # Backup file name with timestamp

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOGFILE
}

# Ensure the destination directory exists
mkdir -p $DESDIR || { log "Failed to create backup directory $DESDIR"; exit 1; }

log "Starting backup process."

# Check available disk space (require at least 512MB free)
AVAILABLE_SPACE=$(df $DESDIR | awk 'NR==2 {print $4}')
if (( AVAILABLE_SPACE < 512 )); then
    log "Insufficient disk space for backup. Exiting."
    exit 1
fi

# Stop BPQ service to ensure consistency
log "Stopping BPQ service."
if sudo systemctl stop linbpq.service; then
    log "BPQ service stopped successfully."
else
    log "Failed to stop BPQ service. Exiting."
    exit 1
fi

# Create the backup
log "Creating backup."
sudo tar --exclude='*.sock' -caf $DESDIR/$FILE $SRCDIR $BPQCFG || { log "Backup failed."; exit 1; }

# Retain only the last $RETENTION_COUNT backups
log "Deleting old backups, keeping the last $RETENTION_COUNT."
ls -1t $DESDIR/bpq*.tar.gz | tail -n +$((RETENTION_COUNT + 1)) | xargs rm -f && log "Old backups deleted successfully."

# Restart BPQ service
log "Restarting BPQ service."
if sudo systemctl start linbpq.service; then
    log "BPQ service started successfully."
else
    log "Failed to start BPQ service."
fi

# Sync to cloud storage using rclone if available
if command -v rclone &> /dev/null; then
    log "Starting cloud sync."
    if rclone sync $DESDIR $CLOUD_TARGET --progress; then
        log "Rclone sync to $CLOUD_TARGET completed successfully."
    else
        log "Rclone sync failed. Exiting."
        exit 1
    fi
else
    log "Rclone not found. Skipping cloud sync."
fi

log "Backup process completed successfully."