# Web Hooks

This deploys multiple web hooks

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)

  webhooks = optional(map(object({
    service_uri    = string
    scope          = string
    actions        = list(string)
    status         = optional(string)
    custom_headers = optional(map(string))
  })))
})
```
