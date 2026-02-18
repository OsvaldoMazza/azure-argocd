terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 6.0.0" # Updated to a more recent version of the provider
    }
  }
}

provider "argocd" {
  # Here we assume that ArgoCD is running locally and accessible via port-forwarding.
  # If you are using kubectl port-forward:
  server_addr = "localhost:8080"
  auth_token  = var.argocd_token 
  insecure    = true
}