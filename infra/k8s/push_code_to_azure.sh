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

echo "Get src directory and Docker image details..."
# Variables
SRC_DIR="$(dirname "$0")/../../"
DOCKER_IMAGE_NAME="${base_name}-image"
ACR_LOGIN_SERVER="$(terraform output -raw acr_login_server)"

# Build Docker image
if [ -f "$SRC_DIR/Dockerfile" ]; then
  echo "Building Docker image using Dockerfile at the root..."
  docker build -t "$DOCKER_IMAGE_NAME" "$SRC_DIR"
else
  echo "Dockerfile not found at $SRC_DIR. Exiting."
  exit 1
fi

# Log in to ACR
echo "Logging in to Azure Container Registry..."
az acr login --name "$ACR_LOGIN_SERVER"

# Tag and push Docker image to ACR
echo "Tagging and pushing Docker image to ACR..."
docker tag "$DOCKER_IMAGE_NAME" "$ACR_LOGIN_SERVER/$DOCKER_IMAGE_NAME"
docker push "$ACR_LOGIN_SERVER/$DOCKER_IMAGE_NAME"

echo "Docker image pushed successfully."