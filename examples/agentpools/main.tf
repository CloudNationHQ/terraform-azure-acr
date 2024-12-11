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
      location = "northeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 8.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    address_space  = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        address_prefixes       = ["10.18.1.0/24"]
        network_security_group = {}
      }
    }
  }
}

module "registry" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 4.0"

  naming = local.naming

  registry = {
    name           = module.naming.container_registry.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku            = "Premium"

    public_network_access_enabled = false

    agentpools = {
      pool1 = {
        instances                 = 2
        virtual_network_subnet_id = module.network.subnets.sn1.id
      }
    }
  }
}
