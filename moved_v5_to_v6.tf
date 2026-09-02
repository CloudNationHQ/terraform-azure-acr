moved {
  from = azurerm_container_registry.acr
  to   = azurerm_container_registry.this
}

moved {
  from = azurerm_container_registry_scope_map.scope
  to   = azurerm_container_registry_scope_map.this
}

moved {
  from = azurerm_container_registry_token.token
  to   = azurerm_container_registry_token.this
}

moved {
  from = azurerm_container_registry_token_password.password
  to   = azurerm_container_registry_token_password.this
}

moved {
  from = azurerm_key_vault_secret.secret
  to   = azurerm_key_vault_secret.this
}

moved {
  from = azurerm_container_registry_agent_pool.pools
  to   = azurerm_container_registry_agent_pool.this
}

moved {
  from = azurerm_container_registry_webhook.webhook
  to   = azurerm_container_registry_webhook.this
}

moved {
  from = azurerm_container_registry_cache_rule.cache
  to   = azurerm_container_registry_cache_rule.this
}

moved {
  from = azurerm_container_connected_registry.connected
  to   = azurerm_container_connected_registry.this
}
