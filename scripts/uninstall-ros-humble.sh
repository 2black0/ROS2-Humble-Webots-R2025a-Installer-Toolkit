#!/bin/bash

set -e
set -u

# Fungsi untuk header
print_header() {
    clear
    echo "🧹 ROS 2 Complete Uninstaller"
    echo "============================="
    echo
}

# Validasi root
validate_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "❌ Error: Do not run as root!"
        exit 1
    fi
}

# Main uninstallation
main() {
    print_header
    validate_root

    echo "🔍 Checking installed ROS distributions..."
    ROS_DIR="/opt/ros"
    if [[ ! -d "$ROS_DIR" ]]; then
        echo "ℹ️  No ROS installation found in $ROS_DIR"
        exit 0
    fi

    # List installed distributions
    echo "📦 Installed ROS distributions:"
    local distributions=($(ls "$ROS_DIR"))
    if [[ ${#distributions[@]} -eq 0 ]]; then
        echo "ℹ️  No ROS distributions found"
        exit 0
    fi

    for i in "${!distributions[@]}"; do
        echo "  $((i+1)). ${distributions[$i]}"
    done

    echo
    read -p "Enter number of distribution to uninstall (0 to exit): " choice
    if [[ $choice -lt 1 || $choice -gt ${#distributions[@]} ]]; then
        echo "🚫 Operation cancelled"
        exit 0
    fi

    selected_distro="${distributions[$((choice-1))]}"
    echo
    echo "⚠️  WARNING: This will completely remove ROS $selected_distro!"
    read -p "Are you sure? (y/N) " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "🚫 Operation cancelled"
        exit 0
    fi

    echo "🚮 Starting uninstallation process for ROS $selected_distro..."
    
    # Step 1: Remove packages
    echo "🧹 Removing packages..."
    sudo apt remove -y "ros-$selected_distro-*" && \
    sudo apt autoremove -y

    # Step 2: Remove ROS directory
    echo "🗑️  Removing installation directory..."
    sudo rm -rf "/opt/ros/$selected_distro"

    # Step 3: Clean environment
    echo "🧼 Cleaning environment..."
    SHELL_CONFIGS=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/fish/config.fish"
    )

    for config in "${SHELL_CONFIGS[@]}"; do
        if [[ -f "$config" ]]; then
            echo "  Cleaning $config..."
            sed -i '/source \/opt\/ros\//d' "$config"
            sed -i '/ROS_DISTRO/d' "$config"
            sed -i '/ROS_VERSION/d' "$config"
        fi
    done

    # Step 4: Remove sources
    echo "📭 Removing repository sources..."
    sudo rm -f /etc/apt/sources.list.d/ros2.list
    sudo rm -f /usr/share/keyrings/ros-archive-keyring.gpg

    # Step 5: Optional workspace cleanup
    echo
    read -p "Remove ROS workspaces and logs? [y/N] " clean_workspaces
    if [[ $clean_workspaces =~ ^[Yy]$ ]]; then
        echo "🧹 Cleaning workspaces..."
        rm -rf "$HOME/ros_ws" 2>/dev/null
        rm -rf "$HOME/.ros" 2>/dev/null
    fi

    # Final cleanup
    echo "🔍 Final system cleanup..."
    sudo apt update
    sudo apt autoremove -y

    echo
    echo "✅ Uninstallation complete!"
    echo "➡️  Please reboot your system to complete cleanup"
}

# Execute main
main