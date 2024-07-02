This sample demonstrates configuring replications, enabling geo-distribution of container images to ensure high availability and faster access across regions.

## Usage

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.4"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    replications = {
      sea  = { location = "southeastasia" }
      eus  = { location = "eastus" }
      eus2 = { location = "eastus2", regional_endpoint_enabled = true }
    }
  }
}
```
