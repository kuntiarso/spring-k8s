#!/bin/bash

# *********************************************
# Helm run portainer applications with microk8s
echo "Helm run portainer applications with microk8s"


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
HELM_REPO="https://portainer.github.io/k8s"


# *****************************************
# Add portainer repository if not exist
if ! microk8s.helm3 repo list | grep -q "portainer\s*$HELM_REPO"; then
    debug "Adding portainer repository..."
    microk8s.helm3 repo add portainer "$HELM_REPO"
    microk8s.helm3 repo update
else
    debug "Portainer repository already added"
fi


# ******************************
# Create namespace if not exists
microk8s.kubectl get namespace "$NAMESPACE" &> /dev/null
if [ $? -ne 0 ]; then
    debug "Creating namespace '$NAMESPACE'..."
    microk8s.kubectl create namespace "$NAMESPACE"
else
    debug "Namespace '$NAMESPACE' already exists"
fi


# ********************************************
# Helm install or upgrade portainer deployment
info "Deploying $RELEASE_NAME to namespace $NAMESPACE..."
microk8s.helm3 upgrade --install "$RELEASE_NAME" portainer/portainer \
    --namespace "$NAMESPACE" \
    --create-namespace \
    -f ./values/portainer.yaml


# *************************************************
# Pods checking to verify deployment status success
info "Successfully deployed $RELEASE_NAME to namespace $NAMESPACE"
debug "Deployment status (Ctrl+C to exit watch):"
microk8s.kubectl get pods -n "$NAMESPACE" --watch