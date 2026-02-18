#!/bin/bash

# Exit on any error
set -e

echo "Configuring Kubernetes deployment..."
echo "Loading variables from terraform.tfvars..."
# Load variables from terraform.tfvars
TFVARS_FILE="$(dirname "$0")/terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
  export $(grep -E '^[a-zA-Z_]+[[:space:]]*=' "$TFVARS_FILE" | sed 's/[[:space:]]*=[[:space:]]*/=/g' | sed 's/\"//g')
fi

echo "Loading ACR Docker image..."
# Get ACR login server from Terraform output
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
DOCKER_IMAGE_NAME="${base_name}-image:latest"


# Update deployment.yaml with the correct image name
DEPLOYMENT_FILE="$(dirname "$0")/deployment.yaml"
TEMP_FILE="$(dirname "$0")/deployment_temp.yaml"
if [ -f "$DEPLOYMENT_FILE" ]; then
  IMAGE_NAME="$ACR_LOGIN_SERVER/$DOCKER_IMAGE_NAME"
  sed "s|<your-container-registry>/<your-image-name>:latest|$IMAGE_NAME|g" "$DEPLOYMENT_FILE" > "$TEMP_FILE"

  echo "Updated deployment.yaml with ACR and image name."
else
  echo "deployment.yaml not found. Exiting."
  exit 1
fi

echo "Setting the AKS context..."
# Get AKS credentials and set context
az aks get-credentials --resource-group "${base_name}-rg" --name "${base_name}aks"

echo "Applying Kubernetes deployment..."
# Apply Kubernetes deployment
kubectl apply -f "$TEMP_FILE"
echo "Kubernetes deployment applied successfully."

rm "$TEMP_FILE"

CONTAINER_DEPLOYED="$ACR_LOGIN_SERVER/$DOCKER_IMAGE_NAME"
echo "Container deployed: $CONTAINER_DEPLOYED"

sleep 5

echo "Checking pods status..."
# Check pods status
kubectl get pods

echo "Getting service details..."
# Get service details
kubectl get service
echo "+-- Use the EXTERNAL-IP to access the application once it's available. --+"