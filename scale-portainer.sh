#!/bin/bash

# ******************************************************
# Microk8s.kubectl script for scaling up or down portainer pods
echo "Microk8s.kubectl script for scaling up or down portainer pods"


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


# ********************************
# Constant variables for local use
NAMESPACE="portainer"
RELEASE_NAME="portainer"
REPLICAS_UP=1
REPLICAS_DOWN=0
ACTION="$1"


# ******************************
# Check if input action is valid
if [ -z "$ACTION" ]; then
  debug "Usage: $0 {up|down}"
  exit 1
fi


# ***************************************
# Check if portainer deployment is exists
if microk8s.kubectl get deployment $RELEASE_NAME -n $NAMESPACE &>/dev/null; then
  debug "Deployment '$RELEASE_NAME' already exists in $NAMESPACE"
else
  error "Deployment '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi


# *********************************
# Run command based on input action
case "$ACTION" in
  up)
    debug "Scaling up portainer '$RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_UP replicas"
    microk8s.kubectl scale deployment "$RELEASE_NAME" --replicas="$REPLICAS_UP" -n "$NAMESPACE"
    debug "Scale up completed"
    ;;
  down)
    debug "Scaling down portainer '$RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_DOWN replicas"
    microk8s.kubectl scale deployment "$RELEASE_NAME" --replicas="$REPLICAS_DOWN" -n "$NAMESPACE"
    debug "Scale down completed"
    ;;
  *)
    error "Invalid input action '$ACTION', please use 'up' or 'down' only"
    exit 1
    ;;
esac
exit 0