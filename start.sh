#!/bin/bash

# =================================
# Microk8s helm install script (GHCR)
# =================================

set -e  # Exit immediately if any command fails

# Variables
CHART_DIR="./helm"
RELEASE_NAME="commonservice"
NAMESPACE="commonservice"
SECRETS_FILE="./helm/secrets.yaml"
GITHUB_USER="kuntiarso"

# GHCR authentication setup
GHCR_PAT="${GHCR_PAT:-$(cat .ghcr-pat 2>/dev/null || echo "")}"

# Validate we have credentials
if [ -z "$GHCR_PAT" ]; then
  echo "ERROR: GitHub Container Registry credentials not found"
  echo "Either:"
  echo "1. Set GHCR_PAT environment variable, or"
  echo "2. Create .ghcr-pat file with your PAT"
  echo "Create PAT with 'read:packages' scope at:"
  echo "https://github.com/settings/tokens"
  exit 1
fi

# Secure the token file if it exists
[ -f .ghcr-pat ] && chmod 600 .ghcr-pat

# Validation section
[ -d "$CHART_DIR" ] || { echo "Error: Missing chart directory '$CHART_DIR'"; exit 1; }
[ -f "$SECRETS_FILE" ] || { echo "Error: Missing secrets file '$SECRETS_FILE'"; exit 1; }

# Login execution to GHCR
echo "Logging in to GHCR..."
echo "$GHCR_PAT" | microk8s helm3 registry login ghcr.io \
  -u "$GITHUB_USER" \
  --password-stdin

# Navigate to chart directory
cd "$CHART_DIR"

# Handle dependencies
echo "Updating Helm dependencies..."
microk8s helm3 dependency update

# Install or upgrade chart
echo "Deploying $RELEASE_NAME to namespace $NAMESPACE..."
microk8s helm3 upgrade --install "$RELEASE_NAME" . \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "../$SECRETS_FILE"

# Verification
echo -e "\nDeployment status (Ctrl+C to exit watch):"
microk8s kubectl get pods -n "$NAMESPACE" --watch
