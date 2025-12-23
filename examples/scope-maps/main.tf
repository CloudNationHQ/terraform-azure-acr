module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  naming = local.naming

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      random_string = {
        token2-1 = {
          length          = 24
          special         = false
          expiration_date = "2026-08-22T17:57:36+08:00"
        }
        token2-2 = {
          length          = 24
          special         = false
          expiration_date = "2026-08-22T17:57:36+08:00"
        }
      }
    }
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 5.0"

  naming = local.naming

  registry = {
    name                = module.naming.container_registry.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    vault               = module.kv.vault.id
    sku                 = "Premium"

    scope_maps = {
      prd = {
        actions = [
          "repositories/repo1/content/read",
          "repositories/repo1/content/write"
        ]
        tokens = {
          token1 = {
            # generated from module
            expiry = "2026-02-22T17:57:36+08:00"
          }
          token2 = {
            # generated outside module
            expiry = "2026-08-22T17:57:36+08:00"
            secret = {
              password1 = module.kv.secrets.token2-1.value
              password2 = module.kv.secrets.token2-2.value
            }
          }
        }
      }
    }
  }
}
