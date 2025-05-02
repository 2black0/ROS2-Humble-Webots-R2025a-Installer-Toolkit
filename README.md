# 🤖 ROS 2 Humble + Webots Integration Installer Toolkit

A comprehensive and automated setup tool for installing **ROS 2 Humble**, **Webots R2025a**, and the **webots\_ros2** interface on **Ubuntu 22.04**. This project provides step-by-step scripts for a smooth and repeatable setup process, ideal for simulation projects such as robotics control, auto-landing, and swarm behavior.

---

## 📦 Features

* ✅ Full installation of **ROS 2 Humble** (desktop version)
* ✅ Clean **uninstallation** for reset or reinstall
* ✅ Official **Webots** simulator installation
* ✅ **webots\_ros2** bridge integration using `rosdep` & `colcon`
* ✅ Structured into 3 clear steps
* ✅ Shell-friendly and fully automatable

---

## 🧰 Project Structure

```
ROS-2-Humble-Webots-R2025a-Integration-Manager/
├── LICENSE
├── README.md
└── scripts
    ├── install-ros-humble.sh
    ├── install-webots-ros2.sh
    ├── ros-webots-installer.sh
    └── uninstall-ros-humble.sh

```

---

## 🖥️ Requirements

* **Ubuntu 22.04 LTS** only
* Internet connection
* Admin (sudo) access
* Fresh terminal (ensure `.bashrc` loads correctly)

---

## 🚀 Installation Steps

### ⚙️ Step 1: Install ROS 2 Humble

Run the ROS 2 installer script:

```bash
./install-ros-humble.sh
```

**What it does:**

* Adds ROS 2 APT repository
* Installs `ros-humble-desktop` (RViz, demos, etc.)
* Installs `colcon`, `rosdep`, and setup tools
* Initializes `rosdep` and updates
* Sources ROS environment to `~/.bashrc`

✅ At the end, run this in any new terminal to activate:

```bash
source /opt/ros/humble/setup.bash
```

### 🔁 (Optional) Step 1a: Uninstall ROS 2

To **completely remove** all ROS 2 Humble packages:

```bash
./uninstall-ros-humble.sh
```

**What it removes:**

* All `ros-humble-*` packages
* `/opt/ros/humble` installation directory
* Cleans `.bashrc` from any sourcing lines
* Option to delete `~/ros2_ws` or other user-created workspaces

---

### 🛠️ Step 2: Install Webots & ROS2 Bridge

```bash
./install-webots-ros2.sh
```

**What this script does:**

* Installs Webots simulator via Cyberbotics APT repo
* Sets up `webots_ros2` from source in a new workspace: `~/webots_ws`
* Clones official [webots\_ros2](https://github.com/cyberbotics/webots_ros2) packages
* Resolves ROS 2 dependencies via `rosdep install`
* Builds with `colcon build` and sets up shell environment

✅ ROS workspace setup:

```bash
source ~/webots_ws/install/setup.bash
```

Webots is now accessible with:

```bash
webots
```

---

### 🧩 Step 3: Use Webots–ROS 2 Integration

After completing both Step 1 and 2, you can launch simulations using `webots_ros2` launch files. Example:

```bash
cd ~/webots_ws
source install/setup.bash
ros2 launch webots_ros2_turtlebot robot_launch.py
```

You may use your own `.wbt` world and custom controllers via the Webots IDE or terminal.

---

## 🧠 Extra: All-in-One Menu

Prefer an interactive menu? Use the master installer:

```bash
./ros-webots-installer.sh
```

It presents:

```
🤖 ROS 2 & Webots Installation Manager
======================================
  [1] Install ROS Humble + Webots R2025a
  [2] Uninstall All Components
  [3] Exit
```

> It logs all actions to `ros_webots_install_<timestamp>.log` for tracking.

---

## 🧹 Cleanup / Reset

To **reset everything**:

```bash
./ros-webots-installer.sh     # then choose option [2]
```

Or remove each part individually:

```bash
./uninstall-ros-humble.sh
sudo apt remove webots
rm -rf ~/webots_ws
```

---

## 📌 Notes & Tips

* Always **source setup files** after installing:

  * `source /opt/ros/humble/setup.bash`
  * `source ~/webots_ws/install/setup.bash`
* If using multiple terminals, add them to your `.bashrc`
* You can customize your ROS 2 workspace (`src` folder) by adding your own packages

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙋‍♂️ Maintainer

**Ardy Seto Priambodo**
🔗 [robot-terbang.web.id](http://robot-terbang.web.id)
💬 [Telegram Group](http://t.me/robot_terbang)

---