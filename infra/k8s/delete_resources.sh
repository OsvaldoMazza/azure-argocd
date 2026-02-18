#!/bin/bash

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


echo "Deleting Kubernetes resources from AKS..."
kubectl delete -f "$TEMP_FILE"

rm "$TEMP_FILE"

echo "Deleting Terraform resources from Azure..."
terraform destroy -auto-approve

echo " --- Resources deleted successfully --- "
