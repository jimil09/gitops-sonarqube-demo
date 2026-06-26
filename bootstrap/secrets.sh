#!/usr/bin/env bash
# Run once before applying root-app.yaml.
# Creates the secrets that Helm charts reference but that should never live in Git.
set -euo pipefail

NAMESPACE=sonarqube-dce

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic sonarqube-db-secret \
  --namespace="$NAMESPACE" \
  --from-literal=password=sonar \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets created in namespace $NAMESPACE"
