#!/bin/bash

# =================================
# Microk8s helm install script (GHCR)
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
CHART_DIR="./helm"
RELEASE_NAME="commonservice"
NAMESPACE="springk8s"
TIMEOUT="10m"  # Increased timeout

# Validate required commands
command -v microk8s >/dev/null 2>&1 || { echo >&2 "microk8s is required but not installed"; exit 1; }
command -v microk8s.kubectl >/dev/null 2>&1 || { echo >&2 "microk8s.kubectl is required but not installed"; exit 1; }
command -v microk8s.helm3 >/dev/null 2>&1 || { echo >&2 "microk8s.helm3 is required but not installed"; exit 1; }

# Validate credentials
required_vars=("GHCR_USER" "GHCR_PAT")
missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "ERROR: Missing required environment variables:"
  printf '%s\n' "${missing_vars[@]}"
  exit 1
fi

# Validate chart directory
[ -d "$CHART_DIR" ] || { echo -e "\033[31mError: Missing chart directory '$CHART_DIR'\033[0m"; exit 1; }

# Create namespace if it doesn't exist
if ! microk8s.kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Creating namespace '$NAMESPACE'..."
  microk8s.kubectl create namespace "$NAMESPACE" || {
    echo "Failed to create namespace $NAMESPACE"
    exit 1
  }
fi

# Create or update secrets
echo "Creating/updating Kubernetes secrets..."

# GHCR credentials
if ! microk8s.kubectl get secret ghcr-credentials -n "$NAMESPACE" >/dev/null 2>&1; then
  microk8s.kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username="$GHCR_USER" \
    --docker-password="$GHCR_PAT" \
    -n "$NAMESPACE" || {
    echo "Failed to create GHCR secret"
    exit 1
  }
else
  microk8s.kubectl delete secret ghcr-credentials -n "$NAMESPACE" >/dev/null 2>&1
  microk8s.kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username="$GHCR_USER" \
    --docker-password="$GHCR_PAT" \
    -n "$NAMESPACE" || {
    echo "Failed to update GHCR secret"
    exit 1
  }
fi

# GHCR login
echo "Logging in to GHCR..."
echo "$GHCR_PAT" | microk8s.helm3 registry login ghcr.io \
  -u "$GHCR_USER" \
  --password-stdin || {
  echo "Failed to login to GHCR"
  exit 1
}

# Helm operations
cd "$CHART_DIR" || {
  echo "Failed to enter chart directory $CHART_DIR"
  exit 1
}

echo "Updating Helm dependencies..."
microk8s.helm3 dependency update || {
  echo "Failed to update Helm dependencies"
  exit 1
}

echo "Deploying $RELEASE_NAME to namespace $NAMESPACE..."
microk8s.helm3 upgrade --install "$RELEASE_NAME" . \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --timeout "$TIMEOUT" \
  --wait \
  --atomic || {  # Added --atomic for automatic rollback on failure
  echo "Helm deployment failed"
  echo "Debugging information:"
  microk8s.kubectl get pods -n "$NAMESPACE"
  microk8s.kubectl describe pods -n "$NAMESPACE"
  exit 1
}

# Verification
echo -e "\n\033[32mSuccessfully deployed $RELEASE_NAME to namespace $NAMESPACE.\033[0m"
echo -e "\nDeployment status (Ctrl+C to exit watch):\033[0m"
microk8s.kubectl get pods -n "$NAMESPACE" --watch
