data "azurerm_client_config" "current" {}

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
  trust_policy_enabled          = try(var.registry.trust_policy_enabled, false)
  retention_policy_in_days      = try(var.registry.retention_policy_in_days, 0)

  dynamic "identity" {
    for_each = lookup(
      var.registry, "identity", null
    ) != null || lookup(var.registry, "encryption", null) != null ? [1] : []

    content {
      type = coalesce(
        try(var.registry.identity.type, null),
        var.registry.encryption != null ? "UserAssigned" : null
      )

      identity_ids = distinct(concat(
        lookup(lookup(var.registry, "identity", {}), "identity_ids", []),

        # if encryption is defined, add the user-assigned identity.
        lookup(var.registry, "encryption", null) != null ? [azurerm_user_assigned_identity.mi["mi"].id] : [],

        # if type is "UserAssigned" and no identity_ids are provided, add the user-assigned identity.
        lookup(lookup(var.registry, "identity", {}), "type", null) == "UserAssigned" && length(lookup(lookup(var.registry, "identity", {}), "identity_ids", [])) == 0 ? [azurerm_user_assigned_identity.mi["mi"].id] : []
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
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = azurerm_user_assigned_identity.mi["mi"].client_id
    }
  }

  dynamic "network_rule_set" {
    for_each = lookup(var.registry, "network_rule_set", null) != null ? [1] : []

    content {
      default_action = lookup(var.registry.network_rule_set, "default_action", "Allow")

      dynamic "ip_rule" {
        for_each = lookup(
          var.registry.network_rule_set, "ip_rules", {}
        )

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

# scope maps
resource "azurerm_container_registry_scope_map" "scope" {
  for_each                = lookup(var.registry, "scope_maps", {})
  name                    = lookup(each.value, "name", "scope-${each.key}")
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  actions                 = each.value.actions
  description             = lookup(each.value, "description", null)
}

# tokens
resource "azurerm_container_registry_token" "token" {
  for_each = merge([
    for scope_key, scope in lookup(var.registry, "scope_maps", {}) : {
      for token_key, token in lookup(scope, "tokens", {}) :
      "${scope_key}.${token_key}" => {
        scope_key = scope_key
        token_key = token_key
        token     = token
      }
    }
  ]...)
  name                    = lookup(each.value.token, "name", "token-${each.value.scope_key}-${each.value.token_key}")
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  scope_map_id            = azurerm_container_registry_scope_map.scope[each.value.scope_key].id
}

# token passwords
resource "azurerm_container_registry_token_password" "password" {
  for_each = merge([
    for scope_key, scope in lookup(var.registry, "scope_maps", {}) : {
      for token_key, token in lookup(scope, "tokens", {}) :
      "${scope_key}.${token_key}" => {
        scope_key = scope_key
        token_key = token_key
        token     = token
      }
    }
  ]...)

  container_registry_token_id = azurerm_container_registry_token.token[each.key].id

  password1 {
    expiry = lookup(each.value.token, "expiry", null)
  }
  password2 {
    expiry = lookup(each.value.token, "expiry", null)
  }
}

# secrets generated from module
resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    for pair in flatten([
      for k, v in merge([
        for scope_key, scope in lookup(var.registry, "scope_maps", {}) : {
          for token_key, token in lookup(scope, "tokens", {}) :
          "${scope_key}.${token_key}" => {
            scope_key = scope_key
            token_key = token_key
            token     = token
          }
        }
        ]...) : [
        {
          key            = k
          value          = v
          password_num   = "1"
          password_value = azurerm_container_registry_token_password.password[k].password1[0].value
        },
        {
          key            = k
          value          = v
          password_num   = "2"
          password_value = azurerm_container_registry_token_password.password[k].password2[0].value
        }
      ] if !contains(keys(v.token), "secret")
    ]) : "${pair.key}-${pair.password_num}" => pair
  }

  key_vault_id    = coalesce(lookup(var.registry, "vault", null))
  name            = lookup(each.value.value.token, "secret_name", "${var.naming.key_vault_secret}-${each.value.value.token_key}-${each.value.password_num}")
  tags            = var.tags
  value           = each.value.password_value
  expiration_date = lookup(each.value.value.token, "expiry", null)
  not_before_date = try(each.value.value.token.not_before_date, null)
  content_type    = try(each.value.value.token.content_type, null)
  depends_on      = [azurerm_role_assignment.admins]
}

# agent pools
resource "azurerm_container_registry_agent_pool" "pools" {
  for_each = lookup(
    var.registry, "agentpools", {}
  )

  name                    = each.key
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  location                = coalesce(lookup(var.registry, "location", null), var.location)

  instance_count            = lookup(each.value, "instances", 1)
  tier                      = lookup(each.value, "tier", "S2")
  virtual_network_subnet_id = lookup(each.value, "virtual_network_subnet_id", null)

  tags = try(
    each.value.tags, var.tags, null
  )
}

# webhooks
resource "azurerm_container_registry_webhook" "webhook" {
  for_each = lookup(
    var.registry, "webhooks", {}
  )

  name                = try(each.value.name, join("", [var.naming.container_registry_webhook, each.key]))
  resource_group_name = coalesce(lookup(var.registry, "resource_group", null), var.resource_group)
  registry_name       = azurerm_container_registry.acr.name
  location            = coalesce(lookup(var.registry, "location", null), var.location)

  service_uri    = each.value.service_uri
  status         = lookup(each.value, "status", "enabled")
  scope          = each.value.scope
  actions        = each.value.actions
  custom_headers = lookup(each.value, "custom_headers", null)

  tags = try(
    each.value.tags, var.tags, null
  )
}

# caching rules
resource "azurerm_container_registry_cache_rule" "cache" {
  for_each = lookup(
    var.registry, "cache_rules", {}
  )

  name                  = lookup(each.value, "name", each.key)
  container_registry_id = azurerm_container_registry.acr.id
  target_repo           = each.value.target_repo
  source_repo           = each.value.source_repo
  credential_set_id     = try(each.value.credential_set_id, null) # no resource for this yet
}

# user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  for_each = lookup(
    var.registry, "encryption", null
    ) != null || (
    lookup(
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
