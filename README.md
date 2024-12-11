# Container registry

This terraform module automates the creation of container registry resources on the azure cloud platform, enabling easier deployment and management of container images.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

A last key goal is to separate logic from configuration in the module, thereby enhancing its scalability, ease of customization, and manageability.

## Non-Goals

These modules are not intended to be complete, ready-to-use solutions; they are designed as components for creating your own patterns.

They are not tailored for a single use case but are meant to be versatile and applicable to a range of scenarios.

Security standardization is applied at the pattern level, while the modules include default values based on best practices but do not enforce specific security standards.

End-to-end testing is not conducted on these modules, as they are individual components and do not undergo the extensive testing reserved for complete patterns or solutions.

## Features

- data replication is possible across different geolocations
- detailed access control is ensured through the use of scope maps
- data protection is enhanced by encryption for data at rest
- utilization of terratest for robust validation.
- enables the configuration of multiple tasks and triggers
- supports enhanced scalability and isolation through dedicated agent pools
- integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_container_registry_agent_pool.pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_agent_pool) | resource |
| [azurerm_container_registry_cache_rule.cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_cache_rule) | resource |
| [azurerm_container_registry_scope_map.scope](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_scope_map) | resource |
| [azurerm_container_registry_token.token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token) | resource |
| [azurerm_container_registry_token_password.password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token_password) | resource |
| [azurerm_container_registry_webhook.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook) | resource |
| [azurerm_key_vault_secret.secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.rol](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | default azure region to be used. | `string` | `null` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | contains naming related configuration | `map(string)` | `{}` | no |
| <a name="input_registry"></a> [registry](#input\_registry) | contains container registry related configuration | `any` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | default resource group to be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to be added to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agentpools"></a> [agentpools](#output\_agentpools) | contains the agent pools |
| <a name="output_registry"></a> [registry](#output\_registry) | contains container registry related configuration |
<!-- END_TF_DOCS -->

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-acr/graphs/contributors).

## Contributing

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## Reference

- [Documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/containerregistry/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/containerregistry)
