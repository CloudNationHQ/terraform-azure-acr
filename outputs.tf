output "acr" {
  value = azurerm_container_registry.acr
}

output "subscriptionId" {
  value = data.azurerm_subscription.current.subscription_id
}
