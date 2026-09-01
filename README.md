# Container registry

This terraform module automates the creation of container registry resources on the azure cloud platform, enabling easier deployment and management of container images.

## Features

Data replication is possible across different geolocations

Detailed access control is ensured through scope maps and tokens

Data protection is enhanced by encryption with user-managed identities

Multiple task types support docker, encoded, and file-based operations

Flexible triggers enable scheduled, source, and base image automations

Dedicated agent pools provide enhanced scalability and isolation

Network rules allow granular access control and IP restrictions

Key vault integration enables secure secret management

Webhook support enables automated notifications and integrations

Custom cache rules optimize container image delivery

Connected registries enable edge and on-premises scenarios with synchronization support

Immediate task execution is supported through run-now capability

Platform settings allow customized architecture and OS configurations

Utilization of terratest for robust validation.

Integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 5.0)

## Resources

The following resources are used by this module:

- [azurerm_container_connected_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_connected_registry) (resource)
- [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (resource)
- [azurerm_container_registry_agent_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_agent_pool) (resource)
- [azurerm_container_registry_cache_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_cache_rule) (resource)
- [azurerm_container_registry_scope_map.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_scope_map) (resource)
- [azurerm_container_registry_token.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token) (resource)
- [azurerm_container_registry_token_password.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token_password) (resource)
- [azurerm_container_registry_webhook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook) (resource)
- [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_role_assignment.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_registry"></a> [registry](#input\_registry)

Description: contains container registry related configuration

Type:

```hcl
object({
    name                          = string
    resource_group_name           = optional(string)
    location                      = optional(string)
    sku                           = string
    admin_enabled                 = optional(bool)
    quarantine_policy_enabled     = optional(bool)
    network_rule_bypass_option    = optional(string)
    public_network_access_enabled = optional(bool)
    zone_redundancy_enabled       = optional(bool)
    anonymous_pull_enabled        = optional(bool)
    export_policy_enabled         = optional(bool)
    data_endpoint_enabled         = optional(bool)
    retention_policy_in_days      = optional(number)
    tags                          = optional(map(string))
    vault                         = optional(string)
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
      key_vault_key_id   = string
      identity_client_id = string
      key_vault_scope    = string
      principal_id       = string
    }))
    network_rule_set = optional(object({
      default_action = optional(string)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_agentpools"></a> [agentpools](#output\_agentpools)

Description: contains the agent pools

### <a name="output_connected_registries"></a> [connected\_registries](#output\_connected\_registries)

Description: contains the connected registries

### <a name="output_registry"></a> [registry](#output\_registry)

Description: contains container registry related configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-acr/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-acr" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/containerregistry/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/containerregistry)
