# Scope Maps

This deploys multiple scope maps

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  vault          = optional(string)
  sku            = optional(string)

  scope_maps = optional(map(object({
    actions = list(string)
    tokens = optional(map(object({
      expiry = optional(string)
      secret = optional(object({
        password1 = string
        password2 = string
      }))
    })))
  })))
})
```
