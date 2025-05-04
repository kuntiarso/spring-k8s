#!/bin/bash

# =================================
# MicroK8s Helm Install Script
# =================================

set -e  # Exit immediately if any command fails

# Configuration
CHART_DIR="./helm"
RELEASE_NAME="commonservice"
NAMESPACE="commonservice"
SECRETS_FILE="./helm/secrets.yaml"

# Validate files exist
if [ ! -d "$CHART_DIR" ]; then
  echo "Error: Chart directory '$CHART_DIR' not found"
  exit 1
fi

if [ ! -f "$SECRETS_FILE" ]; then
  echo "Error: Secrets file '$SECRETS_FILE' not found"
  exit 1
fi

# Navigate to chart directory
cd "$CHART_DIR"

# Handle dependencies
echo "Updating Helm dependencies..."
microk8s helm3 dependency update

# Install chart
echo "Installing $RELEASE_NAME to namespace $NAMESPACE..."
microk8s helm3 install "$RELEASE_NAME" . \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "../$SECRETS_FILE"

# Verification
echo -e "\nDeployment status:"
microk8s kubectl get pods -n "$NAMESPACE" -w
