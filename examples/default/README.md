# Default

This example illustrates the default setup, in its simplest form.

## Types

```hcl
registry = object({
  name           = string
  location       = string
  resource_group = string
  sku            = optional(string)
})
```
