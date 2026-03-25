variable "registry" {
  description = "contains container registry related configuration"
  type = object({
    name                          = string
    resource_group_name           = optional(string)
    location                      = optional(string)
    sku                           = optional(string, "Standard")
    admin_enabled                 = optional(bool, false)
    quarantine_policy_enabled     = optional(bool, false)
    network_rule_bypass_option    = optional(string, "AzureServices")
    public_network_access_enabled = optional(bool, true)
    zone_redundancy_enabled       = optional(bool, false)
    anonymous_pull_enabled        = optional(bool, false)
    export_policy_enabled         = optional(bool, true)
    data_endpoint_enabled         = optional(bool, false)
    trust_policy_enabled          = optional(bool, false)
    retention_policy_in_days      = optional(number, 0)
    tags                          = optional(map(string))
    vault                         = optional(string)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    georeplications = optional(map(object({
      location                  = string
      zone_redundancy_enabled   = optional(bool, false)
      regional_endpoint_enabled = optional(bool, false)
      tags                      = optional(map(string))
    })), {})
    encryption = optional(object({
      key_vault_key_id   = string
      identity_client_id = string
      key_vault_scope    = string
      principal_id       = string
    }))
    network_rule_set = optional(object({
      default_action = optional(string, "Allow")
      ip_rules = optional(map(object({
        ip_range = string
        action   = optional(string, "Allow")
      })), {})
    }))
    scope_maps = optional(map(object({
      name         = optional(string)
      actions      = list(string)
      description  = optional(string)
      key_vault_id = optional(string)
      tokens = optional(map(object({
        name             = optional(string)
        secret_name      = optional(string)
        expiry           = optional(string)
        not_before_date  = optional(string)
        content_type     = optional(string)
        enabled          = optional(bool, true)
        value_wo_version = optional(string)
        value_wo         = optional(string)
        secret = optional(object({
          password1 = string
          password2 = string
        }))
      })), {})
    })), {})
    agentpools = optional(map(object({
      name                      = optional(string)
      instances                 = optional(number, 1)
      tier                      = optional(string, "S2")
      virtual_network_subnet_id = optional(string)
      tags                      = optional(map(string))
    })), {})
    webhooks = optional(map(object({
      name           = optional(string)
      service_uri    = string
      status         = optional(string, "enabled")
      scope          = string
      actions        = list(string)
      custom_headers = optional(map(string))
      tags           = optional(map(string))
    })), {})
    cache_rules = optional(map(object({
      name              = optional(string)
      target_repo       = string
      source_repo       = string
      credential_set_id = optional(string)
    })), {})
    connected_registries = optional(map(object({
      name               = optional(string)
      sync_token_id      = optional(string)
      sync_token         = optional(string)
      audit_log_enabled  = optional(bool, false)
      client_token_ids   = optional(list(string))
      log_level          = optional(string, "None")
      mode               = optional(string, "ReadWrite")
      parent_registry_id = optional(string)
      sync_message_ttl   = optional(string, "P1D")
      sync_schedule      = optional(string, "* * * * *")
      sync_window        = optional(string)
      notifications = optional(map(object({
        name   = string
        action = string
        tag    = optional(string)
        digest = optional(string)
      })), {})
    })), {})
  })

  validation {
    condition     = var.registry.sku == "Premium" || length(lookup(var.registry, "georeplications", {})) == 0
    error_message = "Georeplications are only supported with Premium SKU."
  }

  validation {
    condition     = var.registry.sku == "Premium" || lookup(var.registry, "encryption", null) == null
    error_message = "Customer-managed keys (encryption) are only supported with Premium SKU."
  }

  validation {
    condition     = var.registry.sku == "Premium" || !var.registry.zone_redundancy_enabled
    error_message = "Zone redundancy is only supported with Premium SKU."
  }

  validation {
    condition     = var.registry.sku != "Basic" || var.registry.retention_policy_in_days == 0
    error_message = "Retention policy is not supported with Basic SKU."
  }

  validation {
    condition     = var.registry.sku != "Basic" || !var.registry.trust_policy_enabled
    error_message = "Trust policy is not supported with Basic SKU."
  }

  validation {
    condition     = var.registry.retention_policy_in_days >= 0 && var.registry.retention_policy_in_days <= 365
    error_message = "Retention policy must be between 0 and 365 days."
  }

  validation {
    condition     = var.registry.sku == "Premium" || length(var.registry.connected_registries) == 0
    error_message = "Connected registries are only supported with Premium SKU."
  }

  validation {
    condition     = length(var.registry.connected_registries) == 0 || var.registry.data_endpoint_enabled
    error_message = "Connected registries require data_endpoint_enabled = true."
  }

  validation {
    condition = alltrue([
      for k, v in var.registry.connected_registries :
      v.sync_token_id != null || v.sync_token != null
    ])
    error_message = "Each connected registry must specify either sync_token_id or sync_token_key."
  }
}

variable "naming" {
  description = "contains naming related configuration"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
