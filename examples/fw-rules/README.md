# Firewall Rules

This deploys firewall rules

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)

  network_rule_set = optional(object({
    default_action = string
    ip_rules = optional(map(object({
      ip_range = string
    })))
  }))
})
```
