This helpful script was written by [Robin M0JQQ](https://github.com/m0jqq). I've adapted it so that the archives include `bpq32.cfg`, which is stored in `etc/` in [Hibby's repository](https://www.hibbian.org).

If you're using [Hibby's repository](https://www.hibbian.org), then you probably only need to edit one variable in the script, `DESDIR=`, which is the destination directory for the backups. This should ideally be fileshare on another machine. Alternatively, you could use [Rclone](https://rclone.org) to save your backups to cloud storage.

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

---

### Step 3: Ensure the Script Is Executable
Make sure the script has executable permissions:

```bash
chmod +x ~/RPi_linbpq_backup/RPi_linbpq_backup.sh
```

---

### Step 4: Verify the Cron Job
List your current cron jobs to verify the addition:

```bash
crontab -l
```

---

### Step 5: Test the Script
To confirm it works as intended, run the script manually:

```bash
/bin/bash ~/RPi_linbpq_backup/RPi_linbpq_backup.sh
```

Check the output to ensure there are no errors.

---

You're all set! The script will now run daily at 1 AM.
