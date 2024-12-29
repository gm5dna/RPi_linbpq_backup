To set up Rclone on Debian to sync the contents of `~/bpq-backup` to the OneDrive directory `/Backups/LinBPQ`, follow these steps:

### 1. Install Rclone

First, make sure you have Rclone installed. You can do this by running:

```bash
sudo apt update
sudo apt install rclone
```

### 2. Configure Rclone for OneDrive

Run the following command to configure a new remote:

```bash
rclone config
```

This will launch an interactive prompt. Follow these steps within the prompt:

- **New remote**: Type `n` to create a new remote.
- **Name the remote**: Give it a name, for example `onedrive`.
- **Choose the cloud storage type**: Type `onedrive` and press Enter to select OneDrive.
- **Client ID and Secret**: For personal use, just press Enter to use the default.
- **Use auto-config**: Type `y` and press Enter to authorize Rclone to access your OneDrive account in the browser.
- **Authorize Rclone**: Follow the on-screen instructions to authenticate with OneDrive.
- **Choose the default scope**: Typically, you can just press Enter to accept the default (`drive`).
- **Configure advanced options**: You can skip these by pressing Enter.
- **Confirm configuration**: Type `y` to confirm everything looks good.

After completing this, you'll return to the main Rclone prompt. You should see `onedrive` listed under remotes.

### 3. Sync the Local Directory to OneDrive

Now, you can sync the contents of `~/bpq-backup` to the `/Backups/LinBPQ` directory in OneDrive. Use the following Rclone command:

```bash
rclone sync ~/bpq-backup onedrive:/Backups/LinBPQ
```

This will sync the contents of `~/bpq-backup` to `/Backups/LinBPQ` on OneDrive. If the destination directory doesn’t exist, Rclone will create it.

### 4. Automate the Sync Process (Optional)

You can set up a cron job to automate the sync process. For example, to run the sync every day at midnight, edit your crontab:

```bash
crontab -e
```

Then add the following line to the file:

```bash
0 0 * * * rclone sync ~/bpq-backup onedrive:/Backups/LinBPQ
```

This will sync the directories at midnight each day.

### 5. Verify the Sync

To verify that the sync worked, you can list the contents of your OneDrive folder:

```bash
rclone ls onedrive:/Backups/LinBPQ
```

This will display the files that are currently stored in the `/Backups/LinBPQ` directory on OneDrive.