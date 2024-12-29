## **Setting Up Rclone on Debian to Sync ~/bpq-backup to OneDrive /Backups/LinBPQ**

### **1. Install Rclone**

First, install Rclone on your Debian system (for both headless and interactive setups):

```bash
sudo apt update
sudo apt install rclone
```

---

### **2. Configure Rclone for OneDrive**

#### **Interactive Configuration (with a browser)**

If you have a graphical interface or can use a browser, run:

```bash
rclone config
```

Follow these steps:

1. **Create a New Remote**: Type `n` to create a new remote.
2. **Choose a Name**: Enter a name for the remote, such as `onedrive`.
3. **Choose the Cloud Storage Provider**: Type `onedrive` and press Enter.
4. **Client ID and Secret**: Press Enter to use the default Client ID and Secret.
5. **Auto-config (with browser)**: Type `y` to enable auto-config (this will open the login URL in your browser).
6. **Authorize Rclone**: After the browser opens, log in to your Microsoft account, authorize Rclone, and paste the authorization code back into the terminal.
7. **Default Scopes**: Press Enter to select the default scope (`drive`).
8. **Advanced Configuration**: You can skip by pressing Enter.
9. **Confirm**: Type `y` to confirm your configuration.

#### **Headless Configuration (without a browser)**

If you’re using a headless setup (no GUI), you can configure Rclone without needing a browser:

1. **Start Configuration**: Run `rclone config` and follow these steps:

    ```bash
    rclone config
    ```

2. **Create a New Remote**: Type `n` to create a new remote and name it `onedrive`.
3. **Choose OneDrive**: Type `onedrive` to select Microsoft OneDrive.
4. **Auto-config**: When asked if you want to use auto-config, type `n` (for no).
5. **Get Authorization Code**:
    - Rclone will display a URL:
      
      ```bash
      If your browser supports it, open the following URL:
      https://auth.microsoftonline.com/...
      ```
      
    - Copy the URL and open it in a browser on another device.
    - Sign in to your Microsoft account and grant Rclone permission.
    - After that, you will receive an **authorization code**.
6. **Enter the Authorization Code**: Paste the code back into the terminal when prompted.

7. **Complete the Setup**:
    - Choose the default settings for the remaining prompts (just press Enter).
    - Confirm the configuration by typing `y`.

---

### **3. Sync the Local Directory to OneDrive**

Now, you can sync the local directory `~/bpq-backup` to OneDrive's `/Backups/LinBPQ`.

#### **Sync Command**

Run this command to sync the local directory to OneDrive:

```bash
rclone sync ~/bpq-backup onedrive:/Backups/LinBPQ
```

This command will:

- Copy all files from `~/bpq-backup` to `/Backups/LinBPQ` on OneDrive.
- If the `/Backups/LinBPQ` folder does not exist on OneDrive, Rclone will create it automatically.

---

### **4. Automate the Sync Process with Cron**

To run the sync automatically, you can set up a cron job.

#### **Create a Cron Job**:

Open the crontab editor:

```bash
crontab -e
```

Add the following line to run the sync every day at midnight:

```bash
0 0 * * * rclone sync ~/bpq-backup onedrive:/Backups/LinBPQ
```

This cron job will execute the sync process daily at midnight.

---

### **5. Verify the Sync (Optional)**

To check if the sync worked, list the contents of the `/Backups/LinBPQ` directory on OneDrive:

```bash
rclone ls onedrive:/Backups/LinBPQ
```

This will show the files that have been uploaded to the remote OneDrive folder.