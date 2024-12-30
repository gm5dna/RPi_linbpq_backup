#!/bin/bash

# **Experimental**

# Script to Raspberry Pi Packet Node from a Backup
# All output is logged to /var/log/setup_packet_node.log

logfile="/var/log/setup_packet_node.log"
exec > >(tee -a "$logfile") 2>&1  # Log all output to a file

# Function to check for successful command execution
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Exiting script."
        exit 1
    fi
}

# Step 1: Perform System Updates
echo "Updating system..."
sudo apt update -y && sudo apt dist-upgrade -y && sudo apt autoremove -y
check_status "System update"

# Step 2: Install Additional Packages
echo "Installing additional packages..."
sudo apt install -y tmux screenfetch htop ntpdate sntp unattended-upgrades \
    rsync lsb-release curl python3-pip speedtest-cli git python3-serial
check_status "Package installation"

# Step 3: Set Up Hibbian
echo "Setting up Hibbian..."
cd /tmp
wget https://guide.hibbian.org/static/files/setup.sh
check_status "Downloading Hibbian setup script"
chmod +x /tmp/setup.sh
sudo bash /tmp/setup.sh
check_status "Running Hibbian setup"

# Step 4: Install LinBPQ
echo "Installing LinBPQ..."
sudo apt update && sudo apt install linbpq
check_status "LinBPQ installation"

# Step 5: Download and Restore Backup (interactive web location prompt)
echo "Please enter the URL to download the backup file from:"
read backup_url

# Download the backup file
echo "Downloading backup file from $backup_url..."
wget "$backup_url" -P /tmp
check_status "Downloading backup file"

# Extract the filename from the URL
backup_filename=$(basename "$backup_url")

# Check if the file exists after download
if [ ! -f "/tmp/$backup_filename" ]; then
    echo "Error: Backup file '$backup_filename' not found after download. Exiting."
    exit 1
fi

echo "Restoring backup from $backup_filename..."
sudo tar -xf "/tmp/$backup_filename" -C /
check_status "Backup restoration"

# Step 6: Update BPQ Config File Ownership
echo "Updating BPQ config file ownership..."
sudo chown :linbpq /etc/bpq32.cfg
sudo chmod 644 /etc/bpq32.cfg
check_status "Updating BPQ config file ownership"

# Step 7: Set Up NinoTNC Udev Rules
echo "Setting up NinoTNC udev rules..."
cat <<EOL | sudo tee /etc/udev/rules.d/99-ninotnc.rules
# Create a handy symlink to easily refer to NinoTNCs
SUBSYSTEM=="tty", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="00dd", ATTRS{serial}=="0123456789", SYMLINK+="tnc-2m"
EOL
check_status "Setting up NinoTNC udev rules"

# Step 8: Configure Unattended Updates
echo "Configuring unattended-upgrades..."
sudo dpkg-reconfigure --priority=low unattended-upgrades
check_status "Configuring unattended-upgrades"

# Step 10: Set Up Log2RAM
echo "Setting up Log2RAM..."
wget https://github.com/azlux/log2ram/archive/master.zip
unzip master.zip
cd log2ram-master
chmod +x install.sh
sudo ./install.sh
check_status "Log2RAM installation"

# Verify Log2RAM installation
echo "Verifying Log2RAM installation..."
systemctl status log2ram
check_status "Log2RAM verification"

# Step 11: Set Up Raspberry Pi Watchdog
echo "Setting up Raspberry Pi watchdog..."
echo "dtparam=watchdog=on" | sudo tee -a /boot/config.txt
sudo reboot
sleep 5

echo "Installing watchdog software..."
sudo apt install watchdog
sudo systemctl enable watchdog
check_status "Watchdog installation"

echo "Configuring watchdog..."
sudo sed -i 's/^#watchdog-device.*/watchdog-device = \/dev\/watchdog/' /etc/watchdog.conf
sudo sed -i 's/^#max-load-1.*/max-load-1 = 24/' /etc/watchdog.conf
check_status "Watchdog configuration"

# Step 12: Create .bash_aliases File
echo "Creating .bash_aliases file..."
if ! grep -q "alias c=" ~/.bash_aliases; then
    cat <<EOL >> ~/.bash_aliases
alias c='clear'
alias ping8='ping 8.8.8.8'
alias update='sudo apt update -y && sudo apt dist-upgrade -y && sudo apt autoremove -y'
alias temp='vcgencmd measure_temp'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias tailbbs='tail -f -s 0.1 /opt/oarc/bpq/logLatest_BBS.txt'
alias restartbpq='sudo systemctl restart linbpq.service'
alias startbpq='sudo systemctl restart linbpq.service'
alias stopbpq='sudo systemctl restart linbpq.service'
EOL
else
    echo ".bash_aliases already contains aliases, skipping..."
fi

# Step 9: Configure Raspberry Pi Settings
echo "Configuring Raspberry Pi settings..."
sudo raspi-config
check_status "Raspberry Pi settings configuration"

# Ask user if they want to reboot the system
echo "Setup complete! Would you like to reboot the system now? (yes/no)"
read reboot_choice

if [ "$reboot_choice" == "yes" ]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Please remember to reboot the system later to apply all changes."
fi
