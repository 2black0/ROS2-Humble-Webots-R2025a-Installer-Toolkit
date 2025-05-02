#!/bin/bash

set -e
set -u

# Configuration
LOG_FILE="ros_webots_install_$(date +%Y%m%d_%H%M%S).log"
ROS_DISTRO="humble"
WEBOTS_VERSION="R2025a"
UBUNTU_REQUIRED="22.04"

# Redirect all output to log file and terminal
exec > >(tee -a "$LOG_FILE") 2>&1

# ============================================
# 🛠️  Main Installation Management Script
# ============================================

print_header() {
    clear
    echo "🤖 ROS 2 & Webots Installation Manager"
    echo "======================================"
    echo "  [1] Install ROS $ROS_DISTRO + Webots $WEBOTS_VERSION"
    echo "  [2] Uninstall All Components"
    echo "  [3] Exit"
    echo
}

validate_os() {
    echo "🔍 Checking system compatibility..."
    if ! command -v lsb_release &> /dev/null; then
        echo "❌ Error: lsb_release not found!"
        exit 1
    fi

    local os_info=$(lsb_release -ds)
    local ubuntu_version=$(lsb_release -rs)
    local codename=$(lsb_release -cs)

    if [[ $os_info != *"Ubuntu"* ]] || [[ $ubuntu_version != "$UBUNTU_REQUIRED" ]] || [[ $codename != "jammy" ]]; then
        echo "❌ Error: Requires Ubuntu $UBUNTU_REQUIRED Jammy!"
        exit 1
    fi
    echo "✅ Verified: Ubuntu $UBUNTU_REQUIRED Jammy"
}

install_ros() {
    echo "
⚙️====================================
🚀 STARTING ROS $ROS_DISTRO INSTALLATION
========================================"

    # System updates
    echo "🔄 Updating package lists..."
    sudo apt update -qq

    echo "📦 Installing core dependencies..."
    sudo apt install -y -qq \
        software-properties-common \
        git \
        python3-pip \
        python3-rosdep \
        python3-colcon-common-extensions

    # ROS repository setup
    echo "🔧 Configuring ROS repositories..."
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" | \
        sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

    # ROS installation
    echo "🚀 Installing ROS $ROS_DISTRO..."
    sudo apt update -qq
    sudo apt install -y -qq ros-$ROS_DISTRO-desktop

    # Environment setup
    echo "⚡ Configuring shell environment..."
    if ! grep -q "ros/$ROS_DISTRO" ~/.bashrc; then
        echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
    fi
    source /opt/ros/$ROS_DISTRO/setup.bash

    # ROSDEP initialization
    echo "🛠️  Initializing rosdep..."
    sudo rosdep init || true
    rosdep update

    echo "✅ ROS $ROS_DISTRO installed successfully!"
}

install_webots() {
    echo "
⚙️=====================================
🚀 STARTING WEBOTS $WEBOTS_VERSION INSTALLATION
=========================================="

    # Repository setup
    echo "🔧 Configuring Webots repositories..."
    sudo apt install -y -qq curl
    sudo curl -sSL https://cyberbotics.com/Cyberbotics.asc \
        -o /usr/share/keyrings/Cyberbotics.asc
    echo "deb [signed-by=/usr/share/keyrings/Cyberbotics.asc] https://cyberbotics.com/debian binary-amd64/" | \
        sudo tee /etc/apt/sources.list.d/Cyberbotics.list > /dev/null

    # Webots installation
    echo "📦 Installing Webots..."
    sudo apt update -qq
    sudo apt install -y -qq webots

    # Environment configuration
    echo "⚡ Setting environment variables..."
    if ! grep -q "WEBOTS_HOME" ~/.bashrc; then
        echo "export WEBOTS_HOME=/usr/local/webots" >> ~/.bashrc
    fi
    export WEBOTS_HOME=/usr/local/webots

    echo "✅ Webots $WEBOTS_VERSION installed successfully!"
}

install_webots_ros2() {
    echo "
⚙️=========================================
🚀 STARTING WEBOTS-ROS2 INTEGRATION INSTALLATION
==============================================="

    echo "📦 Installing webots_ros2 package..."
    sudo apt install -y -qq ros-$ROS_DISTRO-webots-ros2

    echo "🔧 Configuring workspace..."
    mkdir -p ~/webots_ws/src
    cd ~/webots_ws
    colcon build

    echo "✅ Webots-ROS2 integration complete!"
}

uninstall_all() {
    echo "
⚙️================================
🧹 STARTING COMPLETE UNINSTALLATION
==================================="

    # ROS Uninstallation
    echo "🚮 Removing ROS $ROS_DISTRO..."
    sudo apt remove -y -qq "ros-$ROS_DISTRO-*"
    sudo rm -rf /opt/ros/$ROS_DISTRO
    sudo apt autoremove -y -qq

    # Webots Uninstallation
    echo "🚮 Removing Webots..."
    sudo apt remove -y -qq webots
    sudo rm -rf /usr/local/webots
    sudo rm /etc/apt/sources.list.d/Cyberbotics.list

    # Environment cleanup
    echo "🧹 Cleaning environment..."
    sed -i '/ros\/'$ROS_DISTRO'/d' ~/.bashrc
    sed -i '/WEBOTS_HOME/d' ~/.bashrc

    echo "✅ All components uninstalled!"
}

main() {
    validate_os

    while true; do
        print_header
        read -p "Select option [1-3]: " choice

        case $choice in
            1)
                install_ros
                install_webots
                install_webots_ros2
                echo "
🎉 Installation Complete!
=========================
- ROS Version: $ROS_DISTRO
- Webots Version: $WEBOTS_VERSION
- Log file: $LOG_FILE
                "
                ;;
            2)
                uninstall_all
                ;;
            3)
                echo "👋 Exiting..."
                exit 0
                ;;
            *)
                echo "❌ Invalid option!"
                ;;
        esac

        read -p "Press Enter to continue..."
    done
}

main
