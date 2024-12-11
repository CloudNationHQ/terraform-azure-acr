# Encryption

This deploys encryption capabilities

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)

  encryption = optional(object({
    enabled               = bool
    key_vault_key_id     = string
    role_assignment_scope = string
  }))
})
```
