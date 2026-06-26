output "resource_group_name" {
  description = "Azure Resource Group name."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.this.login_server
}

output "get_credentials_command" {
  description = "Command to configure kubectl against this AKS cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing"
}

output "docker_build_command" {
  description = "Command to build the application image."
  value       = "docker build -t ${azurerm_container_registry.this.login_server}/testetecnico:latest ."
}

output "docker_push_command" {
  description = "Command to push the application image to ACR."
  value       = "docker push ${azurerm_container_registry.this.login_server}/testetecnico:latest"
}

output "kubectl_set_image_command" {
  description = "Command to point the Kubernetes deployment to the image pushed to ACR."
  value       = "kubectl set image deployment/testetecnico testetecnico=${azurerm_container_registry.this.login_server}/testetecnico:latest -n testetecnico"
}
