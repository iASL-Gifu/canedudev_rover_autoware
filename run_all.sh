#!/bin/bash

# ========================
# ROS2 Autoware Startup Script
# - Static TF Publishing
# - Launching rqt_runtime_monitor
# - Launching Autoware (foreground)
# ========================

# ----------- Config -----------
VEHICLE_MODEL="canedudev_rover_vehicle"
SENSOR_MODEL="canedudev_rover_sensor_kit"
MAP_PATH="/home/apollo-22/map"
# ------------------------------

# Function to stop all background jobs on exit
cleanup() {
  echo -e "\n[INFO] Stopping all background jobs..."
  for pid in "${pids[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "[INFO] Process $pid terminated"
    fi
  done
  exit
}

# Trap SIGINT (Ctrl+C) and call cleanup
trap cleanup SIGINT

# Array to store background process IDs
pids=()

# ------------------------
# Static TF Publishing
# ------------------------

echo "[INFO] Publishing static TF: map → odom"
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 map odom &
pids+=($!)

echo "[INFO] Publishing static TF: odom → base_link"
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 odom base_link &
pids+=($!)

# ------------------------
# Launch rqt_runtime_monitor
# ------------------------

echo "[INFO] Launching rqt_runtime_monitor"
ros2 run rqt_runtime_monitor rqt_runtime_monitor &
pids+=($!)

# ------------------------
# Launch Autoware
# ------------------------

echo "[INFO] Launching Autoware"
ros2 launch autoware_launch autoware.launch.xml \
  vehicle_model:=${VEHICLE_MODEL} \
  sensor_model:=${SENSOR_MODEL} \
  map_path:=${MAP_PATH}

# ------------------------
# Cleanup on exit
# ------------------------

cleanup
