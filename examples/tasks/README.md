# Tasks

This deploys various tasks within the registry

## Types

```hcl
resource_group = string
location = string
tasks = map(object({
  agent_setting = optional(object({
    cpu = optional(number)
  }))
  platform = optional(object({
    architecture = string
    os          = string
  }))
  container_registry_id = string
  encoded_step = object({
    task_content = string
  })
  timer_triggers = optional(map(object({
    name     = string
    schedule = string
    enabled  = optional(bool)
  })))
  identity = optional(object({
    type = string
  }))
}))
```
