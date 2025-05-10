#!/bin/bash

NAMESPACE="springk8s"
APP_DEPLOYMENT="commonservice"
DB_STATEFULSET="commonservice-mysql"
REPLICAS_UP=1
REPLICAS_DOWN=0

ACTION="$1"

if [ -z "$ACTION" ]; then
  echo "Usage: $0 {up|down}"
  exit 1
fi

case "$ACTION" in
  up)
    echo "Scaling up application: $APP_DEPLOYMENT in namespace: $NAMESPACE to $REPLICAS_UP replicas"
    kubectl scale deployment "$APP_DEPLOYMENT" --replicas="$REPLICAS_UP" -n "$NAMESPACE"
    echo "Scaling up database: $DB_STATEFULSET in namespace: $NAMESPACE to $REPLICAS_UP replicas"
    kubectl scale statefulset "$DB_STATEFULSET" --replicas="$REPLICAS_UP" -n "$NAMESPACE"
    echo "Scale up complete."
    ;;
  down)
    echo "Scaling down application: $APP_DEPLOYMENT in namespace: $NAMESPACE to $REPLICAS_DOWN replicas"
    kubectl scale deployment "$APP_DEPLOYMENT" --replicas="$REPLICAS_DOWN" -n "$NAMESPACE"
    echo "Scaling down database: $DB_STATEFULSET in namespace: $NAMESPACE to $REPLICAS_DOWN replicas"
    kubectl scale statefulset "$DB_STATEFULSET" --replicas="$REPLICAS_DOWN" -n "$NAMESPACE"
    echo "Scale down complete."
    ;;
  *)
    echo "Invalid action: '$ACTION'. Use 'up' or 'down'."
    exit 1
    ;;
esac

exit 0
