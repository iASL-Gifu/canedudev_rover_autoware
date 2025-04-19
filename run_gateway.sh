#!/bin/bash

# ----------- Source ROS2 Workspace -----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install/setup.bash"

# ------------------------
# Start CAN interface
# ------------------------

if ip link show can0 2>/dev/null | grep -q "state UP"; then
  echo "[INFO] CAN interface can0 already up. Skipping setup."
else
  echo "[INFO] Setting up CAN interface: can0"
  sudo ip link set can0 type can bitrate 125000 restart-ms 100
  sudo ip link set up can0
fi


# ------------------------
# Docker container settings
# ------------------------

DOCKER_CONTAINER_NAME="rover-ros-gateway"
ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-28}

# ------------------------
# Cleanup function
# ------------------------

cleanup() {
  echo ""
  echo "[INFO] Caught Ctrl+C. Stopping and removing Docker container: ${DOCKER_CONTAINER_NAME}"
  docker stop "${DOCKER_CONTAINER_NAME}" >/dev/null 2>&1
  docker rm "${DOCKER_CONTAINER_NAME}" >/dev/null 2>&1
  echo "[INFO] CAN interface down: can0"
  sudo ip link set down can0
  exit 0
}

# Set trap for Ctrl+C (SIGINT)
trap cleanup SIGINT

# ------------------------
# Start Docker container
# ------------------------

if ! docker ps --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER_NAME}$"; then
  echo "[INFO] Starting Docker container: ${DOCKER_CONTAINER_NAME}"
  docker run -d --name "${DOCKER_CONTAINER_NAME}" \
    --network host --ipc host --pid host \
    --restart always \
    -e ROS_DOMAIN_ID="${ROS_DOMAIN_ID}" \
    ghcr.io/canedudev/rover/ros-gateway-humble:latest
else
  echo "[INFO] Docker container '${DOCKER_CONTAINER_NAME}' is already running. Skipping start."
fi

# ------------------------
# Battery monitoring
# ------------------------
echo "[INFO] Starting battery monitoring"
ros2 topic echo /vehicle/status/battery_charge
