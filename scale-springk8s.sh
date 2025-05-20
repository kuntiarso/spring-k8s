#!/bin/bash

# ******************************************************
# Microk8s.kubectl script for scaling up or down application pods
echo "Microk8s.kubectl script for scaling up or down application pods"


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
NAMESPACE="springk8s"
APP_RELEASE_NAME="commonservice"
DB_RELEASE_NAME="commonservice-mysql"
REPLICAS_UP_APP=2
REPLICAS_UP_DB=1
REPLICAS_DOWN=0
ACTION="$1"


# ******************************
# Check if input action is valid
if [ -z "$ACTION" ]; then
  debug "Usage: $0 {up|down}"
  exit 1
fi


# *********************************
# Check if app deployment is exists
if microk8s.kubectl get deployment $APP_RELEASE_NAME -n $NAMESPACE &>/dev/null; then
  debug "Deployment '$APP_RELEASE_NAME' already exists in $NAMESPACE"
else
  error "Deployment '$APP_RELEASE_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi


# *********************************
# Check if db statefulset is exists
if microk8s.kubectl get statefulset $DB_RELEASE_NAME -n $NAMESPACE &>/dev/null; then
  debug "Statefulset '$DB_RELEASE_NAME' already exists in $NAMESPACE"
else
  error "Statefulset '$DB_RELEASE_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi



# *********************************
# Run command based on input action
case "$ACTION" in
  up)
    debug "Scaling up application '$APP_RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_UP_APP replicas"
    microk8s.kubectl scale deployment "$APP_RELEASE_NAME" --replicas="$REPLICAS_UP_APP" -n "$NAMESPACE"
    debug "Scaling up database '$DB_RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_UP_DB replicas"
    microk8s.kubectl scale statefulset "$DB_RELEASE_NAME" --replicas="$REPLICAS_UP_DB" -n "$NAMESPACE"
    debug "Scale up completed"
    ;;
  down)
    debug "Scaling down application '$APP_RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_DOWN replicas"
    microk8s.kubectl scale deployment "$APP_RELEASE_NAME" --replicas="$REPLICAS_DOWN" -n "$NAMESPACE"
    debug "Scaling down database '$DB_RELEASE_NAME' in namespace '$NAMESPACE' to $REPLICAS_DOWN replicas"
    microk8s.kubectl scale statefulset "$DB_RELEASE_NAME" --replicas="$REPLICAS_DOWN" -n "$NAMESPACE"
    debug "Scale down completed"
    ;;
  *)
    error "Invalid input action '$ACTION', please use 'up' or 'down' only"
    exit 1
    ;;
esac
exit 0