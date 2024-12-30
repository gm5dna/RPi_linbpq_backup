This script was adapted from a helpful one by [Robin M0JQQ](https://github.com/m0jqq).

## Installation
1. Clone this repository: `git clone https://github.com/sdhuk/RPi_linbpq_backup`
2. Optional: [Set up Rclone](/Rclone%20setup%20instructions.md)
3. `cd RPi_linbpq_backup`
4. `nano RPi_linbpq_backup` and modify the variables to suit your personal setup
5. Ensure that the script is executable `chmod +x RPi_linbpq_backup`
6. Test the script is working properly `./RPi_linbpq_backup`
7. [Set up a cron job](#scheduling-a-cron-job) for automated daily backups

## Scheduling a Cron Job
To schedule `~/RPi_linbpq_backup/RPi_linbpq_backup.sh` as a cron job to run every day at 1 AM, follow these steps:

### Step 1: Edit the Cron Table
1. Open the crontab editor:
   ```bash
   crontab -e
   ```

2. If this is your first time editing the crontab, you'll be prompted to select an editor. Choose one (e.g., nano).

---

### Step 2: Add the Cron Job
In the crontab file, add the following line:

```bash
0 1 * * * /bin/bash ~/RPi_linbpq_backup/RPi_linbpq_backup.sh
```

Explanation of the schedule:
- `0 1 * * *`: Specifies that the job runs at 1:00 AM every day.
- `/bin/bash`: Ensures the script runs using the Bash shell.
- `~/RPi_linbpq_backup/RPi_linbpq_backup.sh`: The path to your script.