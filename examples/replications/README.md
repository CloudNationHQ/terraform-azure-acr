# Replications

This deploys multiple geo replicas

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)

  georeplications = optional(map(object({
    location                  = string
    regional_endpoint_enabled = optional(bool)
  })))
})
```
