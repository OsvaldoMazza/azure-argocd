terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.base_name}-rg"
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = replace("${var.base_name}acr", "-", "")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.base_name}aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.base_name}dns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ls_v2" # Updated to the smallest and most economical option
  }

  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}