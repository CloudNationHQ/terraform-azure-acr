module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.25.0.0/16"]
    subnets = {
      demo = { cidr = ["10.25.1.0/24"] }
    }
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.1"

  naming = local.naming

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    agentpools = {
      demo = {
        instances = 2
        subnet    = module.network.subnets.demo.id
        tasks = {
          image = {
            access_token    = var.pat
            repository_url  = "https://github.com/cloudnationhq/az-cn-module-tf-acr.git"
            context_path    = "https://github.com/cloudnationhq/az-cn-module-tf-acr#main"
            dockerfile_path = ".azdo/Dockerfile"
            image_names     = ["azdoagent:latest"]
            source_events   = ["commit"]
          }
        }
      }
    }
  }
}
