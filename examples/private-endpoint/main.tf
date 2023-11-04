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
    cidr          = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.19.1.0/24"]
      }
    }
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.1"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    private_endpoint = {
      name         = module.naming.private_endpoint.name
      dns_zones    = [module.private_dns.zone.id]
      subnet       = module.network.subnets.sn1.id
      subresources = ["registry"]
    }
  }
}

module "private_dns" {
  source  = "cloudnationhq/sa/azure//modules/private-dns"
  version = "~> 0.1"

  providers = {
    azurerm = azurerm.connectivity
  }

  zone = {
    name          = "privatelink.azurecr.io"
    resourcegroup = "rg-dns-shared-001"
    vnet          = module.network.vnet.id
  }
}
