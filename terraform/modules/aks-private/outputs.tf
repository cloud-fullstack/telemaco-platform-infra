output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "oidc_issuer_url" {
  description = "Used to create federated credentials for Workload Identity."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_object_id" {
  description = "Grant AcrPull on the container registry to this identity."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
