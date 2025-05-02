#!/bin/bash

set -e
set -u

# Function to print header
print_header() {
    clear
    echo "🛠️  ROS 2 Humble Auto-Installer for Ubuntu 22.04"
    echo "================================================"
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

# Locale validation and setup
configure_locale() {
    echo "🌐 Configuring locale..."
    
    # Check existing locale
    if ! locale | grep -q 'LANG=en_US.UTF-8'; then
        sudo locale-gen en_US en_US.UTF-8
        sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    fi
    
    export LANG=en_US.UTF-8
    echo "✔️  Locale configured:"
    locale | grep -E 'LANG|LC_ALL'
}

# Main installation
main() {
    print_header
    validate_root
    validate_os

    echo "✅ System Validated: Ubuntu 22.04 Jammy"
    echo "--------------------------------------"
    
    # Step 1: System update and upgrade
    echo "🔄 Updating system packages..."
    sudo apt update -qq
    sudo apt upgrade -y -qq
    sudo apt autoremove -y -qq
    
    # Step 2: Configure locale
    configure_locale
    
    # Step 3: Add ROS repositories
    echo "📥 Adding ROS repositories..."
    required_packages=(
        curl
        gnupg
        software-properties-common
    )
    
    for pkg in "${required_packages[@]}"; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            sudo apt install -y -qq "$pkg"
        fi
    done
    
    # Enable Universe repository
    if ! grep -q "^deb.*universe" /etc/apt/sources.list; then
        sudo add-apt-repository -y universe
    fi
    
    # Add ROS 2 GPG key
    if [[ ! -f /usr/share/keyrings/ros-archive-keyring.gpg ]]; then
        sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
            -o /usr/share/keyrings/ros-archive-keyring.gpg
    fi
    
    # Add repository to sources list
    if [[ ! -f /etc/apt/sources.list.d/ros2.list ]]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
            sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    fi
    
    # Step 4: Install ROS packages
    echo "📦 Installing ROS packages..."
    sudo apt update -qq
    
    # Critical system upgrade (as per ROS documentation)
    echo "⚠️  Performing critical system upgrades..."
    sudo apt upgrade -y -qq systemd udev
    
    # Install ROS packages
    ros_packages=(
        ros-humble-desktop
        python3-rosdep
        python3-colcon-common-extensions
        ros-dev-tools
    )
    
    for pkg in "${ros_packages[@]}"; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            sudo apt install -y -qq "$pkg"
        fi
    done
    
    # Step 5: Initialize rosdep
    echo "🔧 Initializing rosdep..."
    if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
        sudo rosdep init || true
    fi
    rosdep update
    
    # Step 6: Environment setup
    echo "⚡ Setting up environment..."
    
    # Detect current shell
    CURRENT_SHELL=$(basename "$SHELL")
    case "$CURRENT_SHELL" in
        bash)  SHELL_RC="$HOME/.bashrc" ;;
        zsh)   SHELL_RC="$HOME/.zshrc"  ;;
        fish)  SHELL_RC="$HOME/.config/fish/config.fish" ;;
        *)     SHELL_RC="$HOME/.bashrc" ;;
    esac
    
    # Add sourcing command to shell RC
    setup_command="source /opt/ros/humble/setup.${CURRENT_SHELL:-bash}"
    if ! grep -q "$setup_command" "$SHELL_RC"; then
        echo "$setup_command" | tee -a "$SHELL_RC" > /dev/null
    fi
    
    # Source immediately for current session
    set +u  # Temporarily disable unbound variable check
    source "/opt/ros/humble/setup.bash"
    set -u
    
    # Step 7: Verify installation
    echo "✅ Verifying installation..."
    
    verification_passed=true
    
    # Check 1: ROS directory
    if [[ ! -d "/opt/ros/humble" ]]; then
        echo "❌ ROS installation directory not found!"
        verification_passed=false
    fi
    
    # Check 2: ROS environment variables
    if [[ -z "${ROS_DISTRO}" ]]; then
        echo "❌ ROS_DISTRO environment variable not set!"
        verification_passed=false
    elif [[ "$ROS_DISTRO" != "humble" ]]; then
        echo "❌ Incorrect ROS_DISTRO: $ROS_DISTRO (expected humble)"
        verification_passed=false
    fi
    
    # Check 3: ros2 command availability
    if ! command -v ros2 &> /dev/null; then
        echo "❌ ros2 command not found!"
        verification_passed=false
    fi
    
    # Check 4: Package installation
    if ! dpkg -l | grep -q 'ros-humble-desktop'; then
        echo "❌ ros-humble-desktop package not installed!"
        verification_passed=false
    fi
    
    # Final verification result
    if $verification_passed; then
        echo "✔️  All checks passed!"
        echo
        echo "🎉 Installation SUCCESSFUL!"
        echo "---------------------------"
        echo "To verify with demo nodes:"
        echo "1. In first terminal: ros2 run demo_nodes_cpp talker"
        echo "2. In second terminal: ros2 run demo_nodes_py listener"
    else
        echo "❌ Verification failed! See errors above."
        exit 1
    fi
}

# Execute main
main