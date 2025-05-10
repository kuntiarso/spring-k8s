#!/bin/bash

# =================================
# Podman run or delete mysql for local
# =================================

set -e  # Exit immediately if any command fails
set -o pipefail  # Capture pipe failures

# Debug mode
DEBUG=${DEBUG:-false}
$DEBUG && set -x

# Load secret variables from .env
if [ -f ".env" ]; then
  echo "Loading secret variables from .env"
  set -o allexport; source .env; set +o allexport
else
  echo "Warning: No .env file found"
fi

# Variables
CONTAINER_NAME="springk8s-mysql-local"
VOLUME_NAME="springk8s-mysql-local-data"
MYSQL_ROOT_PASSWORD="$MYSQL_LOCAL_ROOT_PASSWORD"
MYSQL_PASSWORD="$MYSQL_LOCAL_PASSWORD"
MYSQL_USERNAME="appuser"
MYSQL_DATABASE="appk8s"
MYSQL_IMAGE="bitnami/mysql:8.0.37"

# Function to start the container
start_container() {
  # Check if the container is already running
  if podman ps -a | grep -q "$CONTAINER_NAME"; then
    echo "MySQL container '$CONTAINER_NAME' is already running or exists."
    echo "Use $0 stop to stop it, or podman restart $CONTAINER_NAME"
    return 1
  fi

  # Check if the volume exists
  if ! podman volume exists "$VOLUME_NAME"; then
    echo "Creating volume '$VOLUME_NAME'..."
    podman volume create "$VOLUME_NAME"
    if [ $? -ne 0 ]; then
      echo "Failed to create volume '$VOLUME_NAME'."
      return 1
    fi
  else
      echo "Volume '$VOLUME_NAME' already exists."
  fi

  # Run the Podman container
  echo "Starting MySQL container '$CONTAINER_NAME'..."
  podman run --name "$CONTAINER_NAME" \
    -p 3306:3306 \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
    -e "MYSQL_USERNAME=$MYSQL_USERNAME" \
    -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    -v "$VOLUME_NAME":/bitnami/mysql \
    -d "$MYSQL_IMAGE"

  if [ $? -eq 0 ]; then
    echo "MySQL container '$CONTAINER_NAME' started successfully."
    echo "You can connect to it using: host=localhost, port=3306, user=root, password=$MYSQL_ROOT_PASSWORD"
    echo "Or using user=$MYSQL_USERNAME, password=$MYSQL_PASSWORD, database=$MYSQL_DATABASE"
  else
    echo "Failed to start MySQL container '$CONTAINER_NAME'."
    return 1
  fi
}

# Function to stop the container
stop_container() {
  # Check if the container is running
  if ! podman ps | grep -q "$CONTAINER_NAME"; then
    echo "MySQL container '$CONTAINER_NAME' is not running."
    echo "Use podman ps -a to see stopped containers."
    return 0 # Exit with success, because the intended state was achieved.
  fi

  # Stop the container
  echo "Stopping MySQL container '$CONTAINER_NAME'..."
  podman stop "$CONTAINER_NAME"

  if [ $? -eq 0 ]; then
    echo "MySQL container '$CONTAINER_NAME' stopped successfully."
  else
    echo "Failed to stop MySQL container '$CONTAINER_NAME'."
    return 1
  fi
}

# Main script logic
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {start|stop}"
  exit 1
fi

case "$1" in
  start)
    start_container
    exit $? # Use the exit code from the function
    ;;
  stop)
    stop_container
    exit $? # Use the exit code from the function
    ;;
  *)
    echo "Invalid argument: $1"
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
