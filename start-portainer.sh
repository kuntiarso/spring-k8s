#!/bin/bash

# Script to install Portainer using Helm in the 'portainer' namespace

NAMESPACE="portainer"
RELEASE_NAME="portainer"
HELM_REPO="https://portainer.github.io/k8s"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is not installed. Please install Helm before running this script."
    exit 1
fi

# Add the Portainer Helm repository if it's not already added
if ! helm repo list | grep -q "portainer\s*$HELM_REPO"; then
    echo "Adding Portainer Helm repository..."
    helm repo add portainer "$HELM_REPO"
    helm repo update
else
    echo "Portainer Helm repository already added."
fi

# Create the namespace if it doesn't exist
kubectl get namespace "$NAMESPACE" &> /dev/null
if [ $? -ne 0 ]; then
    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
else
    echo "Namespace '$NAMESPACE' already exists."
fi

# Install Portainer using Helm with ClusterIP
echo "Installing Portainer using Helm with ClusterIP..."
helm upgrade --install "$RELEASE_NAME" portainer/portainer \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --set service.type=ClusterIP \
    --set persistence.enabled=true \
    --set persistence.size=3Gi

if [ $? -eq 0 ]; then
    echo "Portainer installed successfully in namespace '$NAMESPACE' with release name '$RELEASE_NAME'."
    echo "Portainer is now accessible internally within your cluster."
    echo "To access Portainer from your local machine, run:"
    echo "  kubectl port-forward --namespace $NAMESPACE svc/$RELEASE_NAME {PORT}:{PORT}"
    echo "Then open your web browser and navigate to http://localhost:{PORT}."
else
    echo "Error: Portainer installation failed."
    exit 1
fi

exit 0
