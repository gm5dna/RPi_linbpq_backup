#!/bin/bash
#
#    bpqbackup.sh
#    ============
#
# Daily BPQ backup from /opt/oarc/bpq/ to local network samba share
# Each backup is date stamped and retained for a rolling 10 days
#
DATESHORT=`date +%Y%m%d`                                                        # Date string without dashes for filename                                                           # Source directory
SRCDIR=/opt/oarc/bpq/                                                           # Source for the backup
DESDIR=/mnt/smb_share/BPQbackup                                                 # Destination directory
FILE=bpq$DATESHORT.tar.gz                                                       # Backup file name
REMOVEDATE=$(date --date="10 days ago" +%Y%m%d)                                 # throw away files older than 10 days
REMOVEFILE=bpq$REMOVEDATE.tar.gz                                                # File to remove
#
# Let's start with the backup
#
sudo systemctl stop linbpq.service                                              # Stop BPQ service
sudo tar -cpzf $DESDIR/$FILE $SRCDIR    >> /home/robin/job_result.log 2>&1      # Compressed backup and log file appended
sudo rm $DESDIR/$REMOVEFILE > /dev/null 2>&1                                         # Remove old files
sudo systemctl start linbpq.service                                             # Start BPQ service
#
# Job's a goodun :)
