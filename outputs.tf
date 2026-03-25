output "registry" {
  description = "contains container registry related configuration"
  value       = azurerm_container_registry.acr
}

output "agentpools" {
  description = "contains the agent pools"
  value       = azurerm_container_registry_agent_pool.pools
}

output "connected_registries" {
  description = "contains the connected registries"
  value       = azurerm_container_connected_registry.connected
}
