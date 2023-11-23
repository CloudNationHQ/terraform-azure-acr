This sample demonstrates setting up scope maps, specifying fine-grained permissions for container image access, to enforce security and control in multi-user environments.

## Usage

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.3"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    vault         = module.kv.vault.id
    sku           = "Premium"

    scope_maps = {
      prod = {
        token_expiry = "2024-03-22T17:57:36+08:00"
        actions = [
          "repositories/repo1/content/read",
          "repositories/repo1/content/write"
        ]
      }
    }
  }
}
````
