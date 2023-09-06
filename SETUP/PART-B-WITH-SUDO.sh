#!/usr/bin/env bash

# Tolga Erok
# 14/7/2023
# Post Nixos setup!
# ¯\_(ツ)_/¯

# -----------------------------------------------------------------------------------
# Check if Script is Run as Root
# -----------------------------------------------------------------------------------

# Fix nixos horrible allowance to custom packages
export NIXPKGS_ALLOW_INSECURE=1

# For fun
start_time=$(date +%s)

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# -----------------------------------------------------------------------------------
# Set some variables & functions
# -----------------------------------------------------------------------------------

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'

# Location of private samba folder
shared_folder="/home/NixOs-KDE"

# Install notify agents
nix-env -iA nixos.libnotify
nix-env -iA nixos.notify-desktop

# Install Samba
nix-env -iA nixos.cifs-utils
nix-env -iA nixos.samba4Full

# Define user and group IDs here
user_id=$(id -u "$SUDO_USER")
group_id=$(id -g "$SUDO_USER")

# Get the user and group names using the IDs
user_name=$(id -un "$user_id")
group_name=$(getent group "$group_id" | cut -d: -f1)

# Function to create directories if they don't exist and set permissions
create_directory_if_not_exist() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
        chown "$user_name":"$group_name" "$1"
        chmod 755 "$1"  # Set read and execute permissions for user, group, and others
        make-executable
    fi
}

# Function to check and update permissions of existing directories
update_directory_permissions() {
    if [ -d "$1" ]; then
        perm=$(stat -c "%a" "$1")
        if [ "$perm" != "755" ]; then
            echo "Updating permissions of existing directory: $1"
            chmod 755 "$1"
            make-executable
        fi
    fi
}

# -----------------------------------------------------------------------------------
# Get user id and group id
# -----------------------------------------------------------------------------------

# Get the user and group IDs of the currently logged-in user
user_id=$(id -u "$SUDO_USER")
group_id=$(id -g "$SUDO_USER")

# -----------------------------------------------------------------------------------
#  Create some directories and set permissions
# -----------------------------------------------------------------------------------

if [ -n "$user_name" ] && [ -n "$group_name" ]; then
    home_dir="/home/$user_name"
    config_dir="$home_dir/.config/nix"
    
    create_directory_if_not_exist "$home_dir"
    create_directory_if_not_exist "$config_dir"
    
    # Directories to create and set permissions
    directories=(
        "$home_dir/Documents"
        "$home_dir/Music"
        "$home_dir/Pictures"
        "$home_dir/Public"
        "$home_dir/Templates"
        "$home_dir/Videos"
    )
    
    for dir in "${directories[@]}"; do
        create_directory_if_not_exist "$dir"
    done
    
    # Update directory permissions
    update_directory_permissions "$home_dir/Documents"
    update_directory_permissions "$home_dir/Music"
    update_directory_permissions "$home_dir/Pictures"
    update_directory_permissions "$home_dir/Public"
    update_directory_permissions "$home_dir/Templates"
    update_directory_permissions "$home_dir/Videos"
    
    # Set ownership for directories
    sudo chown -R "$user_name":"$group_name" "$home_dir"
    
    # Give full permissions to the nix.conf file
    echo "experimental-features  = nix-command flakes" | sudo -u "$user_name" tee "$config_dir/nix.conf"
    chmod 644 "$config_dir/nix.conf"  # Set read permissions for user, group, and others
else
    echo "Failed to retrieve non-root user and group information."
    exit 1
fi

# -----------------------------------------------------------------------------------
# Flatpak section
# -----------------------------------------------------------------------------------

echo "
Install Flatpak apps...
"

# Enable Flatpak
if ! flatpak remote-list | grep -q "flathub"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Update Flatpak
echo "
Updating cache, this will take a while...
"
sudo flatpak update -y

# Install Flatpak apps
packages=(
   # com.sindresorhus.Caprine
    org.kde.kweather
)

# Install each package if not already installed
for package in "${packages[@]}"; do
    if ! flatpak list | grep -q "$package"; then
        echo "Installing $package..."
        sudo flatpak install -y flathub "$package"
    else
        echo "$package is already installed. Skipping..."
    fi
done

# List all flatpak
echo "Show Flatpak info:"
su - "$USER" -c "flatpak remote-list"
echo ""

echo -e "
\033[33mChecking all runtimes installed: \033[0m
"
flatpak list --runtime
echo ""

echo "
List of flatpak's installed on system:
"
flatpak list --app
echo ""

# -----------------------------------------------------------------------------------
#  Create some SMB user and group
# -----------------------------------------------------------------------------------

# Function to read user input and prompt for input
prompt_input() {
    read -p "$1" value
    echo "$value"
}

# Create user/group
echo "
Time to create smb user & group
"

create-smb-user

# Pause and continue
echo -e "${GREEN}[✔]${NC} SMB user and Samba group added\n"
read -r -n 1 -s -t 1

clear

# Create and configure the shared folder
sudo mkdir -p "$shared_folder"
sudo chgrp "$sambagroup" "$shared_folder"
sudo chmod 0757 "$shared_folder"

# Configure Samba Filesharing Plugin for a user
echo -e "\nCreate and configure the Samba Filesharing Plugin..."

# Prompt for the desired username to configure Samba Filesharing Plugin
username=$(prompt_input $'\nEnter the username to configure Samba Filesharing Plugin for: ')

# Set umask value
umask 0002

# Set permissions for the shared folder and parent directories (excluding hidden files and .cache directory)
find "$shared_folder" -type d ! -path '/.' ! -path '/.cache' -exec chmod 0757 {} \; 2>/dev/null

# Create the sambashares group if it doesn't exist
sudo groupadd -r sambashares

# Create the usershares directory and set permissions
sudo mkdir -p /var/lib/samba/usershares
sudo chown "$username:sambashares" /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares

# Add the user to the sambashares group
sudo gpasswd sambashares -a "$username"

# Set permissions for the user's home directory
sudo chmod 0757 "/home/$username"

# Recheck to allow insecure packages
export NIXPKGS_ALLOW_INSECURE=1

clear

# Rebuild system

nixos-update

# -------------------
# Install wps fonts
# -------------------
clear && echo -e "${GREEN}[✔]${NC} Installing custom fonts for ${BLUE} WPS${NC}\n"
sudo mkdir -p ~/.local/share/fonts
wget https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip
unzip -o WPS-FONTS.zip -d ~/.local/share/fonts
sudo fc-cache -vf ~/.local/share/fonts
sudo fc-cache -f -v
rm WPS-FONTS.zip
rm WPS-FONTS.zip.*

# ---‐‐---------------------------
# make locations executable
# --------------------------------
clear && echo -e "${GREEN}[✔]${NC} Almost finished\n"
cd $HOME
mse
my-nix && mylist && neofetch
sudo chmod -R 777 /etc/nixos

# Test alittle
wps
et
shotwell

clear && echo -e "${GREEN}[✔]${NC} Setup finished\n"
clear && read -p "Press enter then control + c on next screen to exit cmatrix..."

cmatrix

clear

exit 1
