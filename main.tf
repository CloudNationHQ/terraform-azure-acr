data "azurerm_subscription" "current" {}

# user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  for_each = try(var.registry.encryption.enable, false) == true ? { "mi" : true } : {}

  name                = var.naming.user_assigned_identity
  resource_group_name = var.registry.resourcegroup
  location            = var.registry.location
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
  name                = var.registry.name
  resource_group_name = var.registry.resourcegroup
  location            = var.registry.location

  sku                        = try(var.registry.sku, "Standard")
  admin_enabled              = try(var.registry.enable.admin, false)
  quarantine_policy_enabled  = try(var.registry.enable.quarantine_policy, false)
  network_rule_bypass_option = try(var.registry.network_rule_bypass, "AzureServices")

  anonymous_pull_enabled = (
    var.registry.sku == "Standard" ||
    var.registry.sku == "Premium" ?
    try(var.registry.enable.anonymous_pull, false)
    : false
  )

  data_endpoint_enabled = (
    var.registry == "Premium" ?
    try(var.registry.enable.data_endpoint, false)
    : false
  )

  export_policy_enabled = (
    var.registry.sku == "Premium" &&
    try(var.registry.enable.public_network_access, true) == false ?
    try(var.registry.enable.export_policy, true)
    : true
  )

  public_network_access_enabled = (
    try(var.registry.enable.public_network_access, false)
  )

  dynamic "trust_policy" {
    for_each = var.registry.sku == "Premium" && try(var.registry.enable.trust_policy, false) == true ? [1] : []

    content {
      enabled = var.registry.enable.trust_policy
    }
  }

  dynamic "retention_policy" {
    for_each = var.registry.sku == "Premium" && try(var.registry.enable.retention_policy, false) == true ? [1] : []

    content {
      enabled = var.registry.enable.retention_policy
      days    = try(var.registry.retention_in_days, 90)
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
  resource_group_name     = var.registry.resourcegroup
  actions                 = each.value.actions
}

# tokens
resource "azurerm_container_registry_token" "token" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name                    = each.value.token_name
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = var.registry.resourcegroup
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
}

resource "azurerm_key_vault_secret" "secret2" {
  for_each = {
    for v in local.scope_maps : v.maps_key => v
  }

  name         = "${each.value.secret_name}-2"
  value        = azurerm_container_registry_token_password.password[each.key].password2[0].value
  key_vault_id = each.value.key_vault_id
}

# agent pools
resource "azurerm_container_registry_agent_pool" "pools" {
  for_each = local.pools

  name                      = each.value.name
  container_registry_name   = azurerm_container_registry.acr.name
  instance_count            = each.value.instance_count
  location                  = var.registry.location
  resource_group_name       = var.registry.resourcegroup
  tier                      = each.value.tier
  virtual_network_subnet_id = var.registry.agentpools[each.key].subnet
}

# registry tasks
resource "azurerm_container_registry_task" "tasks" {
  for_each = {
    for task in local.tasks : "${task.pool_name}.${task.task_name}" => task
  }

  agent_pool_name       = each.value.pool_name
  container_registry_id = azurerm_container_registry.acr.id
  name                  = each.value.task_name

  base_image_trigger {
    name                        = "defaultBaseimageTriggerName"
    type                        = each.value.base_image_trigger_type
    update_trigger_payload_type = "Default"
  }

  docker_step {
    context_access_token = each.value.context_access_token
    context_path         = each.value.context_path
    dockerfile_path      = each.value.dockerfile_path
    image_names          = each.value.image_names
  }

  platform {
    architecture = "amd64"
    os           = "Linux"
  }

  source_trigger {
    branch         = each.value.source_branch
    events         = each.value.source_events
    name           = "defaultSourceTriggerName"
    repository_url = each.value.repository_url
    source_type    = each.value.source_type
    authentication {
      token_type = "PAT"
      token      = each.value.access_token
    }
  }
}

# private endpoint
resource "azurerm_private_endpoint" "endpoint" {
  for_each = contains(keys(var.registry), "private_endpoint") ? { "default" = var.registry.private_endpoint } : {}

  name                = var.registry.private_endpoint.name
  location            = var.registry.location
  resource_group_name = var.registry.resourcegroup
  subnet_id           = var.registry.private_endpoint.subnet

  private_service_connection {
    name                           = "endpoint"
    is_manual_connection           = try(each.value.is_manual_connection, false)
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = each.value.subresources
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.registry.private_endpoint.dns_zones
  }
}
