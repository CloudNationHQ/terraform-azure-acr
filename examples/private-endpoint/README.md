This example details a container registry setup with a private endpoint, enhancing security by restricting data access to a private network.

## Usage

```hcl
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
```

To enable private link, the below private dns submodule can be employed:

```hcl
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
```
