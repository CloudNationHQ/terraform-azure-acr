output "registry" {
  description = "contains container registry related configuration"
  value       = module.acr.registry
  sensitive   = true
}

output "subscription_id" {
  description = "contains the subscription id"
  value       = module.acr.subscription_id
}
