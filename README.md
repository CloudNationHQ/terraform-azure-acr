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

Immediate task execution is supported through run-now capability

Platform settings allow customized architecture and OS configurations

Utilization of terratest for robust validation.

Integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (resource)
- [azurerm_container_registry_agent_pool.pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_agent_pool) (resource)
- [azurerm_container_registry_cache_rule.cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_cache_rule) (resource)
- [azurerm_container_registry_scope_map.scope](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_scope_map) (resource)
- [azurerm_container_registry_token.token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token) (resource)
- [azurerm_container_registry_token_password.password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token_password) (resource)
- [azurerm_container_registry_webhook.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook) (resource)
- [azurerm_key_vault_secret.secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
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
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming related configuration

Type: `map(string)`

Default: `{}`

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

### <a name="output_registry"></a> [registry](#output\_registry)

Description: contains container registry related configuration
<!-- END_TF_DOCS -->

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
