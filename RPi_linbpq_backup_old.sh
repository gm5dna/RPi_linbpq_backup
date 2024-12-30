#!/bin/bash
#
#    bpqbackup.sh
#    ============
#
# Daily BPQ backup from /opt/oarc/bpq/ to local network samba share
# Each backup is date stamped and retained for a rolling 10 days
#
DATESHORT=`date +%Y%m%d`                                                        # Date string without dashes for filename
SRCDIR=/opt/oarc/bpq/                                                           # Main application directory for the backup
BPQCFG=/etc/bpq32.cfg                                                           # Location of bpq32.cfg (/etc on Hibbian repo)
DESDIR=~/bpq-backup                                                             # Destination directory (ideally an SMB share)
SYNCDIR=onedrive:/Backups/LinBPQ                                                # Rclone target directory
FILE=bpq$DATESHORT.tar.gz                                                       # Backup file name
REMOVEDATE=$(date --date="10 days ago" +%Y%m%d)                                 # Throw away files older than 10 days
REMOVEFILE=bpq$REMOVEDATE.tar.gz                                                # File to remove
#
# Let's start with the backup
#
sudo systemctl stop linbpq.service                                              # Stop BPQ service
sudo tar -cpzf $DESDIR/$FILE $SRCDIR $BPQCFG  >> $DESDIR/bpq-backup.log 2>&1    # Compressed backup and log file appended
sudo rm $DESDIR/$REMOVEFILE > /dev/null 2>&1                                    # Remove old files
sudo systemctl start linbpq.service                                             # Start BPQ service
rclone sync $DESDIR onedrive:/Backups/LinBPQ --progress                         # Rclone backup to cloud storage, comment this line out if not required
#
# Job's a goodun :)