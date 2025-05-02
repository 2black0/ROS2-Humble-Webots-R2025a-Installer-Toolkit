#!/bin/bash

set -e
set -u

# ============================================
# 🤖 Webots & ROS 2 Humble Auto-Installer
# ============================================

# Configuration
WEBOTS_VERSION="R2025a"  # Target Webots version
ROS_DISTRO_EXPECTED="humble"
WEBOTS_PATH="/usr/local/webots"

# Function to print header
print_header() {
    clear
    echo "🤖 Webots & ROS 2 Humble Auto-Installer"
    echo "======================================="
    echo "Target Versions:"
    echo "- Webots: $WEBOTS_VERSION"
    echo "- ROS 2: $ROS_DISTRO_EXPECTED"
    echo
}

# Root validation
validate_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "❌ Error: Do not run as root!"
        exit 1
    fi
}

# OS validation
validate_os() {
    if ! command -v lsb_release &> /dev/null; then
        echo "❌ Error: lsb_release package not found!"
        exit 1
    fi

    OS_INFO=$(lsb_release -ds)
    UBUNTU_VERSION=$(lsb_release -rs)
    CODENAME=$(lsb_release -cs)

    if [[ $OS_INFO != *"Ubuntu"* ]] || [[ $UBUNTU_VERSION != "22.04" ]] || [[ $CODENAME != "jammy" ]]; then
        echo "❌ Error: Only for Ubuntu 22.04 Jammy Jellyfish!"
        exit 1
    fi
}

# ROS installation validation
validate_ros() {
    if ! command -v ros2 &> /dev/null; then
        echo "❌ Error: ROS 2 not installed or not in PATH!"
        exit 1
    fi

    # Source setup.bash if not already sourced
    if [[ -z "${ROS_DISTRO:-}" ]]; then
        if [[ -f "/opt/ros/$ROS_DISTRO_EXPECTED/setup.bash" ]]; then
            echo "🔄 Sourcing ROS 2 setup.bash..."
            source "/opt/ros/$ROS_DISTRO_EXPECTED/setup.bash"
        fi
    fi

    if [[ -z "${ROS_DISTRO:-}" ]]; then
        echo "❌ Error: ROS_DISTRO is not set!"
        echo "Make sure to source ROS 2 setup.bash:"
        echo "  source /opt/ros/$ROS_DISTRO_EXPECTED/setup.bash"
        exit 1
    fi

    if [[ "$ROS_DISTRO" != "$ROS_DISTRO_EXPECTED" ]]; then
        echo "❌ Error: Detected ROS 2 distro is '$ROS_DISTRO' but expected '$ROS_DISTRO_EXPECTED'."
        exit 1
    fi
}

# Install system dependencies
install_dependencies() {
    echo "🔄 Installing system dependencies..."
    sudo apt update -qq
    sudo apt install -y -qq \
        curl \
        wget \
        libxcb-xinerama0 \
        qtbase5-dev \
        libqt5opengl5-dev \
        libgl1-mesa-dev
}

# Main installation process
main() {
    print_header
    validate_root
    validate_os
    validate_ros

    # Step 1: Setup Webots repository
    echo "🔑 Adding Cyberbotics GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    sudo wget -q https://cyberbotics.com/Cyberbotics.asc -O /etc/apt/keyrings/Cyberbotics.asc

    echo "📥 Adding Webots repository..."
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/Cyberbotics.asc] https://cyberbotics.com/debian binary-amd64/" | \
        sudo tee /etc/apt/sources.list.d/Cyberbotics.list > /dev/null

    # Step 2: Install Webots
    echo "🚀 Installing Webots $WEBOTS_VERSION..."
    sudo apt update -qq
    sudo apt install -y -qq webots

    # Step 3: Environment configuration
    echo "⚡ Configuring environment variables..."
    {
        echo ""
        echo "# Webots environment variables"
        echo "export WEBOTS_HOME=$WEBOTS_PATH"
        echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$WEBOTS_HOME/lib/controller"
    } >> ~/.bashrc

    # Step 4: Install Webots ROS 2 integration
    echo "🔌 Installing Webots ROS 2 bridge..."
    sudo apt install -y -qq ros-$ROS_DISTRO_EXPECTED-webots-ros2

    # Step 5: Verification
    echo "✅ Verifying installation..."
    if ! command -v webots &> /dev/null; then
        echo "❌ Webots not detected in PATH!"
        exit 1
    fi

    if [[ ! -d "$WEBOTS_PATH" ]]; then
        echo "❌ Invalid Webots path: $WEBOTS_PATH"
        exit 1
    fi

    echo
    echo "🎉 Installation SUCCESSFUL!"
    echo "---------------------------"
    echo "For final verification:"
    echo "1. Open Webots:"
    echo "   webots"
    echo
    echo "2. Test ROS 2 integration:"
    echo "   source /opt/ros/$ROS_DISTRO_EXPECTED/setup.bash"
    echo "   ros2 launch webots_ros2_universal_robot multirobot_launch.py"
}

# Run installer
main
