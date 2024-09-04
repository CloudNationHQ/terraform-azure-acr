output "registry" {
  description = "contains container registry related configuration"
  value       = azurerm_container_registry.acr
}

output "subscription_id" {
  description = "contains the current subscription id"
  value       = data.azurerm_subscription.current.subscription_id
}

output "agentpools" {
  description = "contains the agent pools"
  value       = azurerm_container_registry_agent_pool.pools
}
