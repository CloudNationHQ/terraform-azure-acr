module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.22"

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

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 5.0"

  registry = {
    name                = module.naming.container_registry.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku                 = "Premium"

    cache_rules = {
      backend = {
        target_repo = "backend"
        source_repo = "mcr.microsoft.com/azure-cli"
      }

      frontend = {
        target_repo = "frontend"
        source_repo = "mcr.microsoft.com/dotnet/runtime"
      }

      proxy = {
        target_repo = "proxy"
        source_repo = "mcr.microsoft.com/hello-world"
      }
    }
  }
}
