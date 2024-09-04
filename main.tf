data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}


# user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  for_each = lookup(var.registry, "encryption", null) != null || (lookup(
    lookup(var.registry, "identity", {}), "type", null) == "UserAssigned" && lookup(
    lookup(var.registry, "identity", {}), "identity_ids", null
  ) == null) ? { "mi" : true } : {}

  name                = try(var.registry.encryption.identity_name, "uai-${var.registry.name}")
  resource_group_name = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  location            = coalesce(lookup(var.registry, "location", null), var.location)
  tags                = try(var.registry.tags, var.tags, null)
}

# role assignments
resource "azurerm_role_assignment" "rol" {
  for_each = lookup(var.registry, "encryption", null) != null ? { "mi" : true } : {}

  scope                = var.registry.encryption.role_assignment_scope
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.mi[each.key].principal_id
}

resource "azurerm_role_assignment" "admins" {
  for_each = lookup(
    var.registry, "scope_maps", {}
  )

  scope                = coalesce(lookup(each.value, "key_vault_id", null), lookup(var.registry, "vault", null))
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# container registry
resource "azurerm_container_registry" "acr" {
  name                          = var.registry.name
  resource_group_name           = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  location                      = coalesce(lookup(var.registry, "location", null), var.location)
  sku                           = try(var.registry.sku, "Standard")
  admin_enabled                 = try(var.registry.admin_enabled, false)
  quarantine_policy_enabled     = try(var.registry.quarantine_policy_enabled, false)
  network_rule_bypass_option    = try(var.registry.network_rule_bypass_option, "AzureServices")
  public_network_access_enabled = try(var.registry.public_network_access_enabled, true)
  zone_redundancy_enabled       = try(var.registry.zone_redundancy_enabled, false)
  tags                          = try(var.registry.tags, var.tags, {})
  anonymous_pull_enabled        = try(var.registry.anonymous_pull_enabled, false)
  export_policy_enabled         = try(var.registry.export_policy_enabled, true)
  data_endpoint_enabled         = try(var.registry.data_endpoint_enabled, false)

  dynamic "trust_policy" {
    for_each = lookup(var.registry, "trust_policy", null) != null ? { "default" : var.registry.trust_policy } : {}

    content {
      enabled = try(trust_policy.value.enabled, false)
    }
  }

  dynamic "retention_policy" {
    for_each = lookup(var.registry, "retention_policy", null) != null ? { "default" : var.registry.retention_policy } : {}

    content {
      enabled = try(retention_policy.value.enabled, false)
      days    = try(retention_policy.value.days, 7)
    }
  }

  dynamic "identity" {
    for_each = lookup(var.registry, "identity", null) != null || lookup(var.registry, "encryption", null) != null ? [1] : []
    content {
      type = coalesce(
        lookup(lookup(var.registry, "identity", {}), "type", null),
        lookup(var.registry, "encryption", null) != null ? "UserAssigned" : null
      )
      identity_ids = distinct(concat(
        lookup(lookup(var.registry, "identity", {}), "identity_ids", []),
        lookup(var.registry, "encryption", null) != null ? [azurerm_user_assigned_identity.mi["mi"].id] : [],
        lookup(lookup(var.registry, "identity", {}), "type", null) == "UserAssigned" &&
        lookup(lookup(var.registry, "identity", {}), "identity_ids", null) == null ?
        [azurerm_user_assigned_identity.mi["mi"].id] : []
      ))
    }
  }

  dynamic "georeplications" {
    for_each = var.registry.sku == "Premium" ? lookup(var.registry, "georeplications", {}) : {}

    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = try(georeplications.value.zone_redundancy_enabled, false)
      regional_endpoint_enabled = try(georeplications.value.regional_endpoint_enabled, false)
      tags                      = try(georeplications.value.tags, var.tags, null)
    }
  }

  dynamic "encryption" {
    for_each = lookup(var.registry, "encryption", null) != null ? { "default" : var.registry.encryption } : {}

    content {
      enabled            = try(encryption.value.enabled, true)
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = azurerm_user_assigned_identity.mi["mi"].client_id
    }
  }

  dynamic "network_rule_set" {
    for_each = lookup(var.registry, "network_rule_set", null) != null ? [1] : []
    content {
      default_action = lookup(var.registry.network_rule_set, "default_action", "Allow")

      dynamic "ip_rule" {
        for_each = lookup(var.registry.network_rule_set, "ip_rules", {})
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
  for_each = lookup(
    var.registry, "scope_maps", {}
  )

  name                    = lookup(each.value, "scope_name", "scope-${each.key}")
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  actions                 = each.value.actions
  description             = lookup(each.value, "description", null)
}

# tokens
resource "azurerm_container_registry_token" "token" {
  for_each = lookup(
    var.registry, "scope_maps", {}
  )

  name                    = lookup(each.value, "token_name", "token-${each.key}")
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  scope_map_id            = azurerm_container_registry_scope_map.scope[each.key].id
}

resource "azurerm_container_registry_token_password" "password" {
  for_each = lookup(
    var.registry, "scope_maps", {}
  )

  container_registry_token_id = azurerm_container_registry_token.token[each.key].id
  password1 {
    expiry = lookup(
      each.value, "token_expiry", null
    )
  }
  password2 {
    expiry = lookup(
      each.value, "token_expiry", null
    )
  }
}

# secrets
resource "azurerm_key_vault_secret" "secret1" {
  for_each = lookup(
    var.registry, "scope_maps", {}
  )

  key_vault_id = coalesce(lookup(
    each.value, "key_vault_id", null
  ), lookup(var.registry, "vault", null))

  name  = "${lookup(each.value, "secret_name", "${var.naming.key_vault_secret}-${each.key}")}-1"
  tags  = lookup(each.value, "tags", var.tags)
  value = azurerm_container_registry_token_password.password[each.key].password1[0].value

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

resource "azurerm_key_vault_secret" "secret2" {
  for_each = lookup(var.registry, "scope_maps", {})

  key_vault_id = coalesce(lookup(
    each.value, "key_vault_id", null
  ), lookup(var.registry, "vault", null))

  name  = "${lookup(each.value, "secret_name", "${var.naming.key_vault_secret}-${each.key}")}-2"
  tags  = lookup(each.value, "tags", var.tags)
  value = azurerm_container_registry_token_password.password[each.key].password2[0].value

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# agent pools
resource "azurerm_container_registry_agent_pool" "pools" {
  for_each = lookup(var.registry, "agentpools", {})

  name                    = each.key
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  location                = coalesce(lookup(var.registry, "location", null), var.location)

  instance_count            = lookup(each.value, "instances", 1)
  tier                      = lookup(each.value, "tier", "S2")
  virtual_network_subnet_id = lookup(each.value, "virtual_network_subnet_id", null)

  tags = try(each.value.tags, var.tags, null)
}
