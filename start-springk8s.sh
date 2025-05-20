#!/bin/bash

# *********************************************
# Helm run springk8s applications with microk8s
echo "Helm run springk8s applications with microk8s"


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
CHART_DIR="./helm"
RESOURCE_DIR="./helm/resources"
RELEASE_NAME="commonservice"
NAMESPACE="springk8s"
TIMEOUT="10m"


# ***************************
# Validate required directory
[ -d "$CHART_DIR" ] || { error "Missing chart directory '$CHART_DIR'"; exit 1; }
[ -d "$RESOURCE_DIR" ] || { error "Missing resource directory '$RESOURCE_DIR'"; exit 1; }


# ***************************************
# Validate required environment variables
required_vars=("GHCR_USER" "GHCR_PAT")
missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done
if [ ${#missing_vars[@]} -ne 0 ]; then
  error "Missing required environment variables:"
  printf '%s\n' "${missing_vars[@]}"
  exit 1
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


# ****************************************
# Create or update ghcr-credentials secret
debug "Creating or updating ghcr-credentials secret..."
if ! microk8s.kubectl get secret ghcr-credentials -n "$NAMESPACE" >/dev/null 2>&1; then
  microk8s.kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username="$GHCR_USER" \
    --docker-password="$GHCR_PAT" \
    -n "$NAMESPACE" || {
    error "Failed to create ghcr-credentials secret"
    exit 1
  }
else
  microk8s.kubectl delete secret ghcr-credentials -n "$NAMESPACE" >/dev/null 2>&1
  microk8s.kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username="$GHCR_USER" \
    --docker-password="$GHCR_PAT" \
    -n "$NAMESPACE" || {
    error "Failed to update ghcr-credentials secret"
    exit 1
  }
fi


# ******************************
# Login to ghcr package registry
debug "Logging in to ghcr package registry..."
echo "$GHCR_PAT" | microk8s.helm3 registry login ghcr.io \
  -u "$GHCR_USER" \
  --password-stdin || {
  error "Failed to login to ghcr package registry"
  exit 1
}


# ****************************************
# Create or update flyway-config configmap
debug "Creating or updating flyway-config configmap..."
if ! microk8s.kubectl get configmap commonservice-flyway-config -n "$NAMESPACE" >/dev/null 2>&1; then
  microk8s.kubectl create configmap commonservice-flyway-config \
    --from-file=V1__Create_phone_table.sql="$RESOURCE_DIR/V1__Create_phone_table.sql" \
    -n "$NAMESPACE" || {
    error "Failed to create flyway-config configmap"
    exit 1
  }
else
  microk8s.kubectl delete configmap commonservice-flyway-config -n "$NAMESPACE" >/dev/null 2>&1
  microk8s.kubectl create configmap commonservice-flyway-config \
    --from-file=V1__Create_phone_table.sql="$RESOURCE_DIR/V1__Create_phone_table.sql" \
    -n "$NAMESPACE" || {
    error "Failed to update flyway-config configmap"
    exit 1
  }
fi


# ************************************************
# Helm install or upgrade commonservice deployment
cd "$CHART_DIR"
debug "Updating helm dependencies..."
microk8s.helm3 dependency update || { error "Failed to update helm dependencies"; exit 1; }
info "Deploying $RELEASE_NAME to namespace $NAMESPACE..."
microk8s.helm3 upgrade --install "$RELEASE_NAME" . \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --timeout "$TIMEOUT" \
  --wait \
  --atomic || {
  error "Helm deployment failed"
  error "Debugging information:"
  microk8s.kubectl get pods -n "$NAMESPACE"
  microk8s.kubectl describe pods -n "$NAMESPACE"
  exit 1
}


# *************************************************
# Pods checking to verify deployment status success
info "\nSuccessfully deployed $RELEASE_NAME to namespace $NAMESPACE"
debug "\nDeployment status (Ctrl+C to exit watch):"
microk8s.kubectl get pods -n "$NAMESPACE" --watch