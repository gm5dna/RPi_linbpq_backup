This script was adapted from a helpful one by [Robin M0JQQ](https://github.com/m0jqq) and updated to include `/etc/bpq32.cfg`, the configuration file location used in [Hibbian](https://www.hibbian.org). Additionally, it includes an optional feature to sync backups to cloud storage using Rclone, for users not backing up to a mounted fileshare or external drive.

## Features
- Supports backing up `/etc/bpq32.cfg` used by Hibbian.
- Optional integration with Rclone for cloud storage backups.
- Automated daily backups via a cron job.

---

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sdhuk/RPi_linbpq_backup
   ```

2. **Optional: Set up Rclone**  
   Follow the [Rclone setup instructions](Rclone%20setup%20instructions.md) to configure cloud storage.

3. **Navigate to the repository**:
   ```bash
   cd RPi_linbpq_backup
   ```

4. **Customize the script**:  
   Edit the variables in `RPi_linbpq_backup` to suit your setup:
   ```bash
   nano RPi_linbpq_backup
   ```

5. **Make the script executable**:
   ```bash
   chmod +x RPi_linbpq_backup
   ```

6. **Test the script**:  
   Run the script to ensure it works:
   ```bash
   ./RPi_linbpq_backup
   ```

7. **Automate backups**:  
   Set up a cron job to run the script daily. [See details below](#scheduling-a-cron-job).

---

## Scheduling a Cron Job

To automate the backup process, you can schedule the script as a cron job to run every day at 1:00 AM.

### Step 1: Open the Crontab Editor

Run the following command:
```bash
crontab -e
```

If you're using the crontab editor for the first time, select your preferred editor (e.g., nano).

### Step 2: Add the Cron Job

Add the following line to the crontab file:
```bash
0 1 * * * /bin/bash ~/RPi_linbpq_backup/RPi_linbpq_backup.sh
```

#### Explanation of the Cron Schedule
- `0 1 * * *`: Runs the script daily at 1:00 AM.
- `/bin/bash`: Ensures the script runs with the Bash shell.
- `~/RPi_linbpq_backup/RPi_linbpq_backup.sh`: Path to the script.

### Step 3: Save and Exit

Save the crontab file and exit the editor. The script is now scheduled to run daily.