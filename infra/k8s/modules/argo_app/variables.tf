variable "base_name" {
  description = "Base name for resources"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (ACR)"
  type        = string
}

variable "repo_url" {
  description = "URL of the Git repository for the ArgoCD application"
  type        = string
}