# 🤖 ROS 2 Humble + Webots R2025a Installer Toolkit

This repository provides a structured and automated installation flow for:

1. 🧠 **ROS 2 Humble** – The standard robotics middleware
2. 🌍 **Webots R2025a** – Powerful robot simulator by Cyberbotics
3. 🔁 **webots\_ros2** – ROS–Webots integration layer

Designed for robotics researchers, students, and developers who want a **clean, modular setup** using shell scripts. Each script is isolated per task for better control and troubleshooting.

---

## 📂 Project Structure

```
ROS2-Humble-Webots-R2025a-Installer-Toolkit/
├── LICENSE                        # Project license (MIT recommended)
├── README.md                      # This documentation file
└── scripts/                       # All shell automation scripts
    ├── 1a-install-ros-humble.sh      # Step 1a: Install ROS 2 Humble (Ubuntu 22.04)
    ├── 1b-uninstall-ros2-humble.sh   # Step 1b: Optional uninstall script
    ├── 2-install-webots-r2025a.sh    # Step 2: Install Webots R2025a
    └── 3-webots-ros2-project.sh      # Step 3: Setup webots_ros2 bridge (from source)
```

---

## 🛠️ Requirements

* ✅ Ubuntu 22.04 LTS
* ✅ Internet access
* ✅ Sudo privileges
* ✅ Fresh terminal session for proper sourcing

---

## 📦 Installation Steps

### 🧱 Step 1a – Install ROS 2 Humble

```bash
chmod +x scripts/1a-install-ros-humble.sh
./scripts/1a-install-ros-humble.sh
```

🔧 What it does:

* Adds ROS 2 apt sources
* Installs `ros-humble-desktop`
* Sets up `rosdep`, `colcon`, and necessary environment variables
* Appends to your `~/.bashrc`:

  ```bash
  source /opt/ros/humble/setup.bash
  ```

### 🧹 Step 1b – Uninstall ROS 2 (Optional Reset)

```bash
chmod +x scripts/1b-uninstall-ros2-humble.sh
./scripts/1b-uninstall-ros2-humble.sh
```

This will:

* Remove all `ros-humble-*` packages
* Delete `/opt/ros/humble/`
* Clean up `.bashrc` from ROS environment variables

---

### 🌐 Step 2 – Install Webots R2025a

```bash
chmod +x scripts/2-install-webots-r2025a.sh
./scripts/2-install-webots-r2025a.sh
```

🎯 What this script does:

* Adds Cyberbotics APT key and repo
* Installs `webots` (non-snap)
* Installs dependencies like `git`, `curl`, and `python3-vcstool`

You can now run Webots with:

```bash
webots
```

---

### 🔗 Step 3 – Setup `webots_ros2` Project

```bash
chmod +x scripts/3-webots-ros2-project.sh
./scripts/3-webots-ros2-project.sh
```

🧩 This script will:

* Create `~/webots_ws/` ROS workspace
* Clone the latest [webots\_ros2](https://github.com/cyberbotics/webots_ros2) repository
* Use `rosdep` to resolve dependencies
* Build the workspace with `colcon`
* Source the workspace:

  ```bash
  source ~/webots_ws/install/setup.bash
  ```

---

## 🚀 Quick Start After Setup

```bash
source /opt/ros/humble/setup.bash
source ~/webots_ws/install/setup.bash
ros2 launch webots_ros2_turtlebot robot_launch.py
```

---

## 🔁 Typical Use Cases

* Run robot simulation in Webots with ROS 2 nodes
* Integrate Webots vision or LiDAR data with ROS 2 pipelines
* Build your own controllers or planners using ROS 2 + Webots

---

## 💡 Tips & Troubleshooting

* If `rosdep` fails, try:

  ```bash
  sudo rosdep init
  rosdep update
  ```
* Always source the environments before launching:

  ```bash
  source /opt/ros/humble/setup.bash
  source ~/webots_ws/install/setup.bash
  ```
* For custom `.wbt` worlds or controllers, add them under your workspace or open directly in Webots GUI.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙋 Author

**Ardy Seto Priambodo**
