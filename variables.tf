variable "registry" {
  description = "contains container registry related configuration"
  type = object({
    name                                         = string
    resource_group_name                          = optional(string)
    location                                     = optional(string)
    sku                                          = string
    admin_enabled                                = optional(bool)
    quarantine_policy_enabled                    = optional(bool)
    network_rule_bypass_option                   = optional(string)
    public_network_access_enabled                = optional(bool)
    zone_redundancy_enabled                      = optional(bool)
    anonymous_pull_enabled                       = optional(bool)
    export_policy_enabled                        = optional(bool)
    data_endpoint_enabled                        = optional(bool)
    retention_policy_in_days                     = optional(number)
    azuread_authentication_as_arm_policy_enabled = optional(bool)
    network_rule_bypass_for_tasks_enabled        = optional(bool)
    role_assignment_mode                         = optional(string)
    tags                                         = optional(map(string))
    vault                                        = optional(string)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    georeplications = optional(map(object({
      location                        = string
      zone_redundancy_enabled         = optional(bool)
      global_endpoint_routing_enabled = bool
      tags                            = optional(map(string))
    })), {})
    encryption = optional(object({
      key_vault_key_id     = string
      identity_client_id   = string
      key_vault_scope      = string
      principal_id         = string
      role_definition_name = optional(string, "Key Vault Crypto Officer")
    }))
    network_rule_set = optional(object({
      default_action = optional(string)
      ip_rules = optional(map(object({
        ip_range = string
        action   = optional(string, "Allow")
      })), {})
    }))
    scope_maps = optional(map(object({
      name                 = optional(string)
      actions              = list(string)
      description          = optional(string)
      key_vault_id         = optional(string)
      role_definition_name = optional(string, "Key Vault Secrets Officer")
      tokens = optional(map(object({
        name             = optional(string)
        secret_name      = optional(string)
        expiry           = optional(string)
        not_before_date  = optional(string)
        content_type     = optional(string)
        enabled          = optional(bool)
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
      instances                 = optional(number)
      tier                      = optional(string)
      virtual_network_subnet_id = optional(string)
      tags                      = optional(map(string))
    })), {})
    webhooks = optional(map(object({
      name           = optional(string)
      service_uri    = string
      status         = optional(string)
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
      audit_log_enabled  = optional(bool)
      client_token_ids   = optional(list(string))
      log_level          = optional(string)
      mode               = optional(string)
      parent_registry_id = optional(string)
      sync_message_ttl   = optional(string)
      sync_schedule      = optional(string)
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
    condition     = lookup(var.registry, "location", null) != null || var.location != null
    error_message = "location must be set on var.registry.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.registry, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.registry.resource_group_name or on the module-level var.resource_group_name."
  }
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
