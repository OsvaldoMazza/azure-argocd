output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "The login server of the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}