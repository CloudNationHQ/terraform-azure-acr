# Container Registry Tasks

This submodule streamlines container registry tasks management.

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

- [azurerm_container_registry_task.tasks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task) (resource)
- [azurerm_container_registry_task_schedule_run_now.tasks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task_schedule_run_now) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_tasks"></a> [tasks](#input\_tasks)

Description: contains container registry tasks

Type:

```hcl
map(object({
    task_name             = optional(string)
    container_registry_id = string
    agent_pool_name       = optional(string)
    enabled               = optional(bool, true)
    is_system_task        = optional(bool, false)
    log_template          = optional(string)
    schedule_run_now      = optional(bool, false)
    timeout_in_seconds    = optional(number)
    tags                  = optional(map(string))
    agent_setting = optional(object({
      cpu = optional(number, 2)
    }))
    platform = optional(object({
      architecture = optional(string, "amd64")
      os           = optional(string, "Linux")
      variant      = optional(string)
    }))
    docker_step = optional(object({
      context_access_token = string
      context_path         = string
      dockerfile_path      = string
      image_names          = optional(list(string), [])
      arguments            = optional(map(string), {})
      cache_enabled        = optional(bool)
      target               = optional(string)
      push_enabled         = optional(bool)
      secret_arguments     = optional(map(string), {})
    }))
    encoded_step = optional(object({
      task_content         = string
      context_access_token = optional(string)
      context_path         = optional(string)
      values               = optional(map(string), {})
      secret_values        = optional(map(string), {})
      value_content        = optional(string)
    }))
    file_step = optional(object({
      task_file_path       = string
      context_access_token = optional(string)
      context_path         = optional(string)
      value_file_path      = optional(string)
      values               = optional(map(string), {})
      secret_values        = optional(map(string), {})
    }))
    base_image_trigger = optional(object({
      name                        = string
      type                        = string
      enabled                     = optional(bool, true)
      update_trigger_endpoint     = optional(string)
      update_trigger_payload_type = optional(string)
    }))
    source_triggers = optional(map(object({
      name           = string
      repository_url = string
      events         = list(string)
      source_type    = string
      enabled        = optional(bool, true)
      branch         = optional(string)
      authentication = optional(object({
        token             = string
        token_type        = string
        scope             = optional(string)
        refresh_token     = optional(string)
        expire_in_seconds = optional(number)
      }))
    })), {})
    timer_triggers = optional(map(object({
      name     = string
      schedule = string
      enabled  = optional(bool, true)
    })), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    registry_credential = optional(object({
      source = optional(object({
        login_mode = optional(string)
      }))
      custom = optional(map(object({
        login_server = string
        username     = optional(string)
        password     = optional(string)
        identity     = optional(string)
      })))
    }))
    resource_group = optional(string)
    location       = optional(string)
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: contains the region

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `null`

### <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)

Description: contains the resource group name

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

No outputs.
<!-- END_TF_DOCS -->
