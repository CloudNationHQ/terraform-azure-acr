data "azurerm_subscription" "current" {}

# user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  for_each = try(var.registry.encryption.enable, false) == true ? { "mi" : true } : {}

  name                = try(var.registry.encryption.identity_name, "uai-${var.registry.name}")
  resource_group_name = coalesce(lookup(var.registry, "resourcegroup", null), var.resourcegroup)
  location            = coalesce(lookup(var.registry, "location", null), var.location)
  tags                = try(var.registry.tags, var.tags, null)
}

# role assignment
resource "azurerm_role_assignment" "rol" {
  for_each = try(var.registry.encryption.enable, false) == true ? { "mi" : true } : {}

  scope                = var.registry.encryption.role_assignment_scope
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.mi[each.key].principal_id
}

# container registry
resource "azurerm_container_registry" "acr" {
  name                          = var.registry.name
  resource_group_name           = coalesce(lookup(var.registry, "resourcegroup", null), var.resourcegroup)
  location                      = coalesce(lookup(var.registry, "location", null), var.location)
  sku                           = try(var.registry.sku, "Standard")
  admin_enabled                 = try(var.registry.admin_enabled, false)
  quarantine_policy_enabled     = try(var.registry.quarantine_policy_enabled, false)
  network_rule_bypass_option    = try(var.registry.network_rule_bypass_option, "AzureServices")
  public_network_access_enabled = try(var.registry.public_network_access_enabled, true)
  zone_redundancy_enabled       = try(var.registry.zone_redundancy_enabled, false)
  tags                          = try(var.registry.tags, var.tags, null)
  anonymous_pull_enabled        = try(var.registry.anonymous_pull_enabled, false)
  export_policy_enabled         = try(var.registry.export_policy_enabled, true)
  data_endpoint_enabled         = try(var.registry.data_endpoint_enabled, false)

  dynamic "trust_policy" {
    for_each = try(var.registry.trust_policy.enabled, false) == true ? [1] : []

    content {
      enabled = var.registry.trust_policy.enabled
    }
  }

  dynamic "retention_policy" {
    for_each = try(var.registry.retention_policy.enabled, false) == true ? [1] : []

    content {
      enabled = var.registry.retention_policy.enabled
      days    = try(var.registry.retention_policy.days, 90)
    }
  }

  identity {
    type = try(var.registry.encryption.enable, false) == true ? "UserAssigned" : "SystemAssigned"

    identity_ids = try([azurerm_user_assigned_identity.mi["mi"].id], [])
  }

  dynamic "georeplications" {
    for_each = {
      for repl in local.replications : repl.repl_key => repl
      if var.registry.sku == "Premium"
    }

    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enable
    }
  }

  #can only be enabled at creation time
  dynamic "encryption" {
    for_each = try(var.registry.encryption.enable, false) == true ? [1] : []

    content {
      enabled            = try(encryption.enable, true)
      key_vault_key_id   = var.registry.encryption.kv_key_id
      identity_client_id = azurerm_user_assigned_identity.mi["mi"].client_id
    }
  }

  dynamic "network_rule_set" {
    for_each = try(var.registry.network_rule_set, null) != null ? [1] : []
    content {
      default_action = try(var.registry.network_rule_set.default_action, "Allow")

      dynamic "ip_rule" {
        for_each = { for key, ipr in try(var.registry.network_rule_set.ip_rules, {}) : key => ipr }
        content {
          action   = "Allow" # Only Allow is supported at this time
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.rol
  ]
}

# fine grained access control used for non human identities
# scope maps
resource "azurerm_container_registry_scope_map" "scope" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name                    = each.value.name
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resourcegroup", null), var.resourcegroup)
  actions                 = each.value.actions
  description             = each.value.description
}

# tokens
resource "azurerm_container_registry_token" "token" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name                    = each.value.token_name
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resourcegroup", null), var.resourcegroup)
  scope_map_id            = azurerm_container_registry_scope_map.scope[each.key].id
}

# token passwords
resource "azurerm_container_registry_token_password" "password" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  container_registry_token_id = azurerm_container_registry_token.token[each.key].id

  password1 {
    expiry = each.value.token_expiry
  }

  password2 {
    expiry = each.value.token_expiry
  }
}

# secrets
resource "azurerm_key_vault_secret" "secret1" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name         = "${each.value.secret_name}-1"
  value        = azurerm_container_registry_token_password.password[each.key].password1[0].value
  key_vault_id = each.value.key_vault_id
  tags         = each.value.tags
}

resource "azurerm_key_vault_secret" "secret2" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name         = "${each.value.secret_name}-2"
  value        = azurerm_container_registry_token_password.password[each.key].password2[0].value
  key_vault_id = each.value.key_vault_id
  tags         = each.value.tags
}

# agent pools
resource "azurerm_container_registry_agent_pool" "pools" {
  for_each = local.pools

  name                      = each.value.name
  container_registry_name   = azurerm_container_registry.acr.name
  instance_count            = each.value.instance_count
  resource_group_name       = coalesce(lookup(var.registry, "resourcegroup", null), var.resourcegroup)
  location                  = coalesce(lookup(var.registry, "location", null), var.location)
  tier                      = each.value.tier
  virtual_network_subnet_id = each.value.virtual_network_subnet_id
  tags                      = each.value.tags
}
