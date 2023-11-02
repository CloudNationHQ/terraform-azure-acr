output "registry" {
  description = "contains container registry related configuration"
  value       = module.registry.acr
  sensitive   = true
}

output "subscriptionId" {
  description = "contains the subscription id"
  value       = module.registry.subscriptionId
}
