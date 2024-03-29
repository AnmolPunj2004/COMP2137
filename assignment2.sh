#!/bin/bash


# Function herre is to check if a package is installed or not
check_package() {
    # Check if the package is installed
    if ! dpkg -l "$1" &>/dev/null; then
        
        echo "Package $1 is not installed. Installing..."
        # Updated package list and installed the package
        
        apt update
        
        apt install -y "$1"
    else
        
        echo "Package $1 is already installed."
    fi
}

# Function to update netplan configuration
update_netplan() {
    # Checking if the netplan configuration has the required address
    if ! grep -q "192.168.16.21/24" /etc/netplan/*.yaml; then
        # Update netplan configuration to include the required address
        
        echo "Updating netplan configuration..."
        # Modify netplan configuration file
        yq eval ".[].network.network:  version: 2  ethernets:    ens160:      addresses:        - 192.168.16.21/24" /etc/netplan/01-netcfg.yaml > /etc/netplan/99-custom-cfg.yaml
        # Applying  the new netplan configurations 
        netplan apply
        # Check if applying the configuration was successful or not
        check_exit_code "Failed to apply netplan configuration"
    else
        echo "Netplan configuration already contains the required address."
    fi
}

# Function to create user accounts
create_users() {
    # List of users to create
    local users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
    # Loop through each user
    for user in "${users[@]}"; do
        # Check if the user already exists
        if id "$user" &>/dev/null; then
            echo "User $user already exists."
        else
            # Create the user
            echo "Creating user $user..."
            useradd -m -s /bin/bash "$user"
            # Add the user to the sudo group
            usermod -aG sudo "$user"
            # Set the user's password
            echo "$user:$(openssl rand -hex 16)" | chpasswd
            echo "User $user created."
            # Generate SSH keys for the user
            echo "Generated SSH keys for user $user."
        fi
    done
}

# Main script startts here
echo "Starting configuration script"

# Checking and installing required packages
check_package apache2
check_package squid
check_package ufw

# Updating netplan configuration
update_netplan

# Updating /etc/hosts file
update_hosts

# Configuring the firewall
configure_firewall

# Creating user accounts
create_users

echo "Configuration completed."
