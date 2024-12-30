#!/bin/bash

# Variables
DESDIR=~/bpq-backup                       # Local backup destination directory
LOGFILE=$DESDIR/bpq-backup.log            # Log file location
CLOUD_TARGET=onedrive:/Backups/LinBPQ     # Cloud backup target (default: OneDrive)
RETENTION_DAYS=10                         # Number of days to retain backups
SRCDIR=/opt/oarc/bpq/                     # Source directory for backup
BPQCFG=/etc/bpq32.cfg                     # Configuration file for backup
DATESHORT=$(date +%Y%m%d)                  # Current date in YYYYMMDD format
REMOVEDATE=$(date --date="10 days ago" +%Y%m%d) # Date for cleanup
FILE=bpq$DATESHORT.tar.gz                  # Backup file name
REMOVEFILE=bpq$REMOVEDATE.tar.gz           # File name to remove

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOGFILE
}

log "Starting backup process."

# Stop BPQ service
sudo systemctl stop linbpq.service || { log "Failed to stop linbpq.service"; exit 1; }

# Create backup
sudo tar --transform='s,^/,,' --exclude='*.sock' -cpzf $DESDIR/$FILE $SRCDIR $BPQCFG || { log "Backup failed"; exit 1; }

# Delete old backups
sudo rm $DESDIR/$REMOVEFILE > /dev/null 2>&1 && log "Deleted old backup: $REMOVEFILE"

# Restart BPQ service
sudo systemctl start linbpq.service || log "Failed to start linbpq.service"

# Sync to cloud (optional)
if command -v rclone &> /dev/null; then
    rclone sync $DESDIR $CLOUD_TARGET --progress || log "Rclone sync failed"
    log "Rclone sync to $CLOUD_TARGET completed successfully."
else
    log "Rclone not found; skipping cloud sync."
fi

log "Backup process completed successfully."