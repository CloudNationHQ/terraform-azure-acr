This sample demonstrates the ability to configure multiple agent pools, allowing for scalable resource management and optimization.

## Usage

```hcl
module "registry" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.6"

  naming = local.naming

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    public_network_access_enabled = false

    agentpools = {
      pool1 = {
        instances                 = 2
        virtual_network_subnet_id = module.network.subnets.sn1.id
      }
      pool2 = {
        instances                 = 2
        virtual_network_subnet_id = module.network.subnets.sn2.id
      }
    }
  }
}
```
