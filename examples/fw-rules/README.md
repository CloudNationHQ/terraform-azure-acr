This example shows how to use network rules to enhance security with secure access control.

## Usage

```hcl
module "registry" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.1"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    network_rule_set = {
      default_action = "Deny"
      ip_rules = {
        rule_1 = {
          ip_range = "1.0.0.0/32"
        }
        rule_2 = {
          ip_range = "1.0.0.1/32"
        }
      }
    }
  }
}
```
