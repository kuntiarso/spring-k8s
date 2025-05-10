#!/bin/bash

# =================================
# Scale portainer up and down in Kubernetes
# =================================

set -e  # Exit immediately if any command fails
set -o pipefail  # Capture pipe failures

# Debug mode
DEBUG=${DEBUG:-false}
$DEBUG && set -x

# Variables
PORTAINER_NAMESPACE="portainer"
PORTAINER_DEPLOYMENT_NAME="portainer"

function scale_portainer() {
  local action="$1"

  # Check if the action is valid
  if [[ "$action" != "up" && "$action" != "down" ]]; then
    echo "Invalid action: '$action'. Use 'up' or 'down'."
    return 1
  fi

  # Scale the portainer deployment
  if kubectl get deployment -n "$PORTAINER_NAMESPACE" "$PORTAINER_DEPLOYMENT_NAME" &>/dev/null; then
    if [[ "$action" == "up" ]]; then
      echo "Scaling up Portainer Deployment '$PORTAINER_DEPLOYMENT_NAME' in namespace '$PORTAINER_NAMESPACE'..."
      kubectl scale deployment -n "$PORTAINER_NAMESPACE" "$PORTAINER_DEPLOYMENT_NAME" --replicas=1
    elif [[ "$action" == "down" ]]; then
      echo "Scaling down Portainer Deployment '$PORTAINER_DEPLOYMENT_NAME' in namespace '$PORTAINER_NAMESPACE'..."
      kubectl scale deployment -n "$PORTAINER_NAMESPACE" "$PORTAINER_DEPLOYMENT_NAME" --replicas=0
    fi
    return 0
  else
    echo "Portainer Deployment '$PORTAINER_DEPLOYMENT_NAME' not found in namespace '$PORTAINER_NAMESPACE'."
    return 1
  fi
}

# Main script
if [[ -z "$1" ]]; then
  echo "Usage: $0 <up|down>"
  exit 1
fi

action="$1"

scale_portainer "$action"

if [[ "$?" -eq 0 ]]; then
  echo "Portainer scaled $action successfully."
else
  echo "Failed to scale Portainer."
fi

exit "$?"
