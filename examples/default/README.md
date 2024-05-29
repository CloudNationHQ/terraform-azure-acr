This example illustrates the default setup, creating a secure repository for docker images that streamlines both management and deployment workflows.

## Usage: default

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.1"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"
  }
}
```

## Usage: multiple

Additionally, for particular scenarios, the example below illustrates the capability to incorporate multiple container registries.

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.1"

  for_each = local.registries

  registry = each.value
}
```

The module uses a local to iterate, generating a registry for each key.

```hcl
locals {
  registries = {
    acr1 = {
      name          = join("", [module.naming.container_registry.name, "001"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
      sku           = "Premium"
    },
    acr2 = {
      name          = join("", [module.naming.container_registry.name, "002"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
      sku           = "Premium"

      replications = {
        sea = { location = "southeastasia" }
        eus = { location = "eastus" }
      }
    }
  }
}
```
