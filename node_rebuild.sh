#!/bin/bash

# **Experimental**
# Script to set up a Raspberry Pi Packet Node from a Backup
# All output is logged to /var/log/setup_packet_node.log

logfile="/var/log/setup_packet_node.log"
exec > >(while read -r line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done | tee -a "$logfile") 2>&1

# Function to check for successful command execution
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "\033[0;31mError: $1 failed. Exiting script.\033[0m"
        exit 1
    fi
}

# Trap unexpected errors
trap 'echo -e "\033[0;31mAn unexpected error occurred. Exiting.\033[0m"; exit 1' ERR
set -e  # Stop script on any error

# Function to perform system updates
update_system() {
    echo "Updating system..."
    sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
    check_status "System update"
}

# Function to install additional packages
install_packages() {
    echo "Installing additional packages..."
    sudo apt-get install -y tmux screenfetch htop ntpdate sntp unattended-upgrades \
        rsync lsb-release curl python3-pip speedtest-cli git python3-serial unzip
    check_status "Package installation"
}

# Function to set up Hibbian
setup_hibbian() {
    echo "Setting up Hibbian..."
    cd /tmp || exit
    wget https://guide.hibbian.org/static/files/setup.sh
    check_status "Downloading Hibbian setup script"
    chmod +x setup.sh
    sudo bash setup.sh
    check_status "Running Hibbian setup"
}

# Function to install LinBPQ
install_linbpq() {
    echo "Installing LinBPQ..."
    sudo apt-get update -y && sudo apt-get install -y linbpq
    check_status "LinBPQ installation"
}

# Function to download and restore backup
download_and_restore_backup() {
    echo "Please enter the URL to download the backup file from:"
    read -r backup_url

    # Validate URL
    if [[ ! "$backup_url" =~ ^https?:// ]]; then
        echo -e "\033[0;31mError: Invalid URL. Please provide a valid HTTP or HTTPS URL.\033[0m"
        exit 1
    fi

    echo "Downloading backup file from $backup_url..."
    wget "$backup_url" -P /tmp
    check_status "Downloading backup file"

    # Extract the filename from the URL
    backup_filename=$(basename "$backup_url")

    # Verify the file exists after download
    if [ ! -f "/tmp/$backup_filename" ]; then
        echo -e "\033[0;31mError: Backup file '$backup_filename' not found after download. Exiting.\033[0m"
        exit 1
    fi

    echo "Restoring backup from $backup_filename..."
    sudo tar -xzf "/tmp/$backup_filename" -C /
    check_status "Backup restoration"

    # Clean up temporary files
    rm -f "/tmp/$backup_filename"
}

# Function to update BPQ config file ownership
update_bpq_config() {
    echo "Updating BPQ config file ownership..."
    if [ -f /etc/bpq32.cfg ]; then
        sudo cp /etc/bpq32.cfg /etc/bpq32.cfg.bak
        echo "Existing BPQ config backed up to /etc/bpq32.cfg.bak"
    fi
    sudo chown :linbpq /etc/bpq32.cfg
    sudo chmod 644 /etc/bpq32.cfg
    check_status "Updating BPQ config file ownership"
}

# Main function
main() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "\033[0;31mPlease run this script as root or with sudo.\033[0m"
        exit 1
    fi

    update_system
    install_packages
    setup_hibbian
    install_linbpq
    download_and_restore_backup
    update_bpq_config

    echo -e "\033[0;32mSetup complete. Please remember to reboot the system later to apply all changes.\033[0m"
}

main
