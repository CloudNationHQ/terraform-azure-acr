# Cache Rules

This deploys multiple cache rules

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)

  cache_rules = optional(map(object({
    target_repo = string
    source_repo = string
  })))
})
```

## Notes

Authentication for docker registries is not available at this moment.
