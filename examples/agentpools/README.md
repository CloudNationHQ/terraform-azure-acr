# Agent Pools

This deploys multiple agent pools

## Types

```hcl
registry = object({
  name                          = string
  location                      = string
  resource_group                = string
  sku                          = optional(string)
  public_network_access_enabled = optional(bool)

  agentpools = optional(map(object({
    instances                 = optional(number)
    virtual_network_subnet_id = optional(string)
  })))
})
```
