# Integrating Demo Rover and Autoware
## Autoware
Autoware is the open-source software project for autonomous driving. If you want to know more about it, you should refer to the documentation of Autoware.
[Autoware Documentation](https://autowarefoundation.github.io/autoware-documentation/pr-347/)

## Integrate
The URL below shows how to integrate Autoware.
[Integrating Autoware](https://autowarefoundation.github.io/autoware-documentation/main/how-to-guides/integrating-autoware/overview/)

### 1. Requirements
To integrate Autoware and Demo Rover, you will need:
- CAN adapter
- Sensors
    - 3D Lidar sensor
    - (option) Camera
    - (option) IMU
    - (option) GNSS
- Packages for Demo Rover (ROS2)
    - Vehicle Interface
    - Vehicle Launch
    - Sensor Kit Launch

You can either create original Demo Rover packages or use this repository we have created.

### 2. Setup
You have two options for installing Autoware:

[Source Installation Documentation](https://autowarefoundation.github.io/autoware-documentation/main/installation/autoware/source-installation/)

[Docker Installation Documentation](https://autowarefoundation.github.io/autoware-documentation/main/installation/autoware/docker-installation/)

(Source Installation)  
setup instructions provided below are specifically for source installation. We have used a Kvaser USBcan Pro 2xHS v2, Velodyne VLP-32 LiDAR and an Xsens IMU in our setup.  

Step 1: Clone our repository:
```bash
# Clone the repository
git clone https://github.com/iASL-Gifu/canedudev_rover_autoware.git
cd ~/canedudev_rover_autoware
```

step 2: Install dependencies for Autoware:  

If you have already installed the Nvidia driver, it is recommended to edit the amd64.env file and specify the version of Cuda manually.
```bash
#Install all dependencies
./setup-dev-env.sh
#If you have already installed Nvidia-driver, cuda, cudnn, TensorRT
./setup-dev-env.sh --no-nvidia 

```
> [!WARNING]
> This script includes the installation of Nvidia drivers, Cuda, cudnn and TensorRT. Please be careful if you have already installed them, as there might be version conflicts.

step 3: Construct the workspace and clone repojitories
```bash
cd ~/cd canedudev_rover_autoware
mkdir src
vcs import src < autoware.repos
```

step 4: Install dependencies of ROS2
```bash
source /opt/ros/humble/setup.bash
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
```

step 5: Build the workspace
```bash
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```