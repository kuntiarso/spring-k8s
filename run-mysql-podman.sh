#!/bin/bash

# *********************************************************
# Podman script for running or stopping mysql local service
echo "Podman script for running or stopping mysql local service"


# *************************************
# Exit immediately if any command fails
set -e
set -o pipefail


# *******************
# Logging color funcs
debug() { echo -e "\033[1;30m[DEBUG]   $1\033[0m"; }
info() { echo -e "\033[0;36m[INFO]    $1\033[0m"; }
warn() { echo -e "\033[0;33m[WARN]    $1\033[0m"; }
error() { echo -e "\033[0;31m[ERROR]   $1\033[0m"; }


# ************************************
# Load environment variables from .env 
if [ -f ".env" ]; then
  debug "Loading environment variables from .env..."
  set -o allexport; source .env; set +o allexport
else
  warn "No .env file found in current directory"
fi


# ********************************
# Constant variables for local use
CONTAINER_NAME="springk8s-mysql-local"
VOLUME_NAME="springk8s-mysql-local-data"
MYSQL_ROOT_PASSWORD="$MYSQL_LOCAL_ROOT_PASSWORD"
MYSQL_PASSWORD="$MYSQL_LOCAL_PASSWORD"
MYSQL_USERNAME="appuser"
MYSQL_DATABASE="appk8s"
MYSQL_IMAGE="bitnami/mysql:8.0.37"


# ******************************
# Check if input action is valid
if [ "$#" -ne 1 ]; then
  debug "Usage: $0 {start|stop}"
  exit 1
fi


# *********************************
# Run command based on input action
case "$1" in
  start)
    start_container
    exit $?
    ;;
  stop)
    stop_container
    exit $?
    ;;
  *)
    error "Invalid argument: $1"
    warn "Usage: $0 {start|stop}"
    exit 1
    ;;
esac


# *******************************
# Function to start the container
start_container() {
  if podman ps -a | grep -q "$CONTAINER_NAME"; then
    debug "Mysql container '$CONTAINER_NAME' is already running or exists"
    warn "Use $0 stop to stop it, or podman restart $CONTAINER_NAME"
    return 1
  fi

  if ! podman volume exists "$VOLUME_NAME"; then
    debug "Creating volume '$VOLUME_NAME'..."
    podman volume create "$VOLUME_NAME"
    if [ $? -ne 0 ]; then
      error "Failed to create volume '$VOLUME_NAME'"
      return 1
    fi
  else
      debug "Volume '$VOLUME_NAME' already exists"
  fi

  debug "Starting mysql container '$CONTAINER_NAME'..."
  podman run --name "$CONTAINER_NAME" \
    -p 3306:3306 \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
    -e "MYSQL_USERNAME=$MYSQL_USERNAME" \
    -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    -v "$VOLUME_NAME":/bitnami/mysql \
    -d "$MYSQL_IMAGE"

  if [ $? -eq 0 ]; then
    debug "Mysql container '$CONTAINER_NAME' started successfully"
    info "You can connect to it using: host=localhost, port=3306, user=root, password=$MYSQL_ROOT_PASSWORD"
    info "Or using user=$MYSQL_USERNAME, password=$MYSQL_PASSWORD, database=$MYSQL_DATABASE"
  else
    error "Failed to start mysql container '$CONTAINER_NAME'"
    return 1
  fi
}


# ******************************
# Function to stop the container
stop_container() {
  if ! podman ps | grep -q "$CONTAINER_NAME"; then
    debug "Mysql container '$CONTAINER_NAME' is not running"
    debug "Use podman ps -a to see stopped containers"
    return 0
  fi

  debug "Stopping mysql container '$CONTAINER_NAME'..."
  podman stop "$CONTAINER_NAME"

  if [ $? -eq 0 ]; then
    debug "Mysql container '$CONTAINER_NAME' stopped successfully"
  else
    error "Failed to stop mysql container '$CONTAINER_NAME'"
    return 1
  fi
}