data "azurerm_client_config" "current" {}

# container registry
resource "azurerm_container_registry" "acr" {
  resource_group_name = coalesce(
    lookup(
      var.registry, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(
      var.registry, "location", null
    ), var.location
  )

  name                          = var.registry.name
  sku                           = var.registry.sku
  admin_enabled                 = var.registry.admin_enabled
  quarantine_policy_enabled     = var.registry.quarantine_policy_enabled
  network_rule_bypass_option    = var.registry.network_rule_bypass_option
  public_network_access_enabled = var.registry.public_network_access_enabled
  zone_redundancy_enabled       = var.registry.zone_redundancy_enabled
  anonymous_pull_enabled        = var.registry.anonymous_pull_enabled
  export_policy_enabled         = var.registry.export_policy_enabled
  data_endpoint_enabled         = var.registry.data_endpoint_enabled
  trust_policy_enabled          = var.registry.trust_policy_enabled
  retention_policy_in_days      = var.registry.retention_policy_in_days

  tags = coalesce(
    var.registry.tags, var.tags
  )

  dynamic "identity" {
    for_each = var.registry.identity != null ? [var.registry.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "georeplications" {
    for_each = var.registry.georeplications

    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled

      tags = coalesce(
        georeplications.value.tags, var.tags
      )
    }
  }

  dynamic "encryption" {
    for_each = var.registry.encryption != null ? { "default" : var.registry.encryption } : {}

    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  dynamic "network_rule_set" {
    for_each = var.registry.network_rule_set != null ? [var.registry.network_rule_set] : []

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules

        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.encryption
  ]
}

# scope maps
resource "azurerm_container_registry_scope_map" "scope" {
  for_each = var.registry.scope_maps

  resource_group_name = coalesce(
    lookup(
      var.registry, "resource_group_name", null
    ), var.resource_group_name
  )

  name = coalesce(
    each.value.name, "scope-${each.key}"
  )

  container_registry_name = azurerm_container_registry.acr.name
  actions                 = each.value.actions
  description             = each.value.description
}

# tokens
resource "azurerm_container_registry_token" "token" {
  for_each = merge([
    for scope_key, scope in var.registry.scope_maps : {
      for token_key, token in scope.tokens :
      "${scope_key}.${token_key}" => {
        scope_key = scope_key
        token_key = token_key
        token     = token
      }
    }
  ]...)

  resource_group_name = coalesce(
    lookup(
      var.registry, "resource_group_name", null
    ), var.resource_group_name
  )

  name = coalesce(
    each.value.token.name, "token-${each.value.scope_key}-${each.value.token_key}"
  )

  container_registry_name = azurerm_container_registry.acr.name
  scope_map_id            = azurerm_container_registry_scope_map.scope[each.value.scope_key].id
  enabled                 = each.value.token.enabled
}

# token passwords
resource "azurerm_container_registry_token_password" "password" {
  for_each = merge([
    for scope_key, scope in var.registry.scope_maps : {
      for token_key, token in scope.tokens :
      "${scope_key}.${token_key}" => {
        scope_key = scope_key
        token_key = token_key
        token     = token
      }
    }
  ]...)

  container_registry_token_id = azurerm_container_registry_token.token[each.key].id

  password1 {
    expiry = each.value.token.expiry
  }
  password2 {
    expiry = each.value.token.expiry
  }
}

# secrets generated from module
resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    for pair in flatten([
      for k, v in merge([
        for scope_key, scope in var.registry.scope_maps : {
          for token_key, token in scope.tokens :
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

  name = coalesce(
    each.value.value.token.secret_name, "${var.naming.key_vault_secret}-${each.value.value.token_key}-${each.value.password_num}"
  )

  key_vault_id = var.registry.vault
  value        = coalesce(each.value.value.token.value_wo_version, each.value.password_value)

  expiration_date = each.value.value.token.expiry
  not_before_date = each.value.value.token.not_before_date
  content_type    = each.value.value.token.content_type

  tags = coalesce(
    var.registry.tags, var.tags
  )

  depends_on = [azurerm_role_assignment.admins]
}

# agent pools
resource "azurerm_container_registry_agent_pool" "pools" {
  for_each = var.registry.agentpools

  resource_group_name = coalesce(
    lookup(
      var.registry, "resource_group_name", null
    ), var.resource_group_name
  )

  name = coalesce(
    each.value.name, each.key
  )

  container_registry_name = azurerm_container_registry.acr.name
  location                = coalesce(lookup(var.registry, "location", null), var.location)

  instance_count            = each.value.instances
  tier                      = each.value.tier
  virtual_network_subnet_id = each.value.virtual_network_subnet_id

  tags = coalesce(
    each.value.tags, var.tags
  )
}

# webhooks
resource "azurerm_container_registry_webhook" "webhook" {
  for_each = var.registry.webhooks

  resource_group_name = coalesce(
    lookup(
      var.registry, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(
      var.registry, "location", null
    ), var.location
  )

  name = coalesce(
    each.value.name, join("", [var.naming.container_registry_webhook, each.key])
  )

  registry_name  = azurerm_container_registry.acr.name
  service_uri    = each.value.service_uri
  status         = each.value.status
  scope          = each.value.scope
  actions        = each.value.actions
  custom_headers = each.value.custom_headers

  tags = coalesce(
    each.value.tags, var.tags
  )
}

# caching rules
resource "azurerm_container_registry_cache_rule" "cache" {
  for_each = var.registry.cache_rules

  name = coalesce(
    each.value.name, each.key
  )

  container_registry_id = azurerm_container_registry.acr.id
  target_repo           = each.value.target_repo
  source_repo           = each.value.source_repo
  credential_set_id     = each.value.credential_set_id
}

# role assignments
resource "azurerm_role_assignment" "encryption" {
  for_each = var.registry.encryption != null ? { "encryption" = var.registry.encryption } : {}

  scope                = each.value.key_vault_scope
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "admins" {
  for_each = var.registry.scope_maps

  scope                = coalesce(each.value.key_vault_id, var.registry.vault)
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
