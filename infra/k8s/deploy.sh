#!/bin/bash

# Exit on any error
set -e

# Load variables from terraform.tfvars
TFVARS_FILE="$(dirname "$0")/terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
  export $(grep -E '^[a-zA-Z_]+[[:space:]]*=' "$TFVARS_FILE" | sed 's/[[:space:]]*=[[:space:]]*/=/g' | sed 's/\"//g')
fi

# Check if required variables are set
if [ -z "$base_name" ] || [ -z "$location" ]; then
  echo "base_name or location is not set in terraform.tfvars. Exiting."
  exit 1
fi

# Deploy infrastructure
pushd "$(dirname "$0")" > /dev/null
terraform init
terraform apply -auto-approve
popd > /dev/null

# Push Docker image to ACR
"$(dirname "$0")/push_code_to_azure.sh"

# Deploy Kubernetes resources
echo "Deploying Kubernetes resources to AKS..."
"$(dirname "$0")/config_k8s.sh"

echo " --- Deployment completed successfully ---"