module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "scope"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "westeurope"
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 2.0"

  naming = local.naming

  vault = {
    name           = module.naming.key_vault.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 3.0"

  naming = local.naming

  registry = {
    name           = module.naming.container_registry.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    vault          = module.kv.vault.id
    sku            = "Premium"

    scope_maps = {
      prd = {
        token_expiry = "2025-03-22T17:57:36+08:00"
        actions = [
          "repositories/repo1/content/read",
          "repositories/repo1/content/write"
        ]
      }
    }
  }
}
